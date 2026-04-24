#!/usr/bin/env node

/**
 * Task Reference Validation Script
 * 
 * This script validates that all task references in "Depends On" fields
 * across markdown specification files correspond to canonical task IDs
 * defined in the task registry.
 * 
 * Usage: node scripts/validate-task-refs.js
 */

const fs = require('fs');
const path = require('path');

// ANSI color codes for output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m'
};

/**
 * Recursively find all markdown files in the project root
 */
function findMarkdownFiles(dir, files = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  
  for (const entry of entries) {
    const fullPath = path.join(dir, entry.name);
    
    if (entry.isDirectory()) {
      // Skip node_modules and .git directories
      if (entry.name !== 'node_modules' && entry.name !== '.git' && entry.name !== '.windsurf') {
        findMarkdownFiles(fullPath, files);
      }
    } else if (entry.name.endsWith('.md')) {
      files.push(fullPath);
    }
  }
  
  return files;
}

/**
 * Extract all task IDs from a markdown file
 * - Extracts from "Depends On:" lines
 * - Extracts from "### TASK-" patterns
 * - Extracts from "**Parent Task ID**:" lines
 */
function extractTaskIdsFromFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const taskIds = new Set();
  
  // Pattern 1: Depends On: lines (comma-separated task IDs)
  const dependsOnPattern = /Depends On:\s*([^\n]+)/g;
  let match;
  while ((match = dependsOnPattern.exec(content)) !== null) {
    const dependsOnText = match[1];
    // Extract task IDs like FND-001, PROJ-020, DASH-006, etc.
    const taskMatches = dependsOnText.match(/[A-Z]+-\d+/g);
    if (taskMatches) {
      taskMatches.forEach(id => taskIds.add(id));
    }
  }
  
  // Pattern 2: ### TASK- task headings
  const taskHeadingPattern = /### TASK-\d+/g;
  while ((match = taskHeadingPattern.exec(content)) !== null) {
    const taskId = match[0].replace('### ', '');
    taskIds.add(taskId);
  }
  
  // Pattern 3: **Parent Task ID**: lines
  const parentTaskPattern = /\*\*Parent Task ID\*\*:\s*([A-Z]+-\d+)/g;
  while ((match = parentTaskPattern.exec(content)) !== null) {
    taskIds.add(match[1]);
  }
  
  // Pattern 4: Task IDs in text like TASK-001-01 (subtasks)
  const subtaskPattern = /TASK-\d+-\d+/g;
  while ((match = subtaskPattern.exec(content)) !== null) {
    // Extract the parent task ID (e.g., TASK-001 from TASK-001-01)
    const parentTaskId = match[0].split('-').slice(0, 2).join('-');
    taskIds.add(parentTaskId);
  }
  
  return Array.from(taskIds);
}

/**
 * Build the canonical task registry from all markdown files
 */
function buildTaskRegistry(markdownFiles) {
  const registry = new Set();
  
  for (const file of markdownFiles) {
    const taskIds = extractTaskIdsFromFile(file);
    taskIds.forEach(id => registry.add(id));
  }
  
  return Array.from(registry).sort();
}

/**
 * Validate all Depends On references against the registry
 */
function validateTaskReferences(markdownFiles, registry) {
  const errors = [];
  const registrySet = new Set(registry);
  
  for (const file of markdownFiles) {
    const content = fs.readFileSync(file, 'utf-8');
    const relativePath = path.relative(process.cwd(), file);
    
    // Find all Depends On lines
    const dependsOnPattern = /Depends On:\s*([^\n]+)/g;
    let match;
    
    while ((match = dependsOnPattern.exec(content)) !== null) {
      const dependsOnText = match[1];
      const taskMatches = dependsOnText.match(/[A-Z]+-\d+/g);
      
      if (taskMatches) {
        for (const taskId of taskMatches) {
          if (!registrySet.has(taskId)) {
            errors.push({
              file: relativePath,
              invalidRef: taskId,
              context: dependsOnText.trim()
            });
          }
        }
      }
    }
  }
  
  return errors;
}

/**
 * Write task registry to JSON file
 */
function writeTaskRegistry(registry) {
  const docsDir = path.join(process.cwd(), 'docs');
  
  // Create docs directory if it doesn't exist
  if (!fs.existsSync(docsDir)) {
    fs.mkdirSync(docsDir, { recursive: true });
  }
  
  const registryPath = path.join(docsDir, 'task-registry.json');
  const registryData = {
    generatedAt: new Date().toISOString(),
    totalTaskIds: registry.length,
    taskIds: registry
  };
  
  fs.writeFileSync(registryPath, JSON.stringify(registryData, null, 2));
  console.log(`${colors.green}✓ Task registry written to docs/task-registry.json${colors.reset}`);
}

/**
 * Main execution
 */
function main() {
  console.log(`${colors.blue}Validating task references...${colors.reset}\n`);
  
  // Find all markdown files
  const markdownFiles = findMarkdownFiles(process.cwd());
  console.log(`Found ${markdownFiles.length} markdown files\n`);
  
  // Build task registry
  console.log(`${colors.blue}Building task registry...${colors.reset}`);
  const registry = buildTaskRegistry(markdownFiles);
  console.log(`Registry contains ${registry.length} unique task IDs\n`);
  
  // Write registry to JSON file
  writeTaskRegistry(registry);
  console.log();
  
  // Validate references
  console.log(`${colors.blue}Validating Depends On references...${colors.reset}`);
  const errors = validateTaskReferences(markdownFiles, registry);
  
  if (errors.length === 0) {
    console.log(`${colors.green}✓ All task references valid.${colors.reset}`);
    process.exit(0);
  } else {
    console.log(`${colors.red}✗ Found ${errors.length} invalid task reference(s):${colors.reset}\n`);
    
    for (const error of errors) {
      console.log(`${colors.yellow}  File:${colors.reset} ${error.file}`);
      console.log(`${colors.yellow}  Invalid Reference:${colors.reset} ${error.invalidRef}`);
      console.log(`${colors.yellow}  Context:${colors.reset} ${error.context}`);
      console.log();
    }
    
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  main();
}

module.exports = {
  findMarkdownFiles,
  extractTaskIdsFromFile,
  buildTaskRegistry,
  validateTaskReferences
};
