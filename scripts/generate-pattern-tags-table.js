#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const patternTagsPath = path.join(__dirname, '../docs/plan/pattern-tags.yaml');
const outputPath = path.join(__dirname, '../docs/plan/20-PLAN-INTRO.md');

try {
  const fileContents = fs.readFileSync(patternTagsPath, 'utf8');
  const data = yaml.load(fileContents);

  let markdown = '| Tag | Category | Description |\n';
  markdown += '|-----|----------|-------------|\n';

  const categories = [
    { key: 'animation_tags', name: 'Animation' },
    { key: 'data_tags', name: 'Data' },
    { key: 'specialized_tags', name: 'Specialized' },
    { key: 'livekit_tags', name: 'LiveKit' },
    { key: 'spec_tags', name: 'Spec' }
  ];

  categories.forEach(cat => {
    if (data[cat.key] && Array.isArray(data[cat.key])) {
      data[cat.key].forEach(tag => {
        markdown += `| ${tag.tag} | ${cat.name} | ${tag.description} |\n`;
      });
    }
  });

  console.log('✓ Pattern tags table generated (append to 20-PLAN-INTRO.md)');
  console.log(markdown);
} catch (error) {
  console.error('Error generating pattern tags table:', error.message);
  process.exit(1);
}
