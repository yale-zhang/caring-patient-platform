-- ============================================================
-- 演示种子数据（demo seed data）
-- 目标：让五端（患者/医生/助手/咨询/患者管理）都能登录并看到业务数据
--
-- 背景：caring_init.sql 建了 341 张表但只有 5 条 INSERT（且全是空权限表），
--       没有任何用户/租户/业务数据，导致服务起来后列表页全空、无法登录。
--
-- 幂等：全部使用 INSERT ... ON DUPLICATE KEY UPDATE，可重复执行。
-- 密码：MD5（与后端 SecureUtil.md5(password) 一致），统一 demo1234
-- 租户码：0000（对应 caring_base_0000 库）
-- 字段名均已对 information_schema.columns 实测核对
-- ============================================================

SET NAMES utf8mb4;
USE `caring_base_0000`;

-- ---------- 1. 租户 ----------
-- type 取值须为 TenantTypeEnum: CREATE / REGISTER
-- connect_type 取值须为 TenantConnectTypeEnum: LOCAL / REMOTE
-- status 取值须为 TenantStatusEnum: NORMAL / WAIT_INIT / FORBIDDEN / WAITING / REFUSE / DELETING
INSERT INTO `d_tenant`
  (`id`, `code`, `name`, `type`, `connect_type`, `status`, `readonly`, `duty`,
   `describe_`, `create_time`, `create_user`, `update_time`, `update_user`,
   `domain_name`, `wx_app_id`, `wx_status`, `sort`)
VALUES
  (1, '0000', '演示租户-慢病管理', 'REGISTER', 'LOCAL', 'NORMAL', b'0', '慢病管理演示',
   '演示用租户', NOW(), 1, NOW(), 1, 'localhost', 'wx_demo_app', 1, 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `status` = VALUES(`status`);

-- ---------- 2. OAuth 客户端（前端 Basic 头所需） ----------
-- 四个 legacy 端: Basic base64('zuihou_ui:zuihou_ui_secret')
-- 管理端:        Basic base64('caring_ui:caring_ui_secret')
INSERT INTO `c_auth_application`
  (`id`, `tenant_code`, `client_id`, `client_secret`, `website`, `name`, `icon`,
   `app_type`, `describe_`, `status`, `create_user`, `create_time`, `update_user`, `update_time`)
VALUES
  (1, '0000', 'caring_ui', 'caring_ui_secret', 'http://localhost:18082/caring-ui/',
   'SaaS微服务管理后台', '', 'PC', '内置', b'1', 1, NOW(), 1, NOW()),
  (2, '0000', 'caring_admin_ui', 'caring_admin_ui_secret', 'http://localhost:18082/caring-admin-ui/',
   'SaaS微服务超级管理后台', '', 'PC', '内置', b'1', 1, NOW(), 1, NOW()),
  (3, '0000', 'zuihou_ui', 'zuihou_ui_secret', 'http://localhost:18082/',
   '租户端统一客户端(患者/医生/助手/咨询)', '', 'PC', '内置', b'1', 1, NOW(), 1, NOW())
ON DUPLICATE KEY UPDATE `client_secret` = VALUES(`client_secret`), `status` = VALUES(`status`);

-- ---------- 3. 角色 ----------
INSERT INTO `c_auth_role`
  (`id`, `tenant_code`, `name`, `code`, `describe_`, `status`, `readonly`, `ds_type`,
   `create_user`, `create_time`, `update_user`, `update_time`)
VALUES
  (1, '0000', '租户管理员', 'TENANT_ADMIN', '租户管理员', b'1', b'0', 'TENANT', 1, NOW(), 1, NOW()),
  (2, '0000', '医生', 'DOCTOR', '医生角色', b'1', b'0', 'TENANT', 1, NOW(), 1, NOW()),
  (3, '0000', '护理/医助', 'NURSING', '护理医助角色', b'1', b'0', 'TENANT', 1, NOW(), 1, NOW()),
  (4, '0000', '患者', 'PATIENT', '患者角色', b'1', b'0', 'TENANT', 1, NOW(), 1, NOW())
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`);

-- ---------- 4. 租户账号 ----------
-- account: demo_admin / demo_doctor / demo_nurse / demo_patient
INSERT INTO `c_auth_user`
  (`id`, `tenant_code`, `account`, `name`, `org_id`, `readonly`, `email`, `mobile`, `sex`,
   `status`, `password`, `create_user`, `create_time`, `update_user`, `update_time`)
VALUES
  (1, '0000', 'demo_admin',   '演示管理员', NULL, b'0', 'demo_admin@example.com',   '13800000001', '1', b'1', MD5('demo1234'), 1, NOW(), 1, NOW()),
  (2, '0000', 'demo_doctor',  '张医生',     NULL, b'0', 'demo_doctor@example.com',  '13800000002', '1', b'1', MD5('demo1234'), 1, NOW(), 1, NOW()),
  (3, '0000', 'demo_nurse',   '李医助',     NULL, b'0', 'demo_nurse@example.com',   '13800000003', '2', b'1', MD5('demo1234'), 1, NOW(), 1, NOW()),
  (4, '0000', 'demo_patient', '王患者',     NULL, b'0', 'demo_patient@example.com', '13800000004', '1', b'1', MD5('demo1234'), 1, NOW(), 1, NOW())
ON DUPLICATE KEY UPDATE `password` = VALUES(`password`), `status` = VALUES(`status`);

INSERT INTO `d_global_user`
  (`id`, `tenant_code`, `account`, `mobile`, `name`, `email`, `password`, `readonly`,
   `create_time`, `create_user`, `update_time`, `update_user`, `global_user_type`,
   `login_time`, `user_deleted`, `first_login`)
VALUES
  (1, '0000', 'demo_admin',   '13800000001', '演示管理员', 'demo_admin@example.com',   MD5('demo1234'), b'0', NOW(), 1, NOW(), 1, 'TENANT', NOW(), 0, 1),
  (2, '0000', 'demo_doctor',  '13800000002', '张医生',     'demo_doctor@example.com',  MD5('demo1234'), b'0', NOW(), 1, NOW(), 1, 'TENANT', NOW(), 0, 1),
  (3, '0000', 'demo_nurse',   '13800000003', '李医助',     'demo_nurse@example.com',   MD5('demo1234'), b'0', NOW(), 1, NOW(), 1, 'TENANT', NOW(), 0, 1),
  (4, '0000', 'demo_patient', '13800000004', '王患者',     'demo_patient@example.com', MD5('demo1234'), b'0', NOW(), 1, NOW(), 1, 'TENANT', NOW(), 0, 1)
ON DUPLICATE KEY UPDATE `password` = VALUES(`password`), `name` = VALUES(`name`);

INSERT INTO `d_global_user_tenant`
  (`id`, `account_id`, `tenant_id`, `create_time`, `create_user`, `update_time`, `update_user`, `management_type`)
VALUES
  (1, 1, 1, NOW(), 1, NOW(), 1, 'OWNER'),
  (2, 2, 1, NOW(), 1, NOW(), 1, 'MEMBER'),
  (3, 3, 1, NOW(), 1, NOW(), 1, 'MEMBER'),
  (4, 4, 1, NOW(), 1, NOW(), 1, 'MEMBER')
ON DUPLICATE KEY UPDATE `management_type` = VALUES(`management_type`);

INSERT INTO `c_auth_user_role`
  (`id`, `tenant_code`, `role_id`, `user_id`, `create_user`, `create_time`)
VALUES
  (1, '0000', 1, 1, 1, NOW()),
  (2, '0000', 2, 2, 1, NOW()),
  (3, '0000', 3, 3, 1, NOW()),
  (4, '0000', 4, 4, 1, NOW())
ON DUPLICATE KEY UPDATE `role_id` = VALUES(`role_id`);

-- ---------- 5. 医生（u_user_doctor） ----------
INSERT INTO `u_user_doctor`
  (`id`, `name`, `group_id`, `group_name`, `org_id`, `province`, `city`, `hospital_id`,
   `department_id`, `title`, `mobile`, `hospital_name`, `deptartment_name`,
   `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`,
   `password`, `login_name`, `sex`)
VALUES
  (1, '张医生', NULL, '演示医生组', NULL, '北京市', '北京市', 1, '1', '主任医师',
   '4A+VLu6yV6Z5Bhv5/fezSA==', '演示市第一人民医院', '内分泌科', '0000', NOW(), 1, NOW(), 1,
   MD5('demo1234'), 'demo_doctor', 1),
  (2, '刘医生', NULL, '演示医生组', NULL, '上海市', '上海市', 1, '2', '副主任医师',
   '7LNKktwfH5JZmB/YyOj+Dg==', '演示市中心医院', '心内科', '0000', NOW(), 1, NOW(), 1,
   MD5('demo1234'), 'demo_doctor2', 1)
ON DUPLICATE KEY UPDATE `mobile` = VALUES(`mobile`), `name` = VALUES(`name`);

-- ---------- 6. 护理/医助（u_user_nursing_staff） ----------
INSERT INTO `u_user_nursing_staff`
  (`id`, `name`, `login_name`, `mobile`, `org_id`, `sex`, `tenant_code`,
   `create_time`, `create_user`, `update_time`, `update_user`, `password`)
VALUES
  (1, '李医助', 'demo_nurse', 'p5+lM5uorkRqn/WuPQlv9w==', NULL, 2, '0000', NOW(), 1, NOW(), 1, MD5('demo1234'))
ON DUPLICATE KEY UPDATE `mobile` = VALUES(`mobile`), `name` = VALUES(`name`);

-- ---------- 7. 患者（u_user_patient） ----------
INSERT INTO `u_user_patient`
  (`id`, `name`, `nick_name`, `mobile`, `sex`, `birthday`, `group_id`, `group_name`,
   `doctor_id`, `doctor_name`, `status_`, `diagnosis_name`, `tenant_code`,
   `height`, `weight`, `hospital_name`, `create_time`, `create_user`, `update_time`, `update_user`,
   `password`, `service_advisor_id`, `service_advisor_name`)
VALUES
  (1, '王患者', '小王', 'UWFa3gPyzCVBkU9T+tnEGg==', 1, '1985-05-12', NULL, '演示患者组',
   1, '张医生', 1, '2型糖尿病', '0000', 172, 68, '演示市第一人民医院',
   NOW(), 1, NOW(), 1, MD5('demo1234'), 1, '李医助'),
  (2, '陈患者', '小陈', 'ykz5hDIIv0sJeY8tuedxvQ==', 2, '1978-11-03', NULL, '演示患者组',
   1, '张医生', 1, '高血压', '0000', 165, 72, '演示市第一人民医院',
   NOW(), 1, NOW(), 1, MD5('demo1234'), 1, '李医助'),
  (3, '赵患者', '小赵', 'HqvsSVr/U5GUzlRSPjBkng==', 1, '1990-08-20', NULL, '演示患者组',
   2, '刘医生', 1, '冠心病', '0000', 178, 80, '演示市中心医院',
   NOW(), 1, NOW(), 1, MD5('demo1234'), 1, '李医助')
ON DUPLICATE KEY UPDATE `mobile` = VALUES(`mobile`), `name` = VALUES(`name`), `diagnosis_name` = VALUES(`diagnosis_name`);

-- ---------- 8. 医生-患者分组（管理端/助手端患者列表） ----------
INSERT INTO `u_user_doctor_custom_group`
  (`id`, `group_name`, `doctor_id`, `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`)
VALUES
  (1, '演示医生组', 1, '0000', NOW(), 1, NOW(), 1),
  (2, '演示医生组2', 2, '0000', NOW(), 1, NOW(), 1)
ON DUPLICATE KEY UPDATE `group_name` = VALUES(`group_name`);

INSERT INTO `u_user_doctor_custom_group_patient`
  (`id`, `doctor_custom_group_id`, `patient_id`, `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`)
VALUES
  (1, 1, 1, '0000', NOW(), 1, NOW(), 1),
  (2, 1, 2, '0000', NOW(), 1, NOW(), 1),
  (3, 2, 3, '0000', NOW(), 1, NOW(), 1)
ON DUPLICATE KEY UPDATE `patient_id` = VALUES(`patient_id`);

-- ---------- 9. CMS 文章（患者端资讯列表） ----------
INSERT INTO `t_cms_article_news`
  (`id`, `title`, `content`, `digest`, `author`, `tenant_code`,
   `create_time`, `create_user`, `update_time`, `update_user`, `thumb_media_url`)
VALUES
  (1, '糖尿病患者如何科学管理血糖', '糖尿病患者应定时监测血糖，遵循医嘱调整饮食与运动，规律作息有助于稳定血糖水平。', '糖尿病日常管理要点', '张医生', '0000', NOW(), 1, NOW(), 1, ''),
  (2, '高血压日常血压监测要点', '每日固定时间测量血压并记录，有助于医生调整用药方案，避免血压波动带来的风险。', '血压监测指南', '刘医生', '0000', NOW(), 1, NOW(), 1, ''),
  (3, '慢病患者冬季防护提示', '气温骤降时慢病患者需注意保暖，规律作息与适量运动有助于减少急性发作。', '冬季健康提示', '李医助', '0000', NOW(), 1, NOW(), 1, '')
ON DUPLICATE KEY UPDATE `title` = VALUES(`title`), `digest` = VALUES(`digest`);

-- ---------- 10. 用药记录（患者端用药列表） ----------
INSERT INTO `t_patient_drugs`
  (`id`, `patient_id`, `medicine_name`, `dose`, `unit`, `cycle`, `end_time`, `status`,
   `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`,
   `start_take_medicine_date`, `number_of_day`)
VALUES
  (1, 1, '二甲双胍缓释片', 0.5, 'g', 2, '2026-12-01', 1, '0000', NOW(), 1, NOW(), 1, '2026-11-01', 30),
  (2, 1, '阿卡波糖片', 50, 'mg', 3, '2026-12-01', 1, '0000', NOW(), 1, NOW(), 1, '2026-11-01', 30),
  (3, 2, '苯磺酸氨氯地平片', 5, 'mg', 1, '2026-12-05', 1, '0000', NOW(), 1, NOW(), 1, '2026-11-05', 30)
ON DUPLICATE KEY UPDATE `medicine_name` = VALUES(`medicine_name`), `dose` = VALUES(`dose`);

-- ---------- 11. 护理计划（助手端计划列表） ----------
INSERT INTO `t_nursing_plan`
  (`id`, `name_`, `status_`, `project_id`, `type_`, `is_admin_template`, `execute_`,
   `effective_time`, `plan_type`, `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`,
   `system_template`, `plan_desc`, `plan_icon`)
VALUES
  (1, '糖尿病饮食管理计划', 1, NULL, 1, 0, 1, 30, 1, '0000', NOW(), 1, NOW(), 1, 1, '控制每日总热量摄入，规律三餐', 'plan_1'),
  (2, '高血压服药依从性计划', 1, NULL, 1, 0, 1, 30, 1, '0000', NOW(), 1, NOW(), 1, 1, '每日按时服药并记录血压值', 'plan_2')
ON DUPLICATE KEY UPDATE `name_` = VALUES(`name_`), `plan_desc` = VALUES(`plan_desc`);

INSERT INTO `t_nursing_plan_detail`
  (`id`, `execute_`, `content`, `nursing_plan_id`, `type_`, `num`, `diet_type`,
   `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`, `push_type`)
VALUES
  (1, 1, '每日主食控制在 200g 以内，优选粗粮', 1, 1, 30, NULL, '0000', NOW(), 1, NOW(), 1, 1),
  (2, 1, '每餐后 30 分钟散步 20 分钟', 1, 2, 30, NULL, '0000', NOW(), 1, NOW(), 1, 1),
  (3, 1, '晨起测量血压并记录到健康档案', 2, 1, 30, NULL, '0000', NOW(), 1, NOW(), 1, 1)
ON DUPLICATE KEY UPDATE `content` = VALUES(`content`);

-- ---------- 12. 患者订阅护理计划 ----------
INSERT INTO `t_patient_nursing_plan`
  (`id`, `patient_id`, `nursing_plant_id`, `start_date`, `is_subscribe`, `tenant_code`,
   `create_time`, `create_user`, `update_time`, `update_user`, `patient_cancel_subscribe`)
VALUES
  (1, 1, 1, '2026-11-01', 1, '0000', NOW(), 1, NOW(), 1, 0),
  (2, 2, 2, '2026-11-05', 1, '0000', NOW(), 1, NOW(), 1, 0)
ON DUPLICATE KEY UPDATE `patient_id` = VALUES(`patient_id`), `is_subscribe` = VALUES(`is_subscribe`);

-- ---------- 13. 会诊小组（咨询端列表） ----------
INSERT INTO `u_consultation_group`
  (`id`, `group_name`, `group_desc`, `doctor_id`, `nurse_id`, `tenant_code`,
   `create_time`, `create_user`, `update_time`, `update_user`, `consultation_status`, `continued`)
VALUES
  (1, '演示会诊小组A', '演示用会诊小组，覆盖糖尿病与高血压患者', 1, 1, '0000', NOW(), 1, NOW(), 1, 'ON', 1),
  (2, '演示会诊小组B', '演示用会诊小组，覆盖冠心病患者', 2, 1, '0000', NOW(), 1, NOW(), 1, 'ON', 1)
ON DUPLICATE KEY UPDATE `group_name` = VALUES(`group_name`), `group_desc` = VALUES(`group_desc`);

INSERT INTO `u_consultation_group_member`
  (`id`, `consultation_group_id`, `member_name`, `member_role`, `member_status`, `patient_id`,
   `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`, `mobile`)
VALUES
  (1, 1, '张医生', 'DOCTOR', 1, 1, '0000', NOW(), 1, NOW(), 1, '13800000002'),
  (2, 1, '刘医生', 'DOCTOR', 1, NULL, '0000', NOW(), 1, NOW(), 1, '13800000005'),
  (3, 1, '李医助', 'NURSING', 1, NULL, '0000', NOW(), 1, NOW(), 1, '13800000003'),
  (4, 1, '王患者', 'PATIENT', 1, 1, '0000', NOW(), 1, NOW(), 1, '13800000004')
ON DUPLICATE KEY UPDATE `member_name` = VALUES(`member_name`);

-- ---------- 14. 每日用药统计（患者端依从性图表） ----------
INSERT INTO `t_patient_day_drugs`
  (`id`, `patient_id`, `drugs_count_of_day`, `take_drugs_count_of_day`, `checkined_number`,
   `checkin_number_total`, `status`, `day_compliance`, `doctor_id`, `service_advisor_id`,
   `tenant_code`, `create_time`, `create_user`, `update_time`, `update_user`)
VALUES
  (1, 1, 5, 4, 4, 5, 1, 80, 1, 1, '0000', NOW(), 1, NOW(), 1),
  (2, 2, 1, 1, 1, 1, 1, 100, 1, 1, '0000', NOW(), 1, NOW(), 1),
  (3, 3, 2, 0, 0, 2, 0, 0, 2, 1, '0000', NOW(), 1, NOW(), 1)
ON DUPLICATE KEY UPDATE `drugs_count_of_day` = VALUES(`drugs_count_of_day`), `day_compliance` = VALUES(`day_compliance`);

-- ---------- 15. 患者管理端菜单 ----------
INSERT INTO `t_patient_manage_menu`
  (`id`, `name`, `icon`, `menu_sort`, `show_status`, `menu_type`, `tenant_code`,
   `create_time`, `create_user`, `update_time`, `update_user`)
VALUES
  (1, '异常数据', 'abnormal', 1, 1, 'MENU', '0000', NOW(), 1, NOW(), 1),
  (2, '信息完整度', 'integrity', 2, 1, 'MENU', '0000', NOW(), 1, NOW(), 1),
  (3, '用药预警', 'medication', 3, 1, 'MENU', '0000', NOW(), 1, NOW(), 1),
  (4, '监测数据', 'monitor', 4, 1, 'MENU', '0000', NOW(), 1, NOW(), 1),
  (5, '信息统计', 'statistics', 5, 1, 'MENU', '0000', NOW(), 1, NOW(), 1)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `menu_sort` = VALUES(`menu_sort`);
