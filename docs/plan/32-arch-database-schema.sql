-- ============================================================================
-- AI Command Center - Complete Database Schema
-- ============================================================================
-- Source: Table definitions from 02-ARCH-DATABASE.md
-- Created: 2026-04-26
-- Status: Complete SQL DDL for all database tables
-- Database: PostgreSQL 15+ with TimescaleDB extension
-- ============================================================================

-- ============================================================================
-- Extensions
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pgvector;
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- ============================================================================
-- Foundation Tables
-- ============================================================================

-- Users Table
CREATE TABLE users (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT chk_users_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Albums Table
CREATE TABLE albums (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_albums_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE albums ENABLE ROW LEVEL SECURITY;

CREATE POLICY albums_org_policy ON albums
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_albums_org_id ON albums(org_id);
CREATE INDEX idx_albums_category ON albums(category);

-- ============================================================================
-- Core Application Tables
-- ============================================================================

-- Messages Table
CREATE TABLE messages (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    thread_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    content TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_messages_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_thread FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE CASCADE,
    CONSTRAINT fk_messages_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY messages_org_policy ON messages
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_messages_org_id ON messages(org_id);
CREATE INDEX idx_messages_thread_id ON messages(thread_id);
CREATE INDEX idx_messages_user_id ON messages(user_id);
CREATE INDEX idx_messages_updated_at ON messages(updated_at DESC);

-- Threads Table
CREATE TABLE threads (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'chat',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_threads_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE threads ENABLE ROW LEVEL SECURITY;

CREATE POLICY threads_org_policy ON threads
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_threads_org_id ON threads(org_id);
CREATE INDEX idx_threads_category ON threads(category);
CREATE INDEX idx_threads_updated_at ON threads(updated_at DESC);

-- Projects Table
CREATE TABLE projects (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    priority TEXT NOT NULL DEFAULT 'medium',
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    owner TEXT,
    client_email TEXT,
    tags TEXT[],
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_projects_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_projects_status CHECK (status IN ('active', 'completed', 'archived', 'on_hold')),
    CONSTRAINT chk_projects_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY projects_org_policy ON projects
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_projects_org_id ON projects(org_id);
CREATE INDEX idx_projects_status ON projects(status);
CREATE INDEX idx_projects_priority ON projects(priority);
CREATE INDEX idx_projects_owner ON projects(owner);
CREATE INDEX idx_projects_updated_at ON projects(updated_at DESC);

-- Tasks Table
CREATE TABLE tasks (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    project_id TEXT NOT NULL,
    parent_id TEXT,
    title TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'todo',
    assignee TEXT,
    due_date TIMESTAMP WITH TIME ZONE,
    estimated_time INTEGER,
    priority TEXT NOT NULL DEFAULT 'medium',
    "order" INTEGER NOT NULL DEFAULT 0,
    checklist JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_tasks_project FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_parent FOREIGN KEY (parent_id) REFERENCES tasks(id) ON DELETE CASCADE,
    CONSTRAINT chk_tasks_status CHECK (status IN ('todo', 'in_progress', 'completed', 'cancelled')),
    CONSTRAINT chk_tasks_priority CHECK (priority IN ('low', 'medium', 'high', 'critical'))
);

ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;

CREATE POLICY tasks_org_policy ON tasks
    FOR ALL TO authenticated_users
    USING (project_id IN (
        SELECT id FROM projects WHERE org_id = auth.jwt()->>'org_id'
    ));

CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_parent_id ON tasks(parent_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_assignee ON tasks(assignee);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_order ON tasks("order");
CREATE INDEX idx_tasks_updated_at ON tasks(updated_at DESC);

-- Events Table
CREATE TABLE events (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE NOT NULL,
    timezone TEXT NOT NULL DEFAULT 'UTC',
    all_day_flag BOOLEAN DEFAULT FALSE,
    recurrence_id TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_events_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_events_recurrence FOREIGN KEY (recurrence_id) REFERENCES recurrence_rules(id) ON DELETE SET NULL,
    CONSTRAINT chk_events_times CHECK (end_time >= start_time)
);

ALTER TABLE events ENABLE ROW LEVEL SECURITY;

CREATE POLICY events_org_policy ON events
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_events_org_id ON events(org_id);
CREATE INDEX idx_events_start_time ON events(start_time);
CREATE INDEX idx_events_end_time ON events(end_time);
CREATE INDEX idx_events_recurrence_id ON events(recurrence_id);
CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_updated_at ON events(updated_at DESC);

-- ============================================================================
-- Communication & Content Tables
-- ============================================================================

-- Emails Table
CREATE TABLE emails (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    account_id TEXT NOT NULL,
    nylas_id TEXT NOT NULL,
    subject TEXT NOT NULL,
    from_address TEXT NOT NULL,
    to_addresses TEXT[] NOT NULL,
    cc_addresses TEXT[],
    bcc_addresses TEXT[],
    body TEXT,
    attachments JSONB,
    direction TEXT NOT NULL DEFAULT 'inbound',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_emails_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_emails_account FOREIGN KEY (account_id) REFERENCES connected_accounts(id) ON DELETE CASCADE,
    CONSTRAINT chk_emails_direction CHECK (direction IN ('inbound', 'outbound', 'internal'))
);

ALTER TABLE emails ENABLE ROW LEVEL SECURITY;

CREATE POLICY emails_org_policy ON emails
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_emails_org_id ON emails(org_id);
CREATE INDEX idx_emails_account_id ON emails(account_id);
CREATE INDEX idx_emails_nylas_id ON emails(nylas_id);
CREATE INDEX idx_emails_from_address ON emails(from_address);
CREATE INDEX idx_emails_direction ON emails(direction);
CREATE INDEX idx_emails_updated_at ON emails(updated_at DESC);

-- Contacts Table
CREATE TABLE contacts (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    email TEXT,
    phone TEXT,
    company TEXT,
    privacy_settings JSONB,
    tags TEXT[],
    additional_data JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_contacts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_contacts_email UNIQUE(org_id, email) WHERE email IS NOT NULL
);

ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY contacts_org_policy ON contacts
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_contacts_org_id ON contacts(org_id);
CREATE INDEX idx_contacts_email ON contacts(email);
CREATE INDEX idx_contacts_name ON contacts(name);
CREATE INDEX idx_contacts_company ON contacts(company);
CREATE INDEX idx_contacts_tags ON contacts USING GIN(tags);
CREATE INDEX idx_contacts_updated_at ON contacts(updated_at DESC);

-- Documents Table
CREATE TABLE documents (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    size BIGINT NOT NULL,
    storage_path TEXT NOT NULL,
    is_trashed BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_documents_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_documents_size CHECK (size >= 0)
);

ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY documents_org_policy ON documents
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_documents_org_id ON documents(org_id);
CREATE INDEX idx_documents_type ON documents(type);
CREATE INDEX idx_documents_is_trashed ON documents(is_trashed);
CREATE INDEX idx_documents_category ON documents(category);
CREATE INDEX idx_documents_updated_at ON documents(updated_at DESC);

-- Media Table
CREATE TABLE media (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    url TEXT NOT NULL,
    alt_text TEXT,
    blurhash TEXT,
    album_id TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_media_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_media_album FOREIGN KEY (album_id) REFERENCES albums(id) ON DELETE SET NULL
);

ALTER TABLE media ENABLE ROW LEVEL SECURITY;

CREATE POLICY media_org_policy ON media
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_media_org_id ON media(org_id);
CREATE INDEX idx_media_type ON media(type);
CREATE INDEX idx_media_album_id ON media(album_id);
CREATE INDEX idx_media_category ON media(category);
CREATE INDEX idx_media_updated_at ON media(updated_at DESC);

-- ============================================================================
-- Financial & Planning Tables
-- ============================================================================

-- Transactions Table
CREATE TABLE transactions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    type TEXT NOT NULL DEFAULT 'expense',
    is_planned BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_transactions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_transactions_type CHECK (type IN ('income', 'expense', 'transfer'))
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY transactions_org_policy ON transactions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_transactions_org_id ON transactions(org_id);
CREATE INDEX idx_transactions_date ON transactions(date DESC);
CREATE INDEX idx_transactions_category ON transactions(category);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_is_planned ON transactions(is_planned);

-- Goals Table
CREATE TABLE goals (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    target_value DECIMAL(12,2) NOT NULL,
    current_value DECIMAL(12,2) DEFAULT 0,
    deadline DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_goals_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_goals_values CHECK (target_value >= 0 AND current_value >= 0)
);

ALTER TABLE goals ENABLE ROW LEVEL SECURITY;

CREATE POLICY goals_org_policy ON goals
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_goals_org_id ON goals(org_id);
CREATE INDEX idx_goals_deadline ON goals(deadline);
CREATE INDEX idx_goals_category ON goals(category);
CREATE INDEX idx_goals_updated_at ON goals(updated_at DESC);

-- ============================================================================
-- Research & Learning Tables
-- ============================================================================

-- Research Notebooks Table
CREATE TABLE research_notebooks (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_research_notebooks_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE research_notebooks ENABLE ROW LEVEL SECURITY;

CREATE POLICY research_notebooks_org_policy ON research_notebooks
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_research_notebooks_org_id ON research_notebooks(org_id);
CREATE INDEX idx_research_notebooks_category ON research_notebooks(category);
CREATE INDEX idx_research_notebooks_updated_at ON research_notebooks(updated_at DESC);

-- Flashcards Table
CREATE TABLE flashcards (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    front_content TEXT NOT NULL,
    back_content TEXT NOT NULL,
    deck_name TEXT NOT NULL,
    fsrs_state JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_flashcards_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

CREATE POLICY flashcards_org_policy ON flashcards
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_flashcards_org_id ON flashcards(org_id);
CREATE INDEX idx_flashcards_deck_name ON flashcards(deck_name);
CREATE INDEX idx_flashcards_category ON flashcards(category);
CREATE INDEX idx_flashcards_updated_at ON flashcards(updated_at DESC);

-- ============================================================================
-- Collaboration & Communication Tables
-- ============================================================================

-- Conference Rooms Table
CREATE TABLE conference_rooms (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    livekit_room_id TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_conference_rooms_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_conference_rooms_livekit UNIQUE(livekit_room_id)
);

ALTER TABLE conference_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY conference_rooms_org_policy ON conference_rooms
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_conference_rooms_org_id ON conference_rooms(org_id);
CREATE INDEX idx_conference_rooms_livekit_room_id ON conference_rooms(livekit_room_id);
CREATE INDEX idx_conference_rooms_category ON conference_rooms(category);

-- Translation Sessions Table
CREATE TABLE translation_sessions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    source_language TEXT NOT NULL,
    target_language TEXT NOT NULL,
    speakers JSONB,
    segments JSONB,
    status TEXT NOT NULL DEFAULT 'pending',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_translation_sessions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_translation_sessions_status CHECK (status IN ('pending', 'in_progress', 'completed', 'failed'))
);

ALTER TABLE translation_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY translation_sessions_org_policy ON translation_sessions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_translation_sessions_org_id ON translation_sessions(org_id);
CREATE INDEX idx_translation_sessions_status ON translation_sessions(status);
CREATE INDEX idx_translation_sessions_source_language ON translation_sessions(source_language);
CREATE INDEX idx_translation_sessions_target_language ON translation_sessions(target_language);

-- News Articles Table
CREATE TABLE news_articles (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    url TEXT NOT NULL,
    title TEXT NOT NULL,
    source TEXT NOT NULL,
    sentiment TEXT,
    summary TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_news_articles_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_news_articles_url UNIQUE(url)
);

ALTER TABLE news_articles ENABLE ROW LEVEL SECURITY;

CREATE POLICY news_articles_org_policy ON news_articles
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_news_articles_org_id ON news_articles(org_id);
CREATE INDEX idx_news_articles_source ON news_articles(source);
CREATE INDEX idx_news_articles_sentiment ON news_articles(sentiment);
CREATE INDEX idx_news_articles_category ON news_articles(category);
CREATE INDEX idx_news_articles_updated_at ON news_articles(updated_at DESC);

-- ============================================================================
-- System & Administration Tables
-- ============================================================================

-- Workflow Executions Table
CREATE TABLE workflow_executions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    workflow_id TEXT NOT NULL,
    step_id TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    input_data JSONB,
    output_data JSONB,
    started_at TIMESTAMP WITH TIME ZONE,
    finished_at TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    actor_id TEXT NOT NULL,
    idempotency_key TEXT NOT NULL,

    CONSTRAINT fk_workflow_executions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_executions_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_workflow_executions_status CHECK (status IN ('pending', 'running', 'completed', 'failed', 'cancelled')),
    CONSTRAINT uq_workflow_executions_idempotency UNIQUE (actor_id, idempotency_key)
);

ALTER TABLE workflow_executions ENABLE ROW LEVEL SECURITY;

CREATE POLICY workflow_executions_org_policy ON workflow_executions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_workflow_executions_org_id ON workflow_executions(org_id);
CREATE INDEX idx_workflow_executions_workflow_id ON workflow_executions(workflow_id);
CREATE INDEX idx_workflow_executions_step_id ON workflow_executions(step_id);
CREATE INDEX idx_workflow_executions_status ON workflow_executions(status);
CREATE INDEX idx_workflow_executions_started_at ON workflow_executions(started_at DESC);
CREATE INDEX idx_workflow_executions_actor_id ON workflow_executions(actor_id);

-- Audit Logs Table
CREATE TABLE audit_logs (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    actor_id TEXT,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    old_value JSONB,
    new_value JSONB,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY audit_logs_org_policy ON audit_logs
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_audit_logs_org_id ON audit_logs(org_id);
CREATE INDEX idx_audit_logs_actor_id ON audit_logs(actor_id);
CREATE INDEX idx_audit_logs_action ON audit_logs(action);
CREATE INDEX idx_audit_logs_entity_type ON audit_logs(entity_type);
CREATE INDEX idx_audit_logs_entity_id ON audit_logs(entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at DESC);

-- Notification Preferences Table
CREATE TABLE notification_preferences (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    channels JSONB NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_notification_preferences_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_notification_preferences_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_notification_preferences_user UNIQUE(org_id, user_id)
);

ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

CREATE POLICY notification_preferences_org_policy ON notification_preferences
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_notification_preferences_org_id ON notification_preferences(org_id);
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);

-- ============================================================================
-- Multi-Tenant Foundation Tables
-- ============================================================================

-- Organization Members Table
CREATE TABLE organization_members (
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    role_id TEXT,
    joined_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (org_id, user_id),
    CONSTRAINT fk_org_members_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_org_members_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_org_members_role FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE SET NULL
);

ALTER TABLE organization_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY organization_members_policy ON organization_members
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id' AND user_id = auth.jwt()->>'user_id');

CREATE INDEX idx_organization_members_org_id ON organization_members(org_id);
CREATE INDEX idx_organization_members_user_id ON organization_members(user_id);
CREATE INDEX idx_organization_members_role_id ON organization_members(role_id);

-- Connected Accounts Table
CREATE TABLE connected_accounts (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    provider TEXT NOT NULL,
    grant_id TEXT,
    access_token TEXT,
    expires_at TIMESTAMP WITH TIME ZONE,
    grant_status TEXT NOT NULL DEFAULT 'active',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_connected_accounts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_connected_accounts_status CHECK (grant_status IN ('active', 'expired', 'revoked'))
);

ALTER TABLE connected_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY connected_accounts_org_policy ON connected_accounts
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_connected_accounts_org_id ON connected_accounts(org_id);
CREATE INDEX idx_connected_accounts_provider ON connected_accounts(provider);
CREATE INDEX idx_connected_accounts_grant_status ON connected_accounts(grant_status);
CREATE INDEX idx_connected_accounts_expires_at ON connected_accounts(expires_at);

-- Organizations Table
CREATE TABLE organizations (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    slug TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    plan TEXT NOT NULL DEFAULT 'free',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    allow_training_flag BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_organizations_plan CHECK (plan IN ('free', 'pro', 'enterprise'))
);

CREATE INDEX idx_organizations_slug ON organizations(slug);
CREATE INDEX idx_organizations_plan ON organizations(plan);
CREATE INDEX idx_organizations_created_at ON organizations(created_at DESC);

-- Feature Flags Table
CREATE TABLE feature_flags (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    flag_name TEXT NOT NULL,
    percentage DECIMAL(5,2) DEFAULT 0.0,
    enabled BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_feature_flags_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_feature_flags_org_name UNIQUE(org_id, flag_name),
    CONSTRAINT chk_feature_flags_percentage CHECK (percentage >= 0.0 AND percentage <= 100.0)
);

ALTER TABLE feature_flags ENABLE ROW LEVEL SECURITY;

CREATE POLICY feature_flags_org_policy ON feature_flags
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_feature_flags_org_id ON feature_flags(org_id);
CREATE INDEX idx_feature_flags_flag_name ON feature_flags(flag_name);
CREATE INDEX idx_feature_flags_enabled ON feature_flags(enabled);

-- Notifications Table
CREATE TABLE notifications (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    template TEXT NOT NULL,
    deeplink TEXT,
    read_status BOOLEAN DEFAULT FALSE,
    unsubscribed BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_notifications_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY notifications_org_policy ON notifications
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_notifications_org_id ON notifications(org_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_read_status ON notifications(read_status);
CREATE INDEX idx_notifications_unsubscribed ON notifications(unsubscribed);
CREATE INDEX idx_notifications_updated_at ON notifications(updated_at DESC);

-- ============================================================================
-- Role-Based Access Control Tables
-- ============================================================================

-- User Roles Table
CREATE TABLE user_roles (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    permissions JSONB NOT NULL DEFAULT '{}',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_user_roles_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_user_roles_org_name UNIQUE(org_id, name),
    CONSTRAINT chk_user_roles_name CHECK (name IN ('admin', 'manager', 'member', 'viewer', 'external'))
);

ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_roles_org_policy ON user_roles
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_user_roles_org_id ON user_roles(org_id);
CREATE INDEX idx_user_roles_name ON user_roles(name);

-- Role Permissions Table
CREATE TABLE role_permissions (
    role_id TEXT NOT NULL,
    resource TEXT NOT NULL,
    action TEXT NOT NULL,

    PRIMARY KEY (role_id, resource, action),
    CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES user_roles(id) ON DELETE CASCADE
);

ALTER TABLE role_permissions ENABLE ROW LEVEL SECURITY;

CREATE POLICY role_permissions_org_policy ON role_permissions
    FOR ALL TO authenticated_users
    USING (role_id IN (
        SELECT id FROM user_roles WHERE org_id = auth.jwt()->>'org_id'
    ));

CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_resource ON role_permissions(resource);
CREATE INDEX idx_role_permissions_action ON role_permissions(action);

-- ============================================================================
-- AI & Agent Tables
-- ============================================================================

-- Agent Definitions Table
CREATE TABLE agent_definitions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    tools JSONB NOT NULL DEFAULT '[]',
    configuration JSONB NOT NULL DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 1,
    is_public BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_agent_definitions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_agent_definitions_org_name_version UNIQUE(org_id, name, version)
);

ALTER TABLE agent_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY agent_definitions_org_policy ON agent_definitions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_agent_definitions_org_id ON agent_definitions(org_id);
CREATE INDEX idx_agent_definitions_name ON agent_definitions(name);
CREATE INDEX idx_agent_definitions_version ON agent_definitions(version);
CREATE INDEX idx_agent_definitions_is_public ON agent_definitions(is_public);
CREATE INDEX idx_agent_definitions_updated_at ON agent_definitions(updated_at DESC);

-- Recurrence Rules Table
CREATE TABLE recurrence_rules (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    rrule TEXT NOT NULL,
    start_timezone TEXT NOT NULL DEFAULT 'UTC',
    exception_dates TEXT[],
    overrides JSONB DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_recurrence_rules_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_recurrence_rules_entity_type CHECK (entity_type IN ('event', 'task', 'reminder'))
);

ALTER TABLE recurrence_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY recurrence_rules_org_policy ON recurrence_rules
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_recurrence_rules_org_id ON recurrence_rules(org_id);
CREATE INDEX idx_recurrence_rules_entity_id ON recurrence_rules(entity_id);
CREATE INDEX idx_recurrence_rules_entity_type ON recurrence_rules(entity_type);
CREATE INDEX idx_recurrence_rules_updated_at ON recurrence_rules(updated_at DESC);

-- AI Cost Log Table
CREATE TABLE ai_cost_log (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    request_id TEXT NOT NULL,
    model TEXT NOT NULL,
    tokens_in INTEGER NOT NULL DEFAULT 0,
    tokens_out INTEGER NOT NULL DEFAULT 0,
    cost DECIMAL(10,6) NOT NULL DEFAULT 0.000000,
    caller TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ai_cost_log_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_ai_cost_log_tokens CHECK (tokens_in >= 0 AND tokens_out >= 0),
    CONSTRAINT chk_ai_cost_log_cost CHECK (cost >= 0)
);

ALTER TABLE ai_cost_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY ai_cost_log_org_policy ON ai_cost_log
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

SELECT create_hypertable('ai_cost_log', 'created_at', chunk_time_interval => INTERVAL '1 day');

CREATE INDEX idx_ai_cost_log_org_id ON ai_cost_log(org_id);
CREATE INDEX idx_ai_cost_log_request_id ON ai_cost_log(request_id);
CREATE INDEX idx_ai_cost_log_model ON ai_cost_log(model);
CREATE INDEX idx_ai_cost_log_caller ON ai_cost_log(caller);
CREATE INDEX idx_ai_cost_log_created_at ON ai_cost_log(created_at DESC);

-- Prompt Versions Table
CREATE TABLE prompt_versions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    prompt_id TEXT NOT NULL,
    template TEXT NOT NULL,
    variables JSONB DEFAULT '{}',
    version INTEGER NOT NULL DEFAULT 1,
    is_production BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_prompt_versions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT uq_prompt_versions_org_prompt_version UNIQUE(org_id, prompt_id, version)
);

ALTER TABLE prompt_versions ENABLE ROW LEVEL SECURITY;

CREATE POLICY prompt_versions_org_policy ON prompt_versions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_prompt_versions_org_id ON prompt_versions(org_id);
CREATE INDEX idx_prompt_versions_prompt_id ON prompt_versions(prompt_id);
CREATE INDEX idx_prompt_versions_version ON prompt_versions(version);
CREATE INDEX idx_prompt_versions_is_production ON prompt_versions(is_production);
CREATE INDEX idx_prompt_versions_updated_at ON prompt_versions(updated_at DESC);

-- Evaluation Datasets Table
CREATE TABLE evaluation_datasets (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    test_cases JSONB NOT NULL DEFAULT '[]',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_evaluation_datasets_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE evaluation_datasets ENABLE ROW LEVEL SECURITY;

CREATE POLICY evaluation_datasets_org_policy ON evaluation_datasets
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_evaluation_datasets_org_id ON evaluation_datasets(org_id);
CREATE INDEX idx_evaluation_datasets_name ON evaluation_datasets(name);
CREATE INDEX idx_evaluation_datasets_updated_at ON evaluation_datasets(updated_at DESC);

-- Evaluation Runs Table
CREATE TABLE evaluation_runs (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    dataset_id TEXT NOT NULL,
    prompt_version_id TEXT NOT NULL,
    metrics JSONB NOT NULL DEFAULT '{}',
    passed BOOLEAN NOT NULL DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_evaluation_runs_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_runs_dataset FOREIGN KEY (dataset_id) REFERENCES evaluation_datasets(id) ON DELETE CASCADE,
    CONSTRAINT fk_evaluation_runs_prompt_version FOREIGN KEY (prompt_version_id) REFERENCES prompt_versions(id) ON DELETE CASCADE
);

ALTER TABLE evaluation_runs ENABLE ROW LEVEL SECURITY;

CREATE POLICY evaluation_runs_org_policy ON evaluation_runs
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_evaluation_runs_org_id ON evaluation_runs(org_id);
CREATE INDEX idx_evaluation_runs_dataset_id ON evaluation_runs(dataset_id);
CREATE INDEX idx_evaluation_runs_prompt_version_id ON evaluation_runs(prompt_version_id);
CREATE INDEX idx_evaluation_runs_passed ON evaluation_runs(passed);
CREATE INDEX idx_evaluation_runs_updated_at ON evaluation_runs(updated_at DESC);

-- ============================================================================
-- GraphRAG & Analytics Tables
-- ============================================================================

-- Graph Entities Table
CREATE TABLE graph_entities (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    name TEXT NOT NULL,
    type TEXT NOT NULL,
    description TEXT,
    embedding vector(1536),
    source_count INTEGER DEFAULT 0,
    trust_score DECIMAL(3,2) DEFAULT 0.0,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_graph_entities_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_graph_entities_trust_score CHECK (trust_score >= 0.0 AND trust_score <= 1.0)
);

ALTER TABLE graph_entities ENABLE ROW LEVEL SECURITY;

CREATE POLICY graph_entities_org_policy ON graph_entities
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_graph_entities_org_id ON graph_entities(org_id);
CREATE INDEX idx_graph_entities_name ON graph_entities(name);
CREATE INDEX idx_graph_entities_type ON graph_entities(type);
CREATE INDEX idx_graph_entities_trust_score ON graph_entities(trust_score DESC);
CREATE INDEX idx_graph_entities_embedding ON graph_entities USING ivfflat (embedding vector_cosine_ops);

-- Graph Relationships Table
CREATE TABLE graph_relationships (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    source_id TEXT NOT NULL,
    target_id TEXT NOT NULL,
    relationship_type TEXT NOT NULL,
    weight DECIMAL(3,2) DEFAULT 1.0,
    community TEXT,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_graph_relationships_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_graph_relationships_source FOREIGN KEY (source_id) REFERENCES graph_entities(id) ON DELETE CASCADE,
    CONSTRAINT fk_graph_relationships_target FOREIGN KEY (target_id) REFERENCES graph_entities(id) ON DELETE CASCADE,
    CONSTRAINT chk_graph_relationships_weight CHECK (weight >= 0.0)
);

ALTER TABLE graph_relationships ENABLE ROW LEVEL SECURITY;

CREATE POLICY graph_relationships_org_policy ON graph_relationships
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_graph_relationships_org_id ON graph_relationships(org_id);
CREATE INDEX idx_graph_relationships_source_id ON graph_relationships(source_id);
CREATE INDEX idx_graph_relationships_target_id ON graph_relationships(target_id);
CREATE INDEX idx_graph_relationships_relationship_type ON graph_relationships(relationship_type);
CREATE INDEX idx_graph_relationships_weight ON graph_relationships(weight DESC);
CREATE INDEX idx_graph_relationships_community ON graph_relationships(community);

-- RAG Index Statistics Table
CREATE TABLE rag_index_statistics (
    org_id TEXT PRIMARY KEY,
    chunk_count BIGINT DEFAULT 0,
    index_type TEXT NOT NULL DEFAULT 'vector',
    contextual_retrieval_activated BOOLEAN DEFAULT FALSE,
    graphrag_active BOOLEAN DEFAULT FALSE,
    last_indexed TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_rag_index_statistics_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE rag_index_statistics ENABLE ROW LEVEL SECURITY;

CREATE POLICY rag_index_statistics_org_policy ON rag_index_statistics
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_rag_index_statistics_org_id ON rag_index_statistics(org_id);
CREATE INDEX idx_rag_index_statistics_index_type ON rag_index_statistics(index_type);
CREATE INDEX idx_rag_index_statistics_last_indexed ON rag_index_statistics(last_indexed DESC);

-- WebAuthn Challenges Table
CREATE TABLE webauthn_challenges (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    user_id TEXT NOT NULL,
    challenge TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'passkey',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_webauthn_challenges_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_webauthn_challenges_expires CHECK (expires_at > created_at)
);

CREATE INDEX idx_webauthn_challenges_user_id ON webauthn_challenges(user_id);
CREATE INDEX idx_webauthn_challenges_expires_at ON webauthn_challenges(expires_at);
CREATE INDEX idx_webauthn_challenges_challenge ON webauthn_challenges(challenge);

-- Secret Rotation Log Table
CREATE TABLE secret_rotation_log (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    secret_name TEXT NOT NULL,
    rotated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    method TEXT NOT NULL,
    success BOOLEAN NOT NULL,
    evidence TEXT,

    CONSTRAINT chk_secret_rotation_log_method CHECK (method IN ('manual', 'automated', 'emergency'))
);

CREATE INDEX idx_secret_rotation_log_secret_name ON secret_rotation_log(secret_name);
CREATE INDEX idx_secret_rotation_log_rotated_at ON secret_rotation_log(rotated_at DESC);
CREATE INDEX idx_secret_rotation_log_success ON secret_rotation_log(success);

-- PostHog Event Taxonomy Table
CREATE TABLE posthog_event_taxonomy (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    event_name TEXT NOT NULL UNIQUE,
    required_properties JSONB NOT NULL DEFAULT '{}',
    owner TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_posthog_event_taxonomy_event_name ON posthog_event_taxonomy(event_name);
CREATE INDEX idx_posthog_event_taxonomy_owner ON posthog_event_taxonomy(owner);
CREATE INDEX idx_posthog_event_taxonomy_category ON posthog_event_taxonomy(category);

-- Feature Flag Evidence Table
CREATE TABLE feature_flag_evidence (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    flag_id TEXT NOT NULL,
    owner TEXT NOT NULL,
    default_behavior TEXT,
    review_date DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_feature_flag_evidence_flag FOREIGN KEY (flag_id) REFERENCES feature_flags(id) ON DELETE CASCADE
);

ALTER TABLE feature_flag_evidence ENABLE ROW LEVEL SECURITY;

CREATE POLICY feature_flag_evidence_org_policy ON feature_flag_evidence
    FOR ALL TO authenticated_users
    USING (flag_id IN (
        SELECT id FROM feature_flags WHERE org_id = auth.jwt()->>'org_id'
    ));

CREATE INDEX idx_feature_flag_evidence_flag_id ON feature_flag_evidence(flag_id);
CREATE INDEX idx_feature_flag_evidence_owner ON feature_flag_evidence(owner);
CREATE INDEX idx_feature_flag_evidence_review_date ON feature_flag_evidence(review_date DESC);

-- ============================================================================
-- Database Triggers and Functions
-- ============================================================================

-- Updated At Trigger Function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables that need it
CREATE TRIGGER update_messages_updated_at BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_threads_updated_at BEFORE UPDATE ON threads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_emails_updated_at BEFORE UPDATE ON emails
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contacts_updated_at BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_documents_updated_at BEFORE UPDATE ON documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_media_updated_at BEFORE UPDATE ON media
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_goals_updated_at BEFORE UPDATE ON goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_research_notebooks_updated_at BEFORE UPDATE ON research_notebooks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_flashcards_updated_at BEFORE UPDATE ON flashcards
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_conference_rooms_updated_at BEFORE UPDATE ON conference_rooms
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_translation_sessions_updated_at BEFORE UPDATE ON translation_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_news_articles_updated_at BEFORE UPDATE ON news_articles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workflow_executions_updated_at BEFORE UPDATE ON workflow_executions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_connected_accounts_updated_at BEFORE UPDATE ON connected_accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_organizations_updated_at BEFORE UPDATE ON organizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flags_updated_at BEFORE UPDATE ON feature_flags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_roles_updated_at BEFORE UPDATE ON user_roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_agent_definitions_updated_at BEFORE UPDATE ON agent_definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurrence_rules_updated_at BEFORE UPDATE ON recurrence_rules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_prompt_versions_updated_at BEFORE UPDATE ON prompt_versions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_datasets_updated_at BEFORE UPDATE ON evaluation_datasets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_evaluation_runs_updated_at BEFORE UPDATE ON evaluation_runs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_graph_entities_updated_at BEFORE UPDATE ON graph_entities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_graph_relationships_updated_at BEFORE UPDATE ON graph_relationships
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rag_index_statistics_updated_at BEFORE UPDATE ON rag_index_statistics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posthog_event_taxonomy_updated_at BEFORE UPDATE ON posthog_event_taxonomy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flag_evidence_updated_at BEFORE UPDATE ON feature_flag_evidence
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_albums_updated_at BEFORE UPDATE ON albums
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- Monitoring & Cross-Cutting Service Tables
-- ============================================================================

-- Specification Metadata Table
CREATE TABLE specification_metadata (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    component_name TEXT NOT NULL UNIQUE,
    tier INTEGER NOT NULL CHECK (tier IN (1, 2, 3)),
    status TEXT NOT NULL DEFAULT 'draft',
    frontmatter JSONB NOT NULL DEFAULT '{}',
    sections_required TEXT[] NOT NULL DEFAULT '{}',
    authors TEXT[] NOT NULL DEFAULT '{}',
    dependencies TEXT[] NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_specification_metadata_status CHECK (status IN ('draft', 'review', 'approved', 'deprecated'))
);

CREATE INDEX idx_specification_metadata_component_name ON specification_metadata(component_name);
CREATE INDEX idx_specification_metadata_tier ON specification_metadata(tier);
CREATE INDEX idx_specification_metadata_status ON specification_metadata(status);
CREATE INDEX idx_specification_metadata_updated_at ON specification_metadata(updated_at DESC);

-- Realtime Channel Monitoring Table
CREATE TABLE realtime_channel_monitoring (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    channel_name TEXT NOT NULL,
    subscriber_count INTEGER DEFAULT 0,
    memory_mb DECIMAL(10,2) DEFAULT 0.0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_activity TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',

    CONSTRAINT fk_realtime_monitoring_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE realtime_channel_monitoring ENABLE ROW LEVEL SECURITY;

CREATE POLICY realtime_channel_monitoring_org_policy ON realtime_channel_monitoring
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_realtime_channel_monitoring_org_id ON realtime_channel_monitoring(org_id);
CREATE INDEX idx_realtime_channel_monitoring_channel_name ON realtime_channel_monitoring(channel_name);
CREATE INDEX idx_realtime_channel_monitoring_last_activity ON realtime_channel_monitoring(last_activity DESC);

-- Offline Operations Queue Table
CREATE TABLE offline_operations_queue (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    actor_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    idempotency_key TEXT NOT NULL,
    tombstone BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_offline_queue_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_offline_queue_actor FOREIGN KEY (actor_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_offline_queue_idempotency UNIQUE (actor_id, idempotency_key)
);

ALTER TABLE offline_operations_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY offline_operations_queue_org_policy ON offline_operations_queue
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_offline_operations_queue_org_id ON offline_operations_queue(org_id);
CREATE INDEX idx_offline_operations_queue_actor_id ON offline_operations_queue(actor_id);
CREATE INDEX idx_offline_operations_queue_entity_id ON offline_operations_queue(entity_id);
CREATE INDEX idx_offline_operations_queue_operation ON offline_operations_queue(operation);
CREATE INDEX idx_offline_operations_queue_created_at ON offline_operations_queue(created_at DESC);

-- Workflow State Audit Table
CREATE TABLE workflow_state_audit (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    workflow_id TEXT NOT NULL,
    step_id TEXT NOT NULL,
    state TEXT NOT NULL,
    transition_reason TEXT,
    guard_evaluated BOOLEAN DEFAULT FALSE,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_workflow_state_audit_workflow FOREIGN KEY (workflow_id) REFERENCES workflow_executions(id) ON DELETE CASCADE,
    CONSTRAINT fk_workflow_state_audit_step FOREIGN KEY (step_id) REFERENCES workflow_executions(id) ON DELETE CASCADE
);

CREATE INDEX idx_workflow_state_audit_workflow_id ON workflow_state_audit(workflow_id);
CREATE INDEX idx_workflow_state_audit_step_id ON workflow_state_audit(step_id);
CREATE INDEX idx_workflow_state_audit_state ON workflow_state_audit(state);
CREATE INDEX idx_workflow_state_audit_timestamp ON workflow_state_audit(timestamp DESC);

-- Webhook Deduplication Table
CREATE TABLE webhook_deduplication (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    provider TEXT NOT NULL,
    provider_event_id TEXT NOT NULL,
    processed_status TEXT NOT NULL DEFAULT 'pending',
    deduplication_key TEXT NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_webhook_deduplication_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_webhook_deduplication_status CHECK (processed_status IN ('pending', 'processed', 'failed'))
);

ALTER TABLE webhook_deduplication ENABLE ROW LEVEL SECURITY;

CREATE POLICY webhook_deduplication_org_policy ON webhook_deduplication
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_webhook_deduplication_org_id ON webhook_deduplication(org_id);
CREATE INDEX idx_webhook_deduplication_provider ON webhook_deduplication(provider);
CREATE INDEX idx_webhook_deduplication_processed_status ON webhook_deduplication(processed_status);
CREATE INDEX idx_webhook_deduplication_created_at ON webhook_deduplication(created_at DESC);

-- Test Coverage Targets Table
CREATE TABLE test_coverage_targets (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    module TEXT NOT NULL UNIQUE,
    unit_target DECIMAL(3,2) NOT NULL DEFAULT 0.80,
    component_target DECIMAL(3,2) NOT NULL DEFAULT 0.85,
    integration_target DECIMAL(3,2) NOT NULL DEFAULT 0.70,
    e2e_flows_target INTEGER NOT NULL DEFAULT 10,
    a11y_critical_target INTEGER NOT NULL DEFAULT 0,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_test_coverage_targets CHECK (
        unit_target >= 0.0 AND unit_target <= 1.0 AND
        component_target >= 0.0 AND component_target <= 1.0 AND
        integration_target >= 0.0 AND integration_target <= 1.0
    )
);

CREATE INDEX idx_test_coverage_targets_module ON test_coverage_targets(module);

-- Incident Management Table
CREATE TABLE incident_management (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    severity TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    roles TEXT[] NOT NULL DEFAULT '{}',
    slo_impact BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP WITH TIME ZONE,

    CONSTRAINT fk_incident_management_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_incident_management_severity CHECK (severity IN ('P0', 'P1', 'P2', 'P3')),
    CONSTRAINT chk_incident_management_status CHECK (status IN ('open', 'investigating', 'mitigated', 'resolved', 'closed'))
);

ALTER TABLE incident_management ENABLE ROW LEVEL SECURITY;

CREATE POLICY incident_management_org_policy ON incident_management
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_incident_management_org_id ON incident_management(org_id);
CREATE INDEX idx_incident_management_severity ON incident_management(severity);
CREATE INDEX idx_incident_management_status ON incident_management(status);
CREATE INDEX idx_incident_management_created_at ON incident_management(created_at DESC);

-- Feature Flag Registry Table
CREATE TABLE feature_flag_registry (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    flag_name TEXT NOT NULL,
    description TEXT,
    owner TEXT NOT NULL,
    default_behavior TEXT NOT NULL DEFAULT 'disabled',
    targeting_rules JSONB NOT NULL DEFAULT '{}',
    current_stage TEXT NOT NULL DEFAULT 'development',
    cohort_hash TEXT,
    review_date DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_feature_flag_registry_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_feature_flag_registry_stage CHECK (current_stage IN ('development', 'testing', 'staging', 'production', 'deprecated'))
);

ALTER TABLE feature_flag_registry ENABLE ROW LEVEL SECURITY;

CREATE POLICY feature_flag_registry_org_policy ON feature_flag_registry
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_feature_flag_registry_org_id ON feature_flag_registry(org_id);
CREATE INDEX idx_feature_flag_registry_flag_name ON feature_flag_registry(flag_name);
CREATE INDEX idx_feature_flag_registry_current_stage ON feature_flag_registry(current_stage);
CREATE INDEX idx_feature_flag_registry_review_date ON feature_flag_registry(review_date DESC);

-- Cost Budgets Table
CREATE TABLE cost_budgets (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    scope_id TEXT NOT NULL,
    level TEXT NOT NULL,
    monthly_limit DECIMAL(12,2) NOT NULL,
    current_usage DECIMAL(12,2) DEFAULT 0.0,
    alert_15_percent BOOLEAN DEFAULT FALSE,
    alert_5_percent BOOLEAN DEFAULT FALSE,
    alert_0_percent BOOLEAN DEFAULT FALSE,
    hard_cap BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_cost_budgets_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_cost_budgets_level CHECK (level IN ('org', 'team', 'user', 'model'))
);

ALTER TABLE cost_budgets ENABLE ROW LEVEL SECURITY;

CREATE POLICY cost_budgets_org_policy ON cost_budgets
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_cost_budgets_org_id ON cost_budgets(org_id);
CREATE INDEX idx_cost_budgets_scope_id ON cost_budgets(scope_id);
CREATE INDEX idx_cost_budgets_level ON cost_budgets(level);

-- SLO Definitions Table
CREATE TABLE slo_definitions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    service_id TEXT NOT NULL,
    metric TEXT NOT NULL,
    target DECIMAL(5,4) NOT NULL,
    window TEXT NOT NULL,
    current_value DECIMAL(5,4),
    error_budget_remaining DECIMAL(5,4),
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_slo_definitions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_slo_definitions_target CHECK (target >= 0.0 AND target <= 1.0)
);

ALTER TABLE slo_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY slo_definitions_org_policy ON slo_definitions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_slo_definitions_org_id ON slo_definitions(org_id);
CREATE INDEX idx_slo_definitions_service_id ON slo_definitions(service_id);
CREATE INDEX idx_slo_definitions_metric ON slo_definitions(metric);

-- Security Control Mappings Table
CREATE TABLE security_control_mappings (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    rule_id TEXT NOT NULL CHECK (rule_id ~ '^S[0-9]+$'),
    control_description TEXT NOT NULL,
    mechanism TEXT NOT NULL,
    test_method TEXT NOT NULL,
    owner TEXT NOT NULL,
    evidence TEXT,
    last_verified DATE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_security_control_mappings_rule_id ON security_control_mappings(rule_id);
CREATE INDEX idx_security_control_mappings_owner ON security_control_mappings(owner);
CREATE INDEX idx_security_control_mappings_last_verified ON security_control_mappings(last_verified DESC);

-- ============================================================================
-- Security & Compliance Tables
-- ============================================================================

-- MCP Tool Authorizations Table
CREATE TABLE mcp_tool_authorizations (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    tool_name TEXT NOT NULL,
    auth_method TEXT NOT NULL DEFAULT 'oauth',
    scope TEXT NOT NULL DEFAULT '{}',
    allowlist_schema JSONB NOT NULL DEFAULT '{}',
    elicitation_required BOOLEAN DEFAULT FALSE,
    approved_by TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_mcp_tool_authorizations_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_mcp_tool_authorizations_auth_method CHECK (auth_method IN ('oauth', 'api_key', 'none'))
);

ALTER TABLE mcp_tool_authorizations ENABLE ROW LEVEL SECURITY;

CREATE POLICY mcp_tool_authorizations_org_policy ON mcp_tool_authorizations
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_mcp_tool_authorizations_org_id ON mcp_tool_authorizations(org_id);
CREATE INDEX idx_mcp_tool_authorizations_tool_name ON mcp_tool_authorizations(tool_name);

-- Passkeys Table
CREATE TABLE passkeys (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    credential_id TEXT NOT NULL UNIQUE,
    authenticator_type TEXT NOT NULL,
    recovery_codes TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_used TIMESTAMP WITH TIME ZONE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_passkeys_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_passkeys_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_passkeys_authenticator_type CHECK (authenticator_type IN ('platform', 'cross-platform', 'security-key'))
);

ALTER TABLE passkeys ENABLE ROW LEVEL SECURITY;

CREATE POLICY passkeys_org_policy ON passkeys
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_passkeys_org_id ON passkeys(org_id);
CREATE INDEX idx_passkeys_user_id ON passkeys(user_id);
CREATE INDEX idx_passkeys_credential_id ON passkeys(credential_id);

-- Guardrails Audit Logs Table
CREATE TABLE guardrails_audit_logs (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    layer TEXT NOT NULL,
    decision TEXT NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_guardrails_audit_logs_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_guardrails_audit_logs_layer CHECK (layer IN ('input', 'output', 'runtime')),
    CONSTRAINT chk_guardrails_audit_logs_decision CHECK (decision IN ('allow', 'block', 'warn'))
);

ALTER TABLE guardrails_audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY guardrails_audit_logs_org_policy ON guardrails_audit_logs
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_guardrails_audit_logs_org_id ON guardrails_audit_logs(org_id);
CREATE INDEX idx_guardrails_audit_logs_layer ON guardrails_audit_logs(layer);
CREATE INDEX idx_guardrails_audit_logs_decision ON guardrails_audit_logs(decision);
CREATE INDEX idx_guardrails_audit_logs_timestamp ON guardrails_audit_logs(timestamp DESC);

-- SSRF Allowlists Table
CREATE TABLE ssrf_allowlists (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    allowed_domain TEXT NOT NULL,
    allowed_ip_range TEXT,
    validation_method TEXT NOT NULL DEFAULT 'exact',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ssrf_allowlists_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_ssrf_allowlists_validation_method CHECK (validation_method IN ('exact', 'regex', 'cidr'))
);

ALTER TABLE ssrf_allowlists ENABLE ROW LEVEL SECURITY;

CREATE POLICY ssrf_allowlists_org_policy ON ssrf_allowlists
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_ssrf_allowlists_org_id ON ssrf_allowlists(org_id);
CREATE INDEX idx_ssrf_allowlists_allowed_domain ON ssrf_allowlists(allowed_domain);

-- Privacy Training Opt-outs Table
CREATE TABLE privacy_training_optouts (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    allow_training BOOLEAN DEFAULT TRUE,
    opted_out BOOLEAN DEFAULT FALSE,
    reason TEXT,
    segregation_applied BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_privacy_training_optouts_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_privacy_training_optouts_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT uq_privacy_training_optouts_user UNIQUE(org_id, user_id)
);

ALTER TABLE privacy_training_optouts ENABLE ROW LEVEL SECURITY;

CREATE POLICY privacy_training_optouts_org_policy ON privacy_training_optouts
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_privacy_training_optouts_org_id ON privacy_training_optouts(org_id);
CREATE INDEX idx_privacy_training_optouts_user_id ON privacy_training_optouts(user_id);

-- Stripe Usage Records Table
CREATE TABLE stripe_usage_records (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    stripe_meter_id TEXT NOT NULL,
    token_count BIGINT NOT NULL DEFAULT 0,
    cost_usd DECIMAL(10,6) NOT NULL DEFAULT 0.000000,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    stripe_status TEXT NOT NULL DEFAULT 'pending',

    CONSTRAINT fk_stripe_usage_records_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_stripe_usage_records CHECK (token_count >= 0 AND cost_usd >= 0),
    CONSTRAINT chk_stripe_usage_records_status CHECK (stripe_status IN ('pending', 'confirmed', 'failed'))
);

ALTER TABLE stripe_usage_records ENABLE ROW LEVEL SECURITY;

CREATE POLICY stripe_usage_records_org_policy ON stripe_usage_records
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_stripe_usage_records_org_id ON stripe_usage_records(org_id);
CREATE INDEX idx_stripe_usage_records_stripe_meter_id ON stripe_usage_records(stripe_meter_id);
CREATE INDEX idx_stripe_usage_records_recorded_at ON stripe_usage_records(recorded_at DESC);

-- Yjs Document Lifecycle Table
CREATE TABLE yjs_document_lifecycle (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    document_namespace TEXT NOT NULL,
    gc_enabled BOOLEAN DEFAULT TRUE,
    undo_stack_limit INTEGER DEFAULT 5,
    snapshot_version INTEGER DEFAULT 0,
    size_mb DECIMAL(10,2) DEFAULT 0.0,
    compaction_triggered BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_yjs_document_lifecycle_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_yjs_document_lifecycle_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_yjs_document_lifecycle_undo_stack_limit CHECK (undo_stack_limit >= 0 AND undo_stack_limit <= 5)
);

ALTER TABLE yjs_document_lifecycle ENABLE ROW LEVEL SECURITY;

CREATE POLICY yjs_document_lifecycle_org_policy ON yjs_document_lifecycle
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_yjs_document_lifecycle_org_id ON yjs_document_lifecycle(org_id);
CREATE INDEX idx_yjs_document_lifecycle_document_namespace ON yjs_document_lifecycle(document_namespace);

-- Nylas Webhook Configuration Table
CREATE TABLE nylas_webhook_configuration (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    trigger_type TEXT NOT NULL,
    upsert_first BOOLEAN DEFAULT FALSE,
    async_queue BOOLEAN DEFAULT TRUE,
    timeout INTEGER DEFAULT 10,
    sync_policy TEXT NOT NULL DEFAULT 'incremental',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_nylas_webhook_configuration_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_nylas_webhook_configuration_timeout CHECK (timeout > 0),
    CONSTRAINT chk_nylas_webhook_configuration_sync_policy CHECK (sync_policy IN ('incremental', 'full'))
);

ALTER TABLE nylas_webhook_configuration ENABLE ROW LEVEL SECURITY;

CREATE POLICY nylas_webhook_configuration_org_policy ON nylas_webhook_configuration
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_nylas_webhook_configuration_org_id ON nylas_webhook_configuration(org_id);
CREATE INDEX idx_nylas_webhook_configuration_trigger_type ON nylas_webhook_configuration(trigger_type);

-- OpenTelemetry Span Definitions Table
CREATE TABLE opentelemetry_span_definitions (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    span_name TEXT NOT NULL,
    required_attributes JSONB NOT NULL DEFAULT '{}',
    redaction_rules JSONB NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_opentelemetry_span_definitions_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE
);

ALTER TABLE opentelemetry_span_definitions ENABLE ROW LEVEL SECURITY;

CREATE POLICY opentelemetry_span_definitions_org_policy ON opentelemetry_span_definitions
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_opentelemetry_span_definitions_org_id ON opentelemetry_span_definitions(org_id);
CREATE INDEX idx_opentelemetry_span_definitions_span_name ON opentelemetry_span_definitions(span_name);

-- Offline Tombstone Configuration Table
CREATE TABLE offline_tombstone_configuration (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    deleted_at_column TEXT NOT NULL DEFAULT 'deleted_at',
    retention_days INTEGER NOT NULL DEFAULT 90,
    compaction_schedule TEXT NOT NULL DEFAULT '0 2 * * 0',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_offline_tombstone_configuration_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_offline_tombstone_configuration_retention CHECK (retention_days > 0)
);

ALTER TABLE offline_tombstone_configuration ENABLE ROW LEVEL SECURITY;

CREATE POLICY offline_tombstone_configuration_org_policy ON offline_tombstone_configuration
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_offline_tombstone_configuration_org_id ON offline_tombstone_configuration(org_id);
CREATE INDEX idx_offline_tombstone_configuration_entity_type ON offline_tombstone_configuration(entity_type);

-- Realtime Limits Configuration Table
CREATE TABLE realtime_limits_configuration (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    platform_limit INTEGER NOT NULL DEFAULT 100,
    self_service_limit INTEGER NOT NULL DEFAULT 20,
    current_usage INTEGER DEFAULT 0,
    alert_threshold INTEGER DEFAULT 15,
    alert_triggered BOOLEAN DEFAULT FALSE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_realtime_limits_configuration_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_realtime_limits_configuration_limits CHECK (
        platform_limit > 0 AND
        self_service_limit > 0 AND
        self_service_limit <= platform_limit AND
        alert_threshold >= 0 AND
        alert_threshold <= self_service_limit
    )
);

ALTER TABLE realtime_limits_configuration ENABLE ROW LEVEL SECURITY;

CREATE POLICY realtime_limits_configuration_org_policy ON realtime_limits_configuration
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_realtime_limits_configuration_org_id ON realtime_limits_configuration(org_id);

-- Upload Security Configuration Table
CREATE TABLE upload_security_configuration (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    scanner TEXT NOT NULL DEFAULT 'clamd',
    version_pinned TEXT NOT NULL DEFAULT '1.4.x',
    cve_monitoring BOOLEAN DEFAULT TRUE,
    chunked_scanning BOOLEAN DEFAULT TRUE,
    pre_scan_validation BOOLEAN DEFAULT TRUE,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_upload_security_configuration_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_upload_security_configuration_scanner CHECK (scanner IN ('clamd', 'none'))
);

ALTER TABLE upload_security_configuration ENABLE ROW LEVEL SECURITY;

CREATE POLICY upload_security_configuration_org_policy ON upload_security_configuration
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_upload_security_configuration_org_id ON upload_security_configuration(org_id);

-- Recurrence Rule Configuration Table
CREATE TABLE recurrence_rule_configuration (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    rrule TEXT NOT NULL,
    rdate TEXT[],
    exdate TEXT[],
    timezone_id TEXT NOT NULL DEFAULT 'UTC',
    edit_mode TEXT NOT NULL DEFAULT 'this_and_future',
    exception_storage JSONB NOT NULL DEFAULT '{}',
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_recurrence_rule_configuration_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT chk_recurrence_rule_configuration_entity_type CHECK (entity_type IN ('event', 'task', 'reminder')),
    CONSTRAINT chk_recurrence_rule_configuration_edit_mode CHECK (edit_mode IN ('this', 'this_and_future', 'all'))
);

ALTER TABLE recurrence_rule_configuration ENABLE ROW LEVEL SECURITY;

CREATE POLICY recurrence_rule_configuration_org_policy ON recurrence_rule_configuration
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_recurrence_rule_configuration_org_id ON recurrence_rule_configuration(org_id);
CREATE INDEX idx_recurrence_rule_configuration_entity_type ON recurrence_rule_configuration(entity_type);

-- ============================================================================
-- Collaboration Tables
-- ============================================================================

-- Collab Documents Table
CREATE TABLE collab_documents (
    id TEXT PRIMARY KEY DEFAULT gen_random_ulid(),
    org_id TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    ysweet_document_id TEXT NOT NULL UNIQUE,
    entity_type TEXT NOT NULL,
    permissions JSONB NOT NULL DEFAULT '{}',
    creator_id TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'general',
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_collab_documents_org FOREIGN KEY (org_id) REFERENCES organizations(id) ON DELETE CASCADE,
    CONSTRAINT fk_collab_documents_creator FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT chk_collab_documents_entity_type CHECK (entity_type IN ('project', 'task', 'document', 'notebook'))
);

ALTER TABLE collab_documents ENABLE ROW LEVEL SECURITY;

CREATE POLICY collab_documents_org_policy ON collab_documents
    FOR ALL TO authenticated_users
    USING (org_id = auth.jwt()->>'org_id');

CREATE INDEX idx_collab_documents_org_id ON collab_documents(org_id);
CREATE INDEX idx_collab_documents_entity_id ON collab_documents(entity_id);
CREATE INDEX idx_collab_documents_ysweet_document_id ON collab_documents(ysweet_document_id);
CREATE INDEX idx_collab_documents_entity_type ON collab_documents(entity_type);

-- ============================================================================
-- Additional Updated At Triggers for New Tables
-- ============================================================================

CREATE TRIGGER update_specification_metadata_updated_at BEFORE UPDATE ON specification_metadata
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_realtime_channel_monitoring_updated_at BEFORE UPDATE ON realtime_channel_monitoring
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_test_coverage_targets_updated_at BEFORE UPDATE ON test_coverage_targets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_incident_management_updated_at BEFORE UPDATE ON incident_management
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_feature_flag_registry_updated_at BEFORE UPDATE ON feature_flag_registry
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cost_budgets_updated_at BEFORE UPDATE ON cost_budgets
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_slo_definitions_updated_at BEFORE UPDATE ON slo_definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_security_control_mappings_updated_at BEFORE UPDATE ON security_control_mappings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_mcp_tool_authorizations_updated_at BEFORE UPDATE ON mcp_tool_authorizations
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_passkeys_updated_at BEFORE UPDATE ON passkeys
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ssrf_allowlists_updated_at BEFORE UPDATE ON ssrf_allowlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_privacy_training_optouts_updated_at BEFORE UPDATE ON privacy_training_optouts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_yjs_document_lifecycle_updated_at BEFORE UPDATE ON yjs_document_lifecycle
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_nylas_webhook_configuration_updated_at BEFORE UPDATE ON nylas_webhook_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_opentelemetry_span_definitions_updated_at BEFORE UPDATE ON opentelemetry_span_definitions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_offline_tombstone_configuration_updated_at BEFORE UPDATE ON offline_tombstone_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_realtime_limits_configuration_updated_at BEFORE UPDATE ON realtime_limits_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_upload_security_configuration_updated_at BEFORE UPDATE ON upload_security_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_recurrence_rule_configuration_updated_at BEFORE UPDATE ON recurrence_rule_configuration
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_collab_documents_updated_at BEFORE UPDATE ON collab_documents
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- End of Schema
-- ============================================================================
*Last updated: 2026-04-26*
*Status: Complete - Ready for database initialization*
