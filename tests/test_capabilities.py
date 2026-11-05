#!/usr/bin/env python3
"""Exercise capability rendering in isolated chezmoi sources (no apply)."""
import pathlib
import shutil
import subprocess
import tempfile
import unittest

REPO = pathlib.Path(__file__).resolve().parents[1]


class CapabilityRendering(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = pathlib.Path(self.tmp.name)
        self.source = self.root / "source"
        shutil.copytree(REPO, self.source, ignore=shutil.ignore_patterns(".git", ".claude"))
        # Use fixture data instead of depending on a particular user's profile.
        (self.source / '.chezmoidata/15-personal.yaml').write_text(
            'profile_packages:\n  personal:\n    local_ai:\n      darwin:\n'
            '        taps:\n          - name: jundot/omlx\n'
            '            url: https://github.com/jundot/omlx\n'
            '        trusted_formulae: [jundot/omlx/omlx]\n'
            '        cli: [omlx]\n        gui_casks: [lm-studio]\n'
        )
        self.config = self.root / "chezmoi.toml"
        self.config.write_text("")

    def render(self, config, template='{{ template "darwin-brewfile" . }}'):
        self.config.write_text(config)
        return subprocess.run(
            ["chezmoi", "--source", str(self.source), "--config", str(self.config),
             "--destination", str(self.root / "home"), "execute-template", template],
            text=True, capture_output=True,
        )

    def test_default_is_base_only(self):
        result = self.render("")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(set(result.stdout.split()), {'brew', '"git"', '"chezmoi"'})

    def test_headless_local_ai_excludes_gui(self):
        result = self.render('[data.machine]\ngui=false\n[data.capabilities]\nlocal_ai=true\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('brew "omlx"', result.stdout)
        self.assertNotIn('lm-studio', result.stdout)

    def test_formula_trust_is_declared_in_bundle_for_custom_tap(self):
        script = (self.source / '.chezmoiscripts/run_onchange_darwin-install-packages.sh.tmpl').read_text()
        # Render the actual script as Darwin even when the test runs on Linux.
        template = '{{- $_ := set .chezmoi "os" "darwin" -}}' + script
        result = self.render('[data.capabilities]\nlocal_ai=true\n', template)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tap "jundot/omlx", "https://github.com/jundot/omlx", '
                      'trusted: { formulae: ["omlx"] }', result.stdout)
        self.assertIn('brew "omlx"', result.stdout)
        self.assertNotIn('brew trust --formula', result.stdout)
        self.assertNotIn('brew tap ', result.stdout)

    def test_whole_tap_trust_requires_explicit_opt_in(self):
        (self.source / '.chezmoidata/99-extra.yaml').write_text(
            'package_groups:\n  extra:\n    darwin:\n      taps:\n'
            '        - name: example/tools\n'
            '          url: https://example.org/tools.git\n'
            '          trusted: true\n'
        )
        result = self.render('[data.capabilities]\nextra=true\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('tap "example/tools", "https://example.org/tools.git", trusted: true',
                      result.stdout)

    def test_trusted_formula_requires_a_declared_tap(self):
        (self.source / '.chezmoidata/99-extra.yaml').write_text(
            'package_groups:\n  extra:\n    darwin:\n'
            '      trusted_formulae: [example/tools/tool]\n'
        )
        result = self.render('[data.capabilities]\nextra=true\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('require that tap to be declared', result.stderr)

    def test_invalid_choices_are_actionable(self):
        result = self.render('[data.capabilities]\ninterative_cli=true\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('Unknown capability', result.stderr)
        result = self.render('[data.machine]\ngui=false\n[data.capabilities]\nworkstation_apps=true\n')
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('requires machine.gui', result.stderr)

    def test_work_without_personal_files(self):
        (self.source / '.chezmoidata/15-personal.yaml').unlink()
        (self.source / '.chezmoitemplates/personal-ssh-config').unlink(missing_ok=True)
        (self.source / '.chezmoidata/90-work.yaml').write_text('profile:\n  kind: work\n')
        result = self.render('[data.machine]\ngui=true\n[data.capabilities]\nworkstation_apps=true\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('brew "git"', result.stdout)
        self.assertNotIn('obsidian', result.stdout)
        ssh = (self.source / 'private_dot_ssh/config.tmpl').read_text()
        result = self.render('[data.machine]\ngui=true\n', ssh)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn('192.168.5.161', result.stdout)

    def test_duplicate_packages_are_rendered_once(self):
        (self.source / '.chezmoidata/99-extra.yaml').write_text(
            'package_groups:\n  example:\n    darwin:\n      cli: [git, bat]\n'
        )
        result = self.render('[data.capabilities]\ninteractive_cli=true\nexample=true\n')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout.count('brew "git"'), 1)
        self.assertEqual(result.stdout.count('brew "bat"'), 1)


if __name__ == '__main__':
    unittest.main()
