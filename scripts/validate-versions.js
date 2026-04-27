#!/usr/bin/env node

/**
 * Validate that package.json versions match versions.yaml
 * This script ensures the canonical version list stays in sync with the actual package locks
 */

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

// Read package.json
const packageJsonPath = path.join(process.cwd(), 'package.json');
const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));

// Read versions.yaml
const versionsYamlPath = path.join(process.cwd(), 'docs/plan/versions.yaml');
const versionsYaml = fs.readFileSync(versionsYamlPath, 'utf8');
const versions = yaml.load(versionsYaml);

// Extract dependencies from package.json
const allDeps = {
  ...packageJson.dependencies,
  ...packageJson.devDependencies,
  ...packageJson.peerDependencies
};

// Normalize package names (replace @ with _ for YAML keys)
const normalizeName = (name) => name.replace('@', '_').replace('/', '_').replace('-', '_');

let mismatches = [];

for (const [pkg, version] of Object.entries(allDeps)) {
  const yamlKey = normalizeName(pkg);
  const yamlVersion = versions[yamlKey];

  if (!yamlVersion) {
    console.warn(`Warning: ${pkg} not found in versions.yaml`);
    continue;
  }

  // Compare versions (allow for range differences)
  const pkgVersion = version.replace('^', '').replace('~', '').replace('>=', '').replace('>', '');
  const yamlVersionClean = yamlVersion.replace('^', '').replace('~', '').replace('>=', '').replace('>', '');

  if (pkgVersion !== yamlVersionClean && yamlVersionClean !== 'latest') {
    mismatches.push({
      package: pkg,
      packageJson: version,
      versionsYaml: yamlVersion
    });
  }
}

if (mismatches.length > 0) {
  console.error('Version mismatches found:');
  mismatches.forEach(m => {
    console.error(`  ${m.package}: package.json="${m.packageJson}" vs versions.yaml="${m.versionsYaml}"`);
  });
  process.exit(1);
}

console.log('All versions match between package.json and versions.yaml');
process.exit(0);
