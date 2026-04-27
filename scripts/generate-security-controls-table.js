#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const securityControlsPath = path.join(__dirname, '../docs/plan/security-controls.yaml');
const outputPath = path.join(__dirname, '../docs/plan/35-ARCH-SECURITY.md');

try {
  const fileContents = fs.readFileSync(securityControlsPath, 'utf8');
  const data = yaml.load(fileContents);

  if (!data.controls || !Array.isArray(data.controls)) {
    console.error('Invalid security controls structure');
    process.exit(1);
  }

  let markdown = '| ID | Name | Layer | Description | Mechanism | Test Method |\n';
  markdown += '|----|------|-------|-------------|-----------|-------------|\n';

  data.controls.forEach(control => {
    const id = control.id || '';
    const name = control.name || '';
    const layer = control.layer || '';
    const description = control.description || '';
    const mechanism = control.mechanism || '';
    const testMethod = control.test_method || '';

    markdown += `| ${id} | ${name} | ${layer} | ${description} | ${mechanism} | ${testMethod} |\n`;
  });

  console.log('✓ Security controls table generated (append to 35-ARCH-SECURITY.md)');
  console.log(markdown);
} catch (error) {
  console.error('Error generating security controls table:', error.message);
  process.exit(1);
}
