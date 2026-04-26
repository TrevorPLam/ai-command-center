const fs = require('fs');
const path = require('path');

const inputFile = path.join(__dirname, '../docs/plan/51-XCT-DEPENDENCIES.md');
const outputFile = path.join(__dirname, '../docs/plan/versions.yaml');

const content = fs.readFileSync(inputFile, 'utf8');

const versions = {};

const versionSectionMatch = content.match(/## Technology version pins([\s\S]*?)^---/m);
if (versionSectionMatch) {
  const sectionContent = versionSectionMatch[1];
  const versionLines = sectionContent.match(/^-\s+\*\*[^*]+\*\*:\s*[\d^>=latest]/gm);
  
  if (!versionLines) {
    const altVersionLines = sectionContent.match(/^-\s+[^:]+:\s*[\d^>=latest]/gm);
    if (altVersionLines) {
      altVersionLines.forEach(line => {
        const match = line.match(/^-\s+(.+?):\s*(.+)$/);
        if (match) {
          let key = match[1].replace(/\*\*/g, '').replace(/`/g, '').replace(/‑/g, '_').replace(/\//g, '_').replace(/\s+/g, '_').toLowerCase();
          let value = match[2].replace(/\s+ONLY$/, '').replace(/\s+\(import from.*\)$/, '').replace(/\s+\([^)]+\)$/, '').trim();
          versions[key] = value;
        }
      });
    }
  } else {
    versionLines.forEach(line => {
      const match = line.match(/^-\s+(.+?):\s*(.+)$/);
      if (match) {
        let key = match[1].replace(/\*\*/g, '').replace(/`/g, '').replace(/‑/g, '_').replace(/\//g, '_').replace(/\s+/g, '_').toLowerCase();
        let value = match[2].replace(/\s+ONLY$/, '').replace(/\s+\(import from.*\)$/, '').replace(/\s+\([^)]+\)$/, '').trim();
        versions[key] = value;
      }
    });
  }
}

const specialPatterns = [
  { regex: /\*\*TypeScript\*\*:\s*([\d.]+)\s*in production/i, key: 'typescript_production' },
  { regex: /TypeScript 7\.0.*beta/i, key: 'typescript_beta', value: '7.0 beta' },
];

specialPatterns.forEach(pattern => {
  const match = content.match(pattern.regex);
  if (match) {
    if (pattern.transform) {
      versions[pattern.key] = pattern.transform(match);
    } else if (pattern.value) {
      versions[pattern.key] = pattern.value;
    } else {
      versions[pattern.key] = match[1];
    }
  }
});

let yamlOutput = '# Canonical version list for AI Command Center\n';
yamlOutput += '# Auto-generated from 51-XCT-DEPENDENCIES.md\n';
yamlOutput += '# Last updated: ' + new Date().toISOString() + '\n\n';

Object.keys(versions).sort().forEach(key => {
  const value = versions[key];
  if (typeof value === 'object') {
    yamlOutput += `${key}:\n`;
    Object.keys(value).forEach(subKey => {
      yamlOutput += `  ${subKey}: "${value[subKey]}"\n`;
    });
  } else {
    yamlOutput += `${key}: "${value}"\n`;
  }
});

fs.writeFileSync(outputFile, yamlOutput);
console.log(`Generated ${outputFile}`);
