-- ============================================================================
-- V2: Seed TechCorp Learning Portal Data
-- ============================================================================
-- Purpose: Create real TechCorp data for Learning Portal
--          References real employees and departments from Workforce module
-- Created: 2026-01-10
-- ============================================================================

DO $$
DECLARE
    -- TechCorp tenant ID (from Workforce employees)
    v_tenant_id UUID;
    
    -- Employee IDs (from Workforce)
    v_emp_david_miller UUID;      -- CEO - EMP-001
    v_emp_mike_johnson UUID;      -- VP Engineering - EMP-002
    v_emp_lisa_wang UUID;         -- VP Sales - EMP-003
    v_emp_tom_brown UUID;         -- VP Marketing - EMP-004
    v_emp_sarah_director UUID;    -- HR Director - EMP-005
    v_emp_rachel_green UUID;      -- L&D Manager - EMP-012
    v_emp_alex_chen UUID;         -- Engineering Manager - EMP-014
    v_emp_jessica_wong UUID;      -- Engineering Manager FE - EMP-015
    v_emp_john_smith UUID;        -- Senior Engineer - EMP-016
    v_emp_maria_garcia UUID;      -- Senior Engineer - EMP-017
    v_emp_james_wilson UUID;      -- DevOps Engineer - EMP-018
    v_emp_anna_taylor UUID;       -- Frontend Developer - EMP-019
    v_emp_ryan_park UUID;         -- Backend Developer - EMP-020
    v_emp_sophia_lee UUID;        -- QA Engineer - EMP-021
    v_emp_daniel_kim UUID;        -- Data Engineer - EMP-022
    v_emp_michael_brown UUID;     -- Sales Manager - EMP-023
    v_emp_sarah_connor UUID;      -- Sales Manager SMB - EMP-024
    
    -- Department IDs (from Workforce)
    v_dept_engineering UUID;
    v_dept_backend UUID;
    v_dept_frontend UUID;
    v_dept_devops UUID;
    v_dept_qa UUID;
    v_dept_sales UUID;
    v_dept_marketing UUID;
    v_dept_hr UUID;
    
    -- Course IDs (to reference in other objects)
    v_course_java_fundamentals UUID;
    v_course_react_advanced UUID;
    v_course_aws_certified UUID;
    v_course_leadership UUID;
    v_course_security_awareness UUID;
    v_course_agile_scrum UUID;
    v_course_python_datascience UUID;
    v_course_devops_kubernetes UUID;
    
    -- Training Plan IDs
    v_plan_new_engineer UUID;
    v_plan_new_manager UUID;
    v_plan_sales_onboarding UUID;
    
    -- Certification IDs
    v_cert_aws_solutions UUID;
    v_cert_java_developer UUID;
    v_cert_react_certified UUID;
BEGIN
    -- Get TechCorp tenant ID from existing employees
    SELECT DISTINCT tenant_id INTO v_tenant_id 
    FROM ggj_employees 
    WHERE employee_code LIKE 'EMP-%'
    LIMIT 1;
    
    IF v_tenant_id IS NULL THEN
        RAISE EXCEPTION 'TechCorp tenant not found! Ensure Workforce data exists.';
    END IF;
    
    RAISE NOTICE '=== SEEDING TECHCORP LEARNING PORTAL DATA ===';
    RAISE NOTICE 'Tenant ID: %', v_tenant_id;
    
    -- Check if V7 migration has already run (check for CRS-001 course)
    IF EXISTS (SELECT 1 FROM ggj_kernel_objects WHERE tenant_id = v_tenant_id AND object_type_code = 'COURSE' AND object_code = 'CRS-001') THEN
        RAISE NOTICE 'V7 migration already completed. Skipping seed data insertion.';
        RETURN;
    END IF;
    
    -- Get Employee IDs (match by employee_code pattern or name from master data)
    SELECT id INTO v_emp_david_miller FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-001' LIMIT 1;
    SELECT id INTO v_emp_mike_johnson FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-002' LIMIT 1;
    SELECT id INTO v_emp_lisa_wang FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-003' LIMIT 1;
    SELECT id INTO v_emp_tom_brown FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-004' LIMIT 1;
    SELECT id INTO v_emp_sarah_director FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-005' LIMIT 1;
    SELECT id INTO v_emp_rachel_green FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-012' LIMIT 1;
    SELECT id INTO v_emp_alex_chen FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-014' LIMIT 1;
    SELECT id INTO v_emp_jessica_wong FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-015' LIMIT 1;
    SELECT id INTO v_emp_john_smith FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-016' LIMIT 1;
    SELECT id INTO v_emp_maria_garcia FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-017' LIMIT 1;
    SELECT id INTO v_emp_james_wilson FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-018' LIMIT 1;
    SELECT id INTO v_emp_anna_taylor FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-019' LIMIT 1;
    SELECT id INTO v_emp_ryan_park FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-020' LIMIT 1;
    SELECT id INTO v_emp_sophia_lee FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-021' LIMIT 1;
    SELECT id INTO v_emp_daniel_kim FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-022' LIMIT 1;
    SELECT id INTO v_emp_michael_brown FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-023' LIMIT 1;
    SELECT id INTO v_emp_sarah_connor FROM ggj_employees WHERE tenant_id = v_tenant_id AND employee_code = 'EMP-024' LIMIT 1;
    
    -- Get Department IDs (match by department_code)
    SELECT id INTO v_dept_engineering FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG' LIMIT 1;
    SELECT id INTO v_dept_backend FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-BE' LIMIT 1;
    SELECT id INTO v_dept_frontend FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-FE' LIMIT 1;
    SELECT id INTO v_dept_devops FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-OPS' LIMIT 1;
    SELECT id INTO v_dept_qa FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'ENG-QA' LIMIT 1;
    SELECT id INTO v_dept_sales FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'SAL' LIMIT 1;
    SELECT id INTO v_dept_marketing FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'MKT' LIMIT 1;
    SELECT id INTO v_dept_hr FROM ggj_departments WHERE tenant_id = v_tenant_id AND department_code = 'HR' LIMIT 1;
    
    RAISE NOTICE 'Found % employees and % departments', 
        (SELECT COUNT(*) FROM ggj_employees WHERE tenant_id = v_tenant_id),
        (SELECT COUNT(*) FROM ggj_departments WHERE tenant_id = v_tenant_id);
    
    -- ============================================================================
    -- 1. COURSES (8 professional courses aligned with TechCorp needs)
    -- ============================================================================
    RAISE NOTICE '1. Creating Courses...';
    
    -- Course 1: Java Fundamentals
    -- Check if already exists
    SELECT id INTO v_course_java_fundamentals FROM ggj_kernel_objects 
    WHERE tenant_id = v_tenant_id AND object_type_code = 'COURSE' AND object_code = 'CRS-001' LIMIT 1;
    
    IF v_course_java_fundamentals IS NULL THEN
        v_course_java_fundamentals := gen_random_uuid();
        INSERT INTO ggj_kernel_objects (
            id, tenant_id, object_type_code, object_code, data, status, version,
            created_at, created_by, modified_at, modified_by
        ) VALUES (
            v_course_java_fundamentals,
            v_tenant_id,
            'COURSE',
            'CRS-001',
            jsonb_build_object(
                'course_code', 'CRS-001',
                'course_name', 'Java Fundamentals',
                'description', 'Comprehensive introduction to Java programming language covering core concepts, OOP principles, and best practices.',
                'category', 'TECHNICAL',
                'level', 'BEGINNER',
                'duration_hours', 40,
                'credits', 3.0,
                'format', 'INSTRUCTOR_LED',
                'instructor_id', v_emp_alex_chen,
                'department_id', v_dept_backend,
                'max_enrollments', 25,
                'current_enrollments', 18,
                'language', 'EN',
                'is_mandatory', false,
                'is_active', true,
                'status', 'PUBLISHED',
                'created_date', CURRENT_DATE,
                'last_reviewed_date', CURRENT_DATE - INTERVAL '30 days',
                'next_review_date', CURRENT_DATE + INTERVAL '6 months'
            ),
            'ACTIVE', 1,
            CURRENT_TIMESTAMP, 'system@techcorp.com',
            CURRENT_TIMESTAMP, 'system@techcorp.com'
        );
    ELSE
        RAISE NOTICE 'Course CRS-001 already exists, skipping.';
    END IF;
    
    -- Course 2: Advanced React & Node.js
    v_course_react_advanced := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_react_advanced,
        v_tenant_id,
        'COURSE',
        'CRS-002',
        jsonb_build_object(
            'course_code', 'CRS-002',
            'course_name', 'Advanced React & Node.js',
            'description', 'Full-stack web development with React frontend and Node.js backend. Covers hooks, state management, API design, and deployment.',
            'category', 'TECHNICAL',
            'level', 'INTERMEDIATE',
            'duration_hours', 60,
            'credits', 5.0,
            'format', 'HYBRID',
            'instructor_id', v_emp_jessica_wong,
            'department_id', v_dept_frontend,
            'max_enrollments', 20,
            'current_enrollments', 15,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'prerequisites', jsonb_build_array('CRS-001'),
            'created_date', CURRENT_DATE - INTERVAL '60 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '15 days',
            'next_review_date', CURRENT_DATE + INTERVAL '5 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '60 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '15 days', 'system@techcorp.com'
    );
    
    -- Course 3: AWS Solutions Architect Certification Prep
    v_course_aws_certified := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_aws_certified,
        v_tenant_id,
        'COURSE',
        'CRS-003',
        jsonb_build_object(
            'course_code', 'CRS-003',
            'course_name', 'AWS Solutions Architect Certification Prep',
            'description', 'Prepare for AWS Certified Solutions Architect exam. Covers EC2, S3, RDS, Lambda, VPC, and cloud architecture best practices.',
            'category', 'CERTIFICATION',
            'level', 'ADVANCED',
            'duration_hours', 80,
            'credits', 6.0,
            'format', 'HYBRID',
            'instructor_id', v_emp_james_wilson,
            'department_id', v_dept_devops,
            'max_enrollments', 15,
            'current_enrollments', 12,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'certification_awarded', 'AWS Certified Solutions Architect - Associate',
            'validity_period_days', 1095,
            'created_date', CURRENT_DATE - INTERVAL '90 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '10 days',
            'next_review_date', CURRENT_DATE + INTERVAL '4 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '10 days', 'system@techcorp.com'
    );
    
    -- Course 4: Leadership Essentials
    v_course_leadership := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_leadership,
        v_tenant_id,
        'COURSE',
        'CRS-004',
        jsonb_build_object(
            'course_code', 'CRS-004',
            'course_name', 'Leadership Essentials: From IC to Manager',
            'description', 'Essential skills for transitioning from individual contributor to manager. Covers delegation, feedback, conflict resolution, and team building.',
            'category', 'SOFT_SKILLS',
            'level', 'INTERMEDIATE',
            'duration_hours', 24,
            'credits', 2.0,
            'format', 'INSTRUCTOR_LED',
            'instructor_id', v_emp_sarah_director,
            'department_id', v_dept_hr,
            'max_enrollments', 30,
            'current_enrollments', 22,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'created_date', CURRENT_DATE - INTERVAL '45 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '5 days',
            'next_review_date', CURRENT_DATE + INTERVAL '7 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '45 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '5 days', 'system@techcorp.com'
    );
    
    -- Course 5: Security Awareness Training (Mandatory)
    v_course_security_awareness := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_security_awareness,
        v_tenant_id,
        'COURSE',
        'CRS-005',
        jsonb_build_object(
            'course_code', 'CRS-005',
            'course_name', 'Information Security Awareness Training 2025',
            'description', 'Mandatory security awareness training covering phishing, password security, data protection, and company security policies.',
            'category', 'COMPLIANCE',
            'level', 'BEGINNER',
            'duration_hours', 4,
            'credits', 0.5,
            'format', 'SELF_PACED',
            'department_id', v_dept_hr,
            'max_enrollments', 1000,
            'current_enrollments', 23,
            'language', 'EN',
            'is_mandatory', true,
            'is_active', true,
            'status', 'PUBLISHED',
            'validity_period_days', 365,
            'created_date', CURRENT_DATE - INTERVAL '180 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '20 days',
            'next_review_date', CURRENT_DATE + INTERVAL '11 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '20 days', 'system@techcorp.com'
    );
    
    -- Course 6: Agile & Scrum Fundamentals
    v_course_agile_scrum := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_agile_scrum,
        v_tenant_id,
        'COURSE',
        'CRS-006',
        jsonb_build_object(
            'course_code', 'CRS-006',
            'course_name', 'Agile & Scrum Fundamentals',
            'description', 'Introduction to Agile methodologies and Scrum framework. Covers sprints, standups, retrospectives, and agile principles.',
            'category', 'SOFT_SKILLS',
            'level', 'BEGINNER',
            'duration_hours', 16,
            'credits', 1.5,
            'format', 'INSTRUCTOR_LED',
            'instructor_id', v_emp_mike_johnson,
            'department_id', v_dept_engineering,
            'max_enrollments', 35,
            'current_enrollments', 28,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'created_date', CURRENT_DATE - INTERVAL '30 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '3 days',
            'next_review_date', CURRENT_DATE + INTERVAL '9 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '30 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '3 days', 'system@techcorp.com'
    );
    
    -- Course 7: Python for Data Science
    v_course_python_datascience := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_python_datascience,
        v_tenant_id,
        'COURSE',
        'CRS-007',
        jsonb_build_object(
            'course_code', 'CRS-007',
            'course_name', 'Python for Data Science & Machine Learning',
            'description', 'Learn Python programming for data analysis, visualization, and machine learning using pandas, numpy, matplotlib, and scikit-learn.',
            'category', 'TECHNICAL',
            'level', 'INTERMEDIATE',
            'duration_hours', 50,
            'credits', 4.0,
            'format', 'HYBRID',
            'instructor_id', v_emp_daniel_kim,
            'department_id', v_dept_engineering,
            'max_enrollments', 20,
            'current_enrollments', 14,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'prerequisites', jsonb_build_array('CRS-001'),
            'created_date', CURRENT_DATE - INTERVAL '75 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '12 days',
            'next_review_date', CURRENT_DATE + INTERVAL '6 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '75 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '12 days', 'system@techcorp.com'
    );
    
    -- Course 8: DevOps & Kubernetes
    v_course_devops_kubernetes := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_course_devops_kubernetes,
        v_tenant_id,
        'COURSE',
        'CRS-008',
        jsonb_build_object(
            'course_code', 'CRS-008',
            'course_name', 'DevOps & Kubernetes Mastery',
            'description', 'Master containerization with Docker and orchestration with Kubernetes. Covers CI/CD, monitoring, and cloud-native architecture.',
            'category', 'TECHNICAL',
            'level', 'ADVANCED',
            'duration_hours', 70,
            'credits', 6.0,
            'format', 'HYBRID',
            'instructor_id', v_emp_james_wilson,
            'department_id', v_dept_devops,
            'max_enrollments', 18,
            'current_enrollments', 11,
            'language', 'EN',
            'is_mandatory', false,
            'is_active', true,
            'status', 'PUBLISHED',
            'prerequisites', jsonb_build_array('CRS-003'),
            'created_date', CURRENT_DATE - INTERVAL '50 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '8 days',
            'next_review_date', CURRENT_DATE + INTERVAL '7 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '50 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '8 days', 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 8 courses';
    
    -- ============================================================================
    -- 2. TRAINING PLANS (3 comprehensive training plans)
    -- ============================================================================
    RAISE NOTICE '2. Creating Training Plans...';
    
    -- Training Plan 1: New Engineer Onboarding
    v_plan_new_engineer := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_plan_new_engineer,
        v_tenant_id,
        'TRAINING_PLAN',
        'TP-001',
        jsonb_build_object(
            'plan_code', 'TP-001',
            'plan_name', 'New Engineer Onboarding Plan',
            'description', 'Comprehensive onboarding plan for new software engineers covering technical skills, tools, and company culture.',
            'target_audience', 'NEW_HIRES',
            'department_id', v_dept_engineering,
            'duration_weeks', 12,
            'total_hours', 120,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_java_fundamentals, 'course_code', 'CRS-001', 'order', 1),
                jsonb_build_object('course_id', v_course_agile_scrum, 'course_code', 'CRS-006', 'order', 2),
                jsonb_build_object('course_id', v_course_security_awareness, 'course_code', 'CRS-005', 'order', 3)
            ),
            'is_mandatory', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '200 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '25 days',
            'next_review_date', CURRENT_DATE + INTERVAL '5 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '25 days', 'system@techcorp.com'
    );
    
    -- Training Plan 2: New Manager Development
    v_plan_new_manager := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_plan_new_manager,
        v_tenant_id,
        'TRAINING_PLAN',
        'TP-002',
        jsonb_build_object(
            'plan_code', 'TP-002',
            'plan_name', 'New Manager Development Program',
            'description', 'Leadership development program for employees transitioning to management roles.',
            'target_audience', 'PROMOTED_EMPLOYEES',
            'department_id', v_dept_hr,
            'duration_weeks', 16,
            'total_hours', 80,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_leadership, 'course_code', 'CRS-004', 'order', 1),
                jsonb_build_object('course_id', v_course_agile_scrum, 'course_code', 'CRS-006', 'order', 2)
            ),
            'is_mandatory', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '150 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '18 days',
            'next_review_date', CURRENT_DATE + INTERVAL '6 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '150 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '18 days', 'system@techcorp.com'
    );
    
    -- Training Plan 3: Sales Onboarding
    v_plan_sales_onboarding := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_plan_sales_onboarding,
        v_tenant_id,
        'TRAINING_PLAN',
        'TP-003',
        jsonb_build_object(
            'plan_code', 'TP-003',
            'plan_name', 'Sales Team Onboarding',
            'description', 'Comprehensive onboarding for new sales team members covering products, processes, and sales methodology.',
            'target_audience', 'NEW_HIRES',
            'department_id', v_dept_sales,
            'duration_weeks', 8,
            'total_hours', 60,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_security_awareness, 'course_code', 'CRS-005', 'order', 1)
            ),
            'is_mandatory', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '120 days',
            'last_reviewed_date', CURRENT_DATE - INTERVAL '14 days',
            'next_review_date', CURRENT_DATE + INTERVAL '8 months'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '120 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP - INTERVAL '14 days', 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 3 training plans';
    
    -- ============================================================================
    -- 3. CERTIFICATIONS (3 professional certifications)
    -- ============================================================================
    RAISE NOTICE '3. Creating Certifications...';
    
    -- Certification 1: AWS Solutions Architect
    v_cert_aws_solutions := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_cert_aws_solutions,
        v_tenant_id,
        'CERTIFICATION',
        'CERT-001',
        jsonb_build_object(
            'cert_code', 'CERT-001',
            'cert_name', 'AWS Certified Solutions Architect - Associate',
            'description', 'AWS certification demonstrating expertise in designing distributed systems on AWS platform.',
            'certification_type', 'EXTERNAL',
            'issuing_organization', 'Amazon Web Services',
            'course_id', v_course_aws_certified,
            'validity_period_years', 3,
            'renewal_required', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '90 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Certification 2: Java Developer Certified
    v_cert_java_developer := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_cert_java_developer,
        v_tenant_id,
        'CERTIFICATION',
        'CERT-002',
        jsonb_build_object(
            'cert_code', 'CERT-002',
            'cert_name', 'Oracle Certified Java Developer',
            'description', 'Oracle certification demonstrating proficiency in Java SE development.',
            'certification_type', 'EXTERNAL',
            'issuing_organization', 'Oracle Corporation',
            'course_id', v_course_java_fundamentals,
            'validity_period_years', 0,
            'renewal_required', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '60 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '60 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Certification 3: React Certified
    v_cert_react_certified := gen_random_uuid();
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        v_cert_react_certified,
        v_tenant_id,
        'CERTIFICATION',
        'CERT-003',
        jsonb_build_object(
            'cert_code', 'CERT-003',
            'cert_name', 'Meta React Developer Certificate',
            'description', 'Meta certification demonstrating expertise in React and modern frontend development.',
            'certification_type', 'EXTERNAL',
            'issuing_organization', 'Meta (Facebook)',
            'course_id', v_course_react_advanced,
            'validity_period_years', 2,
            'renewal_required', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '45 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '45 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 3 certifications';
    
    -- ============================================================================
    -- 4. ASSESSMENTS (5 assessments for various courses)
    -- ============================================================================
    RAISE NOTICE '4. Creating Assessments...';
    
    -- Assessment 1: Java Fundamentals Exam
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSESSMENT',
        'ASSESS-001',
        jsonb_build_object(
            'assessment_code', 'ASSESS-001',
            'assessment_name', 'Java Fundamentals Final Exam',
            'description', 'Comprehensive exam covering Java fundamentals, OOP, and core concepts.',
            'course_id', v_course_java_fundamentals,
            'type', 'EXAM',
            'duration_minutes', 120,
            'passing_score', 70,
            'max_attempts', 3,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '40 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '40 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Assessment 2: React Project Evaluation
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSESSMENT',
        'ASSESS-002',
        jsonb_build_object(
            'assessment_code', 'ASSESS-002',
            'assessment_name', 'React Full-Stack Project Evaluation',
            'description', 'Project-based assessment requiring students to build a full-stack application using React and Node.js.',
            'course_id', v_course_react_advanced,
            'type', 'PROJECT',
            'duration_minutes', 1440,
            'passing_score', 75,
            'max_attempts', 2,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '35 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '35 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Assessment 3: Security Awareness Quiz
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSESSMENT',
        'ASSESS-003',
        jsonb_build_object(
            'assessment_code', 'ASSESS-003',
            'assessment_name', 'Security Awareness Quiz',
            'description', 'Mandatory quiz covering security policies, phishing awareness, and data protection.',
            'course_id', v_course_security_awareness,
            'type', 'QUIZ',
            'duration_minutes', 30,
            'passing_score', 80,
            'max_attempts', 5,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '180 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Assessment 4: AWS Practice Exam
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSESSMENT',
        'ASSESS-004',
        jsonb_build_object(
            'assessment_code', 'ASSESS-004',
            'assessment_name', 'AWS Solutions Architect Practice Exam',
            'description', 'Practice exam simulating the actual AWS certification exam format and difficulty.',
            'course_id', v_course_aws_certified,
            'type', 'PRACTICE_EXAM',
            'duration_minutes', 130,
            'passing_score', 72,
            'max_attempts', 10,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '80 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '80 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Assessment 5: Leadership Self-Assessment
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'ASSESSMENT',
        'ASSESS-005',
        jsonb_build_object(
            'assessment_code', 'ASSESS-005',
            'assessment_name', 'Leadership Skills Self-Assessment',
            'description', '360-degree self-assessment of leadership skills including delegation, communication, and team management.',
            'course_id', v_course_leadership,
            'type', 'SELF_ASSESSMENT',
            'duration_minutes', 45,
            'passing_score', 60,
            'max_attempts', 1,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '40 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '40 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 5 assessments';
    
    -- ============================================================================
    -- 5. LEARNING PATHS (3 learning paths)
    -- ============================================================================
    RAISE NOTICE '5. Creating Learning Paths...';
    
    -- Learning Path 1: Full-Stack Developer Path
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'LEARNING_PATH',
        'LP-001',
        jsonb_build_object(
            'path_code', 'LP-001',
            'path_name', 'Full-Stack Developer Career Path',
            'description', 'Comprehensive learning path for becoming a full-stack developer, from fundamentals to advanced topics.',
            'target_role', 'FULL_STACK_DEVELOPER',
            'department_id', v_dept_engineering,
            'duration_weeks', 24,
            'total_hours', 200,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_java_fundamentals, 'order', 1, 'is_required', true),
                jsonb_build_object('course_id', v_course_react_advanced, 'order', 2, 'is_required', true),
                jsonb_build_object('course_id', v_course_agile_scrum, 'order', 3, 'is_required', false)
            ),
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '100 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '100 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Learning Path 2: Cloud Architect Path
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'LEARNING_PATH',
        'LP-002',
        jsonb_build_object(
            'path_code', 'LP-002',
            'path_name', 'Cloud Solutions Architect Career Path',
            'description', 'Path to becoming a cloud solutions architect with focus on AWS and DevOps.',
            'target_role', 'CLOUD_ARCHITECT',
            'department_id', v_dept_devops,
            'duration_weeks', 20,
            'total_hours', 180,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_aws_certified, 'order', 1, 'is_required', true),
                jsonb_build_object('course_id', v_course_devops_kubernetes, 'order', 2, 'is_required', true)
            ),
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '90 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Learning Path 3: Data Scientist Path
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'LEARNING_PATH',
        'LP-003',
        jsonb_build_object(
            'path_code', 'LP-003',
            'path_name', 'Data Scientist Career Path',
            'description', 'Comprehensive path covering data analysis, machine learning, and advanced analytics.',
            'target_role', 'DATA_SCIENTIST',
            'department_id', v_dept_engineering,
            'duration_weeks', 18,
            'total_hours', 160,
            'courses', jsonb_build_array(
                jsonb_build_object('course_id', v_course_python_datascience, 'order', 1, 'is_required', true)
            ),
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '75 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '75 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 3 learning paths';
    
    -- ============================================================================
    -- 6. SKILLS (8 technical and soft skills)
    -- ============================================================================
    RAISE NOTICE '6. Creating Skills...';
    
    -- Skill 1: Java Programming
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-001',
        jsonb_build_object(
            'skill_code', 'SKILL-001',
            'skill_name', 'Java Programming',
            'description', 'Proficiency in Java programming language, OOP principles, and Java ecosystem.',
            'category', 'TECHNICAL',
            'skill_type', 'TECHNICAL',
            'is_core', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '200 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 2: React Development
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-002',
        jsonb_build_object(
            'skill_code', 'SKILL-002',
            'skill_name', 'React Development',
            'description', 'Expertise in React framework, hooks, state management, and modern frontend development.',
            'category', 'TECHNICAL',
            'skill_type', 'TECHNICAL',
            'is_core', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '190 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '190 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 3: AWS Cloud Architecture
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-003',
        jsonb_build_object(
            'skill_code', 'SKILL-003',
            'skill_name', 'AWS Cloud Architecture',
            'description', 'Ability to design and implement scalable, secure cloud solutions on AWS.',
            'category', 'TECHNICAL',
            'skill_type', 'TECHNICAL',
            'is_core', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '180 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 4: Leadership
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-004',
        jsonb_build_object(
            'skill_code', 'SKILL-004',
            'skill_name', 'Leadership',
            'description', 'Ability to lead teams, delegate tasks, provide feedback, and drive results.',
            'category', 'SOFT_SKILLS',
            'skill_type', 'SOFT',
            'is_core', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '170 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '170 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 5: Agile/Scrum
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-005',
        jsonb_build_object(
            'skill_code', 'SKILL-005',
            'skill_name', 'Agile/Scrum Methodology',
            'description', 'Understanding and application of Agile principles and Scrum framework.',
            'category', 'SOFT_SKILLS',
            'skill_type', 'SOFT',
            'is_core', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '160 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '160 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 6: Python Data Science
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-006',
        jsonb_build_object(
            'skill_code', 'SKILL-006',
            'skill_name', 'Python Data Science',
            'description', 'Data analysis, visualization, and machine learning using Python libraries.',
            'category', 'TECHNICAL',
            'skill_type', 'TECHNICAL',
            'is_core', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '150 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '150 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 7: DevOps & Kubernetes
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-007',
        jsonb_build_object(
            'skill_code', 'SKILL-007',
            'skill_name', 'DevOps & Kubernetes',
            'description', 'Containerization, orchestration, CI/CD pipelines, and infrastructure automation.',
            'category', 'TECHNICAL',
            'skill_type', 'TECHNICAL',
            'is_core', false,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '140 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '140 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Skill 8: Security Awareness
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'SKILL',
        'SKILL-008',
        jsonb_build_object(
            'skill_code', 'SKILL-008',
            'skill_name', 'Security Awareness',
            'description', 'Understanding of security best practices, phishing prevention, and data protection.',
            'category', 'COMPLIANCE',
            'skill_type', 'SOFT',
            'is_core', true,
            'is_active', true,
            'status', 'ACTIVE',
            'created_date', CURRENT_DATE - INTERVAL '180 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 8 skills';
    
    -- ============================================================================
    -- 7. MENTORSHIP (3 mentorship programs)
    -- ============================================================================
    RAISE NOTICE '7. Creating Mentorship Programs...';
    
    -- Mentorship 1: Engineering Mentorship
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'MENTORSHIP',
        'MENTOR-001',
        jsonb_build_object(
            'mentorship_code', 'MENTOR-001',
            'mentorship_name', 'Engineering Mentorship Program',
            'description', 'Pair junior engineers with senior engineers for technical guidance and career development.',
            'mentor_id', v_emp_alex_chen,
            'department_id', v_dept_engineering,
            'duration_months', 6,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '120 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '120 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Mentorship 2: Leadership Mentorship
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'MENTORSHIP',
        'MENTOR-002',
        jsonb_build_object(
            'mentorship_code', 'MENTOR-002',
            'mentorship_name', 'Leadership Development Mentorship',
            'description', 'Pair emerging leaders with experienced managers for leadership skill development.',
            'mentor_id', v_emp_mike_johnson,
            'department_id', v_dept_hr,
            'duration_months', 12,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '100 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '100 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Mentorship 3: Sales Mentorship
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'MENTORSHIP',
        'MENTOR-003',
        jsonb_build_object(
            'mentorship_code', 'MENTOR-003',
            'mentorship_name', 'Sales Excellence Mentorship',
            'description', 'Pair new sales reps with experienced account executives for sales skills development.',
            'mentor_id', v_emp_michael_brown,
            'department_id', v_dept_sales,
            'duration_months', 6,
            'status', 'ACTIVE',
            'is_active', true,
            'created_date', CURRENT_DATE - INTERVAL '90 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '90 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 3 mentorship programs';
    
    -- ============================================================================
    -- 8. CATALOGS (2 course catalogs)
    -- ============================================================================
    RAISE NOTICE '8. Creating Catalogs...';
    
    -- Catalog 1: Technical Training Catalog
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'CATALOG',
        'CAT-001',
        jsonb_build_object(
            'catalog_code', 'CAT-001',
            'catalog_name', 'Technical Training Catalog 2025',
            'description', 'Complete catalog of technical courses for engineering and development teams.',
            'category', 'TECHNICAL',
            'courses', jsonb_build_array(
                v_course_java_fundamentals,
                v_course_react_advanced,
                v_course_aws_certified,
                v_course_python_datascience,
                v_course_devops_kubernetes
            ),
            'is_active', true,
            'status', 'PUBLISHED',
            'publish_date', CURRENT_DATE - INTERVAL '200 days',
            'valid_from', CURRENT_DATE - INTERVAL '200 days',
            'valid_until', CURRENT_DATE + INTERVAL '165 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '200 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    -- Catalog 2: Soft Skills & Leadership Catalog
    INSERT INTO ggj_kernel_objects (
        id, tenant_id, object_type_code, object_code, data, status, version,
        created_at, created_by, modified_at, modified_by
    ) VALUES (
        gen_random_uuid(),
        v_tenant_id,
        'CATALOG',
        'CAT-002',
        jsonb_build_object(
            'catalog_code', 'CAT-002',
            'catalog_name', 'Soft Skills & Leadership Catalog 2025',
            'description', 'Catalog of leadership, communication, and professional development courses.',
            'category', 'SOFT_SKILLS',
            'courses', jsonb_build_array(
                v_course_leadership,
                v_course_agile_scrum,
                v_course_security_awareness
            ),
            'is_active', true,
            'status', 'PUBLISHED',
            'publish_date', CURRENT_DATE - INTERVAL '180 days',
            'valid_from', CURRENT_DATE - INTERVAL '180 days',
            'valid_until', CURRENT_DATE + INTERVAL '185 days'
        ),
        'ACTIVE', 1,
        CURRENT_TIMESTAMP - INTERVAL '180 days', 'system@techcorp.com',
        CURRENT_TIMESTAMP, 'system@techcorp.com'
    );
    
    RAISE NOTICE '   Created 2 catalogs';
    
    -- ============================================================================
    -- COMPLETION SUMMARY
    -- ============================================================================
    RAISE NOTICE '';
    RAISE NOTICE '=== TECHCORP LEARNING PORTAL DATA SEEDED SUCCESSFULLY ===';
    RAISE NOTICE 'Courses: 8';
    RAISE NOTICE 'Training Plans: 3';
    RAISE NOTICE 'Certifications: 3';
    RAISE NOTICE 'Assessments: 5';
    RAISE NOTICE 'Learning Paths: 3';
    RAISE NOTICE 'Skills: 8';
    RAISE NOTICE 'Mentorship Programs: 3';
    RAISE NOTICE 'Catalogs: 2';
    RAISE NOTICE '';
    RAISE NOTICE 'All data references real TechCorp employees and departments from Workforce module.';
    RAISE NOTICE 'Data is ready for drill-down navigation and cross-module integration.';
    
END $$;
