#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const versionsPath = path.join(__dirname, '../docs/plan/versions.yaml');
const outputPath = path.join(__dirname, '../docs/plan/51-XCT-DEPENDENCIES.md');

try {
  const fileContents = fs.readFileSync(versionsPath, 'utf8');
  const data = yaml.load(fileContents);

  let markdown = '| Technology | Version |\n';
  markdown += '|-------------|---------|\n';

  Object.entries(data).forEach(([key, value]) => {
    const formattedKey = key.replace(/_/g, '.').replace(/@/g, '@');
    markdown += `| ${formattedKey} | ${value} |\n`;
  });

  console.log('✓ Versions table generated (append to 51-XCT-DEPENDENCIES.md)');
  console.log(markdown);
} catch (error) {
  console.error('Error generating versions table:', error.message);
  process.exit(1);
}
