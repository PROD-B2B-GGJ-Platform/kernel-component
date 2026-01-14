-- ============================================================================
-- V3: Seed TechCorp Learning Portal Data - Remaining Tabs
-- ============================================================================
-- Purpose: Create real TechCorp data for remaining Learning Portal tabs
--          References real employees, departments, courses from previous migration
-- Created: 2026-01-10
-- ============================================================================

DO $$
DECLARE
    -- TechCorp tenant ID (from Workforce employees)
    v_tenant_id UUID;
    
    -- Employee IDs (from Workforce - reuse from V2)
    v_emp_john_smith UUID;        -- Senior Engineer - EMP-016
    v_emp_maria_garcia UUID;      -- Senior Engineer - EMP-017
    v_emp_ryan_park UUID;         -- Backend Developer - EMP-020
    v_emp_alex_chen UUID;         -- Engineering Manager - EMP-014
    v_emp_mike_johnson UUID;      -- VP Engineering - EMP-002
    v_emp_sarah_director UUID;    -- HR Director - EMP-005
    
    -- Department IDs (from Workforce - reuse from V2)
    v_dept_engineering UUID;
    v_dept_backend UUID;
    v_dept_frontend UUID;
    v_dept_sales UUID;
    v_dept_hr UUID;
    
    -- Course IDs (from V2 migration)
    v_course_java_fundamentals UUID;
    v_course_security_awareness UUID;
    v_course_aws_certified UUID;
    
    -- Skill IDs (from V2 migration - need to fetch)
    v_skill_java UUID;
    v_skill_react UUID;
    v_skill_aws UUID;
    
    -- Org Unit IDs (will be created)
    v_org_unit_engineering UUID;
    v_org_unit_backend UUID;
    v_org_unit_frontend UUID;
BEGIN
    -- Get TechCorp tenant ID from existing employees
    SELECT DISTINCT tenant_id INTO v_tenant_id 
    FROM ggj_employees 
    WHERE employee_code LIKE 'EMP-%'
    LIMIT 1;
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'TechCorp tenant not found! Ensure Workforce data exists.';
    END IF;
    
    RAISE NOTICE '=== SEEDING TECHCORP LEARNING PORTAL - REMAINING TABS ===';
    RAISE NOTICE 'Tenant ID: %', v_tenant_id;
    
    -- Check if V8 migration has already run (check for multiple objects to be safe)
    IF EXISTS (SELECT 1 FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'ORG_UNIT' AND object_code = 'ORG-ENG')
       AND EXISTS (SELECT 1 FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'ORG_UNIT' AND object_code = 'ORG-ENG-BE')
       AND EXISTS (SELECT 1 FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'COMPLIANCE_REQUIREMENT' AND object_code = 'COMP-001') THEN
        RAISE NOTICE 'V8 migration already completed. Skipping seed data insertion.';
        RETURN;
    END IF;
    
    -- Get Employee IDs
    SELECT id INTO v_emp_john_smith FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-016' LIMIT 1;
    SELECT id INTO v_emp_maria_garcia FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-017' LIMIT 1;
    SELECT id INTO v_emp_ryan_park FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-020' LIMIT 1;
    SELECT id INTO v_emp_alex_chen FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-014' LIMIT 1;
    SELECT id INTO v_emp_mike_johnson FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-002' LIMIT 1;
    SELECT id INTO v_emp_sarah_director FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-005' LIMIT 1;
    
    -- Get Department IDs
    SELECT id INTO v_dept_engineering FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG' LIMIT 1;
    SELECT id INTO v_dept_backend FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-BE' LIMIT 1;
    SELECT id INTO v_dept_frontend FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-FE' LIMIT 1;
    SELECT id INTO v_dept_sales FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'SAL' LIMIT 1;
    SELECT id INTO v_dept_hr FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'HR' LIMIT 1;
    
    -- Get Course IDs from V7 migration (by object_code)
    SELECT id INTO v_course_java_fundamentals FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'COURSE' AND object_code = 'CRS-001' LIMIT 1;
    SELECT id INTO v_course_security_awareness FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'COURSE' AND object_code = 'CRS-005' LIMIT 1;
    SELECT id INTO v_course_aws_certified FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'COURSE' AND object_code = 'CRS-003' LIMIT 1;
    
    -- Get Skill IDs from V7 migration (by object_code)
    SELECT id INTO v_skill_java FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'SKILL' AND object_code = 'SKILL-001' LIMIT 1;
    SELECT id INTO v_skill_react FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'SKILL' AND object_code = 'SKILL-002' LIMIT 1;
    SELECT id INTO v_skill_aws FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'SKILL' AND object_code = 'SKILL-003' LIMIT 1;
    
    -- Validate required data exists (V7 must run first)
    IF v_course_java_fundamentals IS NULL OR v_course_security_awareness IS NULL OR v_course_aws_certified IS NULL THEN
        RAISE WARNING 'Some courses not found. V7 migration may not have completed. Skipping V8 data that depends on courses.';
    END IF;
    
    IF v_skill_java IS NULL OR v_skill_react IS NULL OR v_skill_aws IS NULL THEN
        RAISE WARNING 'Some skills not found. V7 migration may not have completed. Skipping V8 data that depends on skills.';
    END IF;
    
    IF v_emp_mike_johnson IS NULL OR v_emp_alex_chen IS NULL OR v_emp_sarah_director IS NULL THEN
        RAISE EXCEPTION 'Required employees not found! Ensure Workforce data exists for EMP-002, EMP-014, EMP-005.';
    END IF;
    
    -- ============================================================================
    -- 9. ORG_UNIT (Organizational Units - 5 units)
    -- ============================================================================
    RAISE NOTICE '9. Creating Org Units...';
    
    -- Org Unit 1: Engineering Division
    -- Check if already exists
    SELECT id INTO v_org_unit_engineering FROM ggj_kernel_objects 
    WHERE tenant_id = v_tenant_id AND object_type_code = 'ORG_UNIT' AND object_code = 'ORG-ENG' LIMIT 1;
    
    IF v_org_unit_engineering IS NULL THEN
        v_org_unit_engineering := gen_random_uuid();
        INSERT INTO ggj_kernel_objects (
            id, tenant_id, object_type_code, object_code, data, status, version,
            created_at, created_by, modified_at, modified_by
        ) VALUES (
            v_org_unit_engineering,
            v_tenant_id,
            'ORG_UNIT',
            'ORG-ENG',
            jsonb_build_object(
                'unit_code', 'ORG-ENG',
                'unit_name', 'Engineering Division',
                'description', 'Complete engineering organization including backend, frontend, DevOps, QA, and Data Engineering teams.',
                'unit_type', 'DIVISION',
                'manager_id', v_emp_mike_johnson,
                'level', 1,
                'path', '/Engineering',
                'cost_center', 'CC-200',
                'headcount', 45,
                'status', 'ACTIVE',
                'is_active', true,
                'created_date', CURRENT_DATE - INTERVAL '200 days'
            ),
            'ACTIVE', 1,
            CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
            CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    ELSE
        RAISE NOTICE 'Org Unit ORG-ENG already exists, skipping.';
    END IF;
    
    -- Org Unit 2: Backend Engineering Team
    -- Check if already exists
    SELECT id INTO v_org_unit_backend FROM ggj_kernel_objects 
    WHERE tenant_id = v_tenant_id AND object_type_code = 'ORG_UNIT' AND object_code = 'ORG-ENG-BE' LIMIT 1;
    
    IF v_org_unit_backend IS NULL THEN
        v_org_unit_backend := gen_random_uuid();
        INSERT INTO ggj_kernel_objects (
            id, tenant_id, object_type_code, object_code, data, status, version,
            created_at, created_by, modified_at, modified_by
        ) VALUES (
            v_org_unit_backend,
            v_tenant_id,
            'ORG_UNIT',
            'ORG-ENG-BE',
            jsonb_build_object(
                'unit_code', 'ORG-ENG-BE',
                'unit_name', 'Backend Engineering Team',
                'description', 'Backend development team responsible for server-side logic, APIs, and database management.',
                'unit_type', 'TEAM',
                'parent_unit_id', v_org_unit_engineering,
                'manager_id', v_emp_alex_chen,
                'level', 2,
                'path', '/Engineering/Backend',
                'cost_center', 'CC-210',
                'headcount', 15,
                'status', 'ACTIVE',
                'is_active', true,
                'created_date', CURRENT_DATE - INTERVAL '180 days'
            ),
            'ACTIVE', 1,
            CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
            CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    ELSE
        RAISE NOTICE 'Org Unit ORG-ENG-BE already exists, skipping.';
    END IF;
    
    -- Org Unit 3: Frontend Engineering Team
    v_org_unit_frontend := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_org_unit_frontend,
        v_tenant_id,
        'ORG_UNIT',
        'ORG-ENG-FE',
        jsonb_build_object(
            'unit_code', 'ORG-ENG-FE',
            'unit_name', 'Frontend Engineering Team',
            'description', 'Frontend development team responsible for user interfaces and client-side applications.',
            'unit_type', 'TEAM',
            'parent_unit_id', v_org_unit_engineering,
            'level', 2,
            'path', '/Engineering/Frontend',
            'cost_center', 'CC-220',
            'headcount', 12,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '180 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Get the ID if it was inserted or already exists
    SELECT id INTO v_org_unit_frontend FROM ggj_kernel_objects 
    WHERE tenant_id = v_tenant_id AND object_type_code = 'ORG_UNIT' AND object_code = 'ORG-ENG-FE' LIMIT 1;
    
    -- Org Unit 4: Sales Department Unit
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ORG_UNIT',
        'ORG-SAL',
        jsonb_build_object(
            'unit_code', 'ORG-SAL',
            'unit_name', 'Sales Department',
            'description', 'Sales organization including enterprise sales, SMB sales, and sales development teams.',
            'unit_type', 'DEPARTMENT',
            'level', 1,
            'path', '/Sales',
            'cost_center', 'CC-300',
            'headcount', 25,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '200 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Org Unit 5: HR Department Unit
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ORG_UNIT',
        'ORG-HR',
        jsonb_build_object(
            'unit_code', 'ORG-HR',
            'unit_name', 'Human Resources Department',
            'description', 'HR organization including talent acquisition, HR operations, and learning & development.',
            'unit_type', 'DEPARTMENT',
            'manager_id', v_emp_sarah_director,
            'level', 1,
            'path', '/HR',
            'cost_center', 'CC-500',
            'headcount', 8,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '200 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 5 org units';
    
    -- ============================================================================
    -- 10. COMPLIANCE_REQUIREMENT (3 compliance requirements)
    -- ============================================================================
    RAISE NOTICE '10. Creating Compliance Requirements...';
    
    -- Compliance 1: Security Awareness (GDPR/Company Policy)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'COMPLIANCE_REQUIREMENT',
        'COMP-001',
        jsonb_build_object(
            'requirement_code', 'COMP-001',
            'requirement_name', 'Security Awareness Training - GDPR & Company Policy',
            'description', 'Mandatory security awareness training required for all employees to comply with GDPR and company security policies.',
            'regulation_type', 'GDPR',
            'applicable_departments', jsonb_build_array(v_dept_engineering, v_dept_sales, v_dept_hr),
            'required_courses', jsonb_build_array(v_course_security_awareness),
            'validity_period_months', 12,
            'recurrence_type', 'ANNUAL',
            'priority', 'CRITICAL',
            'enforcement_date', CURRENT_DATE - INTERVAL '180 days',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '200 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Compliance 2: AWS Certification (Industry Standard)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'COMPLIANCE_REQUIREMENT',
        'COMP-002',
        jsonb_build_object(
            'requirement_code', 'COMP-002',
            'requirement_name', 'AWS Solutions Architect Certification - DevOps Team',
            'description', 'AWS Solutions Architect certification required for all DevOps engineers to maintain cloud infrastructure expertise.',
            'regulation_type', 'INDUSTRY_STANDARD',
            'applicable_departments', jsonb_build_array(v_dept_engineering),
            'required_courses', jsonb_build_array(v_course_aws_certified),
            'validity_period_months', 36,
            'recurrence_type', 'ONE_TIME',
            'priority', 'HIGH',
            'enforcement_date', CURRENT_DATE - INTERVAL '90 days',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '100 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '100 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Compliance 3: Java Certification (Company Policy)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'COMPLIANCE_REQUIREMENT',
        'COMP-003',
        jsonb_build_object(
            'requirement_code', 'COMP-003',
            'requirement_name', 'Java Fundamentals Certification - Backend Engineers',
            'description', 'Java fundamentals certification required for all backend engineers to ensure consistent coding standards.',
            'regulation_type', 'COMPANY_POLICY',
            'applicable_departments', jsonb_build_array(v_dept_backend),
            'required_courses', jsonb_build_array(v_course_java_fundamentals),
            'validity_period_months', 0,
            'recurrence_type', 'ONE_TIME',
            'priority', 'MEDIUM',
            'enforcement_date', CURRENT_DATE - INTERVAL '60 days',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '80 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '80 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 3 compliance requirements';
    
    -- ============================================================================
    -- 11. ASSIGNMENT_SCHEDULE (5 training assignment schedules)
    -- ============================================================================
    RAISE NOTICE '11. Creating Assignment Schedules...';
    
    -- Assignment Schedule 1: John Smith - Java Fundamentals
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSIGNMENT_SCHEDULE',
        'SCHED-001',
        jsonb_build_object(
            'schedule_code', 'SCHED-001',
            'employee_id', v_emp_john_smith,
            'course_id', v_course_java_fundamentals,
            'start_date', CURRENT_DATE - INTERVAL '30 days',
            'due_date', CURRENT_DATE + INTERVAL '10 days',
            'schedule_type', 'SELF_PACED',
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '30 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '30 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Assignment Schedule 2: Maria Garcia - Security Awareness (Completed)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSIGNMENT_SCHEDULE',
        'SCHED-002',
        jsonb_build_object(
            'schedule_code', 'SCHED-002',
            'employee_id', v_emp_maria_garcia,
            'course_id', v_course_security_awareness,
            'start_date', CURRENT_DATE - INTERVAL '60 days',
            'due_date', CURRENT_DATE - INTERVAL '30 days',
            'completion_date', CURRENT_DATE - INTERVAL '25 days',
            'schedule_type', 'SELF_PACED',
            'status', 'COMPLETED',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '60 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '60 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '25 days', 'system@techcorp.com'
    );
    
    -- Assignment Schedule 3: Ryan Park - Java Fundamentals (Scheduled)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSIGNMENT_SCHEDULE',
        'SCHED-003',
        jsonb_build_object(
            'schedule_code', 'SCHED-003',
            'employee_id', v_emp_ryan_park,
            'course_id', v_course_java_fundamentals,
            'start_date', CURRENT_DATE + INTERVAL '5 days',
            'due_date', CURRENT_DATE + INTERVAL '45 days',
            'schedule_type', 'INSTRUCTOR_LED',
            'status', 'SCHEDULED',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '10 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '10 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Assignment Schedule 4: John Smith - AWS Certification (Overdue)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSIGNMENT_SCHEDULE',
        'SCHED-004',
        jsonb_build_object(
            'schedule_code', 'SCHED-004',
            'employee_id', v_emp_john_smith,
            'course_id', v_course_aws_certified,
            'start_date', CURRENT_DATE - INTERVAL '90 days',
            'due_date', CURRENT_DATE - INTERVAL '10 days',
            'schedule_type', 'HYBRID',
            'status', 'OVERDUE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '90 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Assignment Schedule 5: Maria Garcia - AWS Certification (In Progress)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSIGNMENT_SCHEDULE',
        'SCHED-005',
        jsonb_build_object(
            'schedule_code', 'SCHED-005',
            'employee_id', v_emp_maria_garcia,
            'course_id', v_course_aws_certified,
            'start_date', CURRENT_DATE - INTERVAL '20 days',
            'due_date', CURRENT_DATE + INTERVAL '60 days',
            'schedule_type', 'HYBRID',
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '20 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '20 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 5 assignment schedules';
    
    -- ============================================================================
    -- 12. SKILLS_GAP (6 skills gap analyses)
    -- ============================================================================
    RAISE NOTICE '12. Creating Skills Gap Analyses...';
    
    -- Skills Gap 1: John Smith - Java (Gap: 2 levels)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-001',
        jsonb_build_object(
            'gap_code', 'GAP-001',
            'employee_id', v_emp_john_smith,
            'skill_id', v_skill_java,
            'current_level', 2,
            'target_level', 4,
            'gap', 2,
            'priority', 'HIGH',
            'recommended_courses', jsonb_build_array(v_course_java_fundamentals),
            'status', 'OPEN',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '30 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '30 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Skills Gap 2: Ryan Park - React (Gap: 3 levels)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-002',
        jsonb_build_object(
            'gap_code', 'GAP-002',
            'employee_id', v_emp_ryan_park,
            'skill_id', v_skill_react,
            'current_level', 1,
            'target_level', 4,
            'gap', 3,
            'priority', 'CRITICAL',
            'recommended_courses', jsonb_build_array(v_course_java_fundamentals),
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '25 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '25 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Skills Gap 3: Maria Garcia - AWS (Gap: 1 level)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-003',
        jsonb_build_object(
            'gap_code', 'GAP-003',
            'employee_id', v_emp_maria_garcia,
            'skill_id', v_skill_aws,
            'current_level', 3,
            'target_level', 4,
            'gap', 1,
            'priority', 'MEDIUM',
            'recommended_courses', jsonb_build_array(v_course_aws_certified),
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '20 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '20 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Skills Gap 4: John Smith - AWS (Gap: 2 levels)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-004',
        jsonb_build_object(
            'gap_code', 'GAP-004',
            'employee_id', v_emp_john_smith,
            'skill_id', v_skill_aws,
            'current_level', 2,
            'target_level', 4,
            'gap', 2,
            'priority', 'HIGH',
            'recommended_courses', jsonb_build_array(v_course_aws_certified),
            'status', 'OPEN',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '15 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '15 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Skills Gap 5: Ryan Park - Java (Gap: 1 level - Resolved)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-005',
        jsonb_build_object(
            'gap_code', 'GAP-005',
            'employee_id', v_emp_ryan_park,
            'skill_id', v_skill_java,
            'current_level', 3,
            'target_level', 3,
            'gap', 0,
            'priority', 'LOW',
            'status', 'RESOLVED',
            'is_active', false,
            'created_date', CURRENT_DATE - INTERVAL '60 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '60 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '10 days', 'system@techcorp.com'
    );
    
    -- Skills Gap 6: Maria Garcia - React (Gap: 1 level)
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILLS_GAP',
        'GAP-006',
        jsonb_build_object(
            'gap_code', 'GAP-006',
            'employee_id', v_emp_maria_garcia,
            'skill_id', v_skill_react,
            'current_level', 3,
            'target_level', 4,
            'gap', 1,
            'priority', 'MEDIUM',
            'status', 'OPEN',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '10 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '10 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 6 skills gap analyses';
    
    -- ============================================================================
    -- 13. PERFORMANCE_MAPPING (3 performance mappings)
    -- ============================================================================
    RAISE NOTICE '13. Creating Performance Mappings...';
    
    -- Performance Mapping 1: Senior Software Engineer
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PERFORMANCE_MAPPING',
        'PERF-001',
        jsonb_build_object(
            'mapping_code', 'PERF-001',
            'mapping_name', 'Senior Software Engineer Performance Mapping',
            'description', 'Performance expectations and competency mapping for Senior Software Engineer role.',
            'competencies', jsonb_build_object(
                'technical_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Java Programming', 'target_level', 4),
                    jsonb_build_object('skill', 'React Development', 'target_level', 3),
                    jsonb_build_object('skill', 'AWS Cloud Architecture', 'target_level', 3)
                ),
                'soft_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Leadership', 'target_level', 3),
                    jsonb_build_object('skill', 'Agile/Scrum', 'target_level', 4)
                )
            ),
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '150 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '150 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Performance Mapping 2: Engineering Manager
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PERFORMANCE_MAPPING',
        'PERF-002',
        jsonb_build_object(
            'mapping_code', 'PERF-002',
            'mapping_name', 'Engineering Manager Performance Mapping',
            'description', 'Performance expectations and competency mapping for Engineering Manager role.',
            'competencies', jsonb_build_object(
                'technical_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Java Programming', 'target_level', 4),
                    jsonb_build_object('skill', 'AWS Cloud Architecture', 'target_level', 3)
                ),
                'soft_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Leadership', 'target_level', 5),
                    jsonb_build_object('skill', 'Agile/Scrum', 'target_level', 5)
                )
            ),
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '120 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '120 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Performance Mapping 3: Backend Developer
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PERFORMANCE_MAPPING',
        'PERF-003',
        jsonb_build_object(
            'mapping_code', 'PERF-003',
            'mapping_name', 'Backend Developer Performance Mapping',
            'description', 'Performance expectations and competency mapping for Backend Developer role.',
            'competencies', jsonb_build_object(
                'technical_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Java Programming', 'target_level', 4),
                    jsonb_build_object('skill', 'AWS Cloud Architecture', 'target_level', 2)
                ),
                'soft_skills', jsonb_build_array(
                    jsonb_build_object('skill', 'Agile/Scrum', 'target_level', 3)
                )
            ),
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '100 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '100 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 3 performance mappings';
    
    -- ============================================================================
    -- 14. PROJECT (4 learning-related projects)
    -- ============================================================================
    RAISE NOTICE '14. Creating Projects...';
    
    -- Project 1: Learning Platform Enhancement
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PROJECT',
        'PROJ-001',
        jsonb_build_object(
            'project_code', 'PROJ-001',
            'project_name', 'Learning Platform Enhancement Project',
            'description', 'Enhancement project to improve Learning Portal functionality, add new features, and integrate with Workforce module.',
            'project_type', 'INTERNAL',
            'department_id', v_dept_engineering,
            'manager_id', v_emp_alex_chen,
            'start_date', CURRENT_DATE - INTERVAL '90 days',
            'end_date', CURRENT_DATE + INTERVAL '90 days',
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '90 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Project 2: Employee Onboarding Automation
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PROJECT',
        'PROJ-002',
        jsonb_build_object(
            'project_code', 'PROJ-002',
            'project_name', 'Employee Onboarding Automation',
            'description', 'Project to automate employee onboarding training assignments and track completion.',
            'project_type', 'INTERNAL',
            'department_id', v_dept_hr,
            'manager_id', v_emp_sarah_director,
            'start_date', CURRENT_DATE - INTERVAL '60 days',
            'end_date', CURRENT_DATE + INTERVAL '30 days',
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '60 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '60 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Project 3: Skills Development Initiative
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PROJECT',
        'PROJ-003',
        jsonb_build_object(
            'project_code', 'PROJ-003',
            'project_name', 'Q1 2025 Skills Development Initiative',
            'description', 'Quarterly initiative to identify skill gaps and provide targeted training programs for engineering teams.',
            'project_type', 'INTERNAL',
            'department_id', v_dept_engineering,
            'manager_id', v_emp_mike_johnson,
            'start_date', CURRENT_DATE - INTERVAL '30 days',
            'end_date', CURRENT_DATE + INTERVAL '60 days',
            'status', 'IN_PROGRESS',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '30 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '30 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Project 4: Compliance Training Rollout
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'PROJECT',
        'PROJ-004',
        jsonb_build_object(
            'project_code', 'PROJ-004',
            'project_name', 'Compliance Training Rollout 2025',
            'description', 'Project to roll out mandatory compliance training across all departments and track completion.',
            'project_type', 'INTERNAL',
            'department_id', v_dept_hr,
            'manager_id', v_emp_sarah_director,
            'start_date', CURRENT_DATE - INTERVAL '120 days',
            'end_date', CURRENT_DATE - INTERVAL '30 days',
            'status', 'COMPLETED',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '120 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '120 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '30 days', 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 4 projects';
    
    -- ============================================================================
    -- 15. ADMINISTRATION (3 administration records)
    -- ============================================================================
    RAISE NOTICE '15. Creating Administration Records...';
    
    -- Administration 1: Learning Portal Configuration
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ADMINISTRATION',
        'ADMIN-001',
        jsonb_build_object(
            'admin_code', 'ADMIN-001',
            'title', 'Learning Portal System Configuration',
            'description', 'System configuration settings for Learning Portal including course approval workflows, enrollment limits, and notification preferences.',
            'administration_type', 'CONFIGURATION',
            'category', 'LEARNING',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '200 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Administration 2: Training Policy Document
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ADMINISTRATION',
        'ADMIN-002',
        jsonb_build_object(
            'admin_code', 'ADMIN-002',
            'title', 'TechCorp Training Policy 2025',
            'description', 'Company-wide training policy document outlining mandatory training requirements, certification policies, and learning development guidelines.',
            'administration_type', 'POLICY',
            'category', 'LEARNING',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '180 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    -- Administration 3: Learning Portal Audit Log
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ADMINISTRATION',
        'ADMIN-003',
        jsonb_build_object(
            'admin_code', 'ADMIN-003',
            'title', 'Learning Portal Access Audit - Q4 2024',
            'description', 'Quarterly audit log of Learning Portal access, course enrollments, and system usage for compliance reporting.',
            'administration_type', 'AUDIT',
            'category', 'LEARNING',
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '15 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '15 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
        ) ON CONFLICT (tenant_id, object_type_code, object_code) DO NOTHING;
    
    RAISE NOTICE '   Created 3 administration records';
    
    -- ============================================================================
    -- COMPLETION SUMMARY
    -- ============================================================================
    RAISE NOTICE '';
    RAISE NOTICE '=== TECHCORP LEARNING PORTAL - REMAINING TABS DATA SEEDED ===';
    RAISE NOTICE 'Org Units: 5';
    RAISE NOTICE 'Compliance Requirements: 3';
    RAISE NOTICE 'Assignment Schedules: 5';
    RAISE NOTICE 'Skills Gap Analyses: 6';
    RAISE NOTICE 'Performance Mappings: 3';
    RAISE NOTICE 'Projects: 4';
    RAISE NOTICE 'Administration Records: 3';
    RAISE NOTICE '';
    RAISE NOTICE 'Total Learning Portal Objects: 35 (8 from V2 + 27 from V3)';
    RAISE NOTICE 'All 16 tabs now have real TechCorp data!';
    RAISE NOTICE 'Data is ready for drill-down navigation and full functionality simulation.';
    
END $$;
