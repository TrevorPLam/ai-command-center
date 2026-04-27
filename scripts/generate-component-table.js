#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const yaml = require('js-yaml');

const componentRegistryPath = path.join(__dirname, '../docs/plan/component-registry.yaml');
const outputPath = path.join(__dirname, '../docs/plan/40-COMP-OVERVIEW.md');

try {
  const fileContents = fs.readFileSync(componentRegistryPath, 'utf8');
  const data = yaml.load(fileContents);

  if (!data.components || !Array.isArray(data.components)) {
    console.error('Invalid component registry structure');
    process.exit(1);
  }

  let markdown = '# Component Overview\n\n';
  markdown += 'This document is auto-generated from `component-registry.yaml`. Do not edit manually.\n\n';
  markdown += '| ID | Module | Type | Tags | Rules | Dependencies | Notes |\n';
  markdown += '|----|--------|------|------|-------|--------------|-------|\n';

  data.components.forEach(comp => {
    const id = comp.id || '';
    const module = comp.module || '';
    const type = comp.type || '';
    const tags = Array.isArray(comp.tags) ? comp.tags.join(', ') : '';
    const rules = Array.isArray(comp.rules) ? comp.rules.join(', ') : '';
    const deps = Array.isArray(comp.dependencies) ? comp.dependencies.join(', ') : '';
    const notes = comp.notes || '';

    markdown += `| ${id} | ${module} | ${type} | ${tags} | ${rules} | ${deps} | ${notes} |\n`;
  });

  fs.writeFileSync(outputPath, markdown);
  console.log('✓ Component overview table regenerated');
} catch (error) {
  console.error('Error generating component table:', error.message);
  process.exit(1);
}
