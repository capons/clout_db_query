-- phpMyAdmin SQL Dump
-- version 4.4.15.7
-- http://www.phpmyadmin.net
--
-- Хост: 192.168.0.130:3306
-- Время создания: Сен 05 2016 г., 15:11
-- Версия сервера: 5.6.31
-- Версия PHP: 5.6.23

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `clout_v1_3iam`
--

-- --------------------------------------------------------

--
-- Структура таблицы `activity_log`
--

CREATE TABLE IF NOT EXISTS `activity_log` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `activity_code` varchar(100) NOT NULL,
  `result` varchar(100) NOT NULL,
  `uri` varchar(300) NOT NULL,
  `log_details` text NOT NULL,
  `device` varchar(200) NOT NULL,
  `ip_address` varchar(100) NOT NULL,
  `event_time` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `permissions`
--

CREATE TABLE IF NOT EXISTS `permissions` (
  `id` bigint(20) NOT NULL,
  `code` varchar(100) NOT NULL,
  `display` varchar(300) NOT NULL,
  `details` varchar(300) NOT NULL,
  `category` varchar(100) NOT NULL,
  `url` varchar(300) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `permissions`
--

INSERT INTO `permissions` (`id`, `code`, `display`, `details`, `category`, `url`, `status`) VALUES
(1, 'can_login', 'Can Login', 'Can Login - The default access right for any user', 'access', '', 'active'),
(2, 'can_view_checkin_perks', 'Can view checkin perks', 'Can view checkin perks', 'search', '', 'active'),
(3, 'can_view_reservation_perks', 'Can view reservation perks', 'Can view reservation perks', 'search', '', 'active'),
(4, 'can_view_cashback', 'Can view cashback', 'Can view cashback', 'search', '', 'active'),
(5, 'can_view_invite_tools', 'Can view invite tools', 'Can view invite tools', 'network', '', 'active'),
(6, 'can_send_message', 'Can Send Message', 'Can Send Message', 'messages', '', 'active'),
(7, 'can_view_my_commission_network', 'Can View My Commission Network', 'Can View My Commission Network', 'network', '', 'active'),
(8, 'can_create_custom_referral_url', 'Can Create Custom Referral URL', 'Can Create Custom Referral URL', 'network', '', 'active'),
(9, 'can_generate_referral_button', 'Can Generate Referral Button', 'Can Generate Referral Button', 'network', '', 'active'),
(10, 'can_add_repository_tag', 'Can Add Repository Tag', 'Can Add Repository Tag', 'access', '', 'active');

-- --------------------------------------------------------

--
-- Структура таблицы `permission_groups`
--

CREATE TABLE IF NOT EXISTS `permission_groups` (
  `id` bigint(20) NOT NULL,
  `_default_permission` bigint(20) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `notes` varchar(300) NOT NULL,
  `group_type` enum('clout_owner','clout_admin_user','store_owner_owner','store_owner_admin_user','invited_shopper','random_shopper') NOT NULL DEFAULT 'random_shopper',
  `group_category` enum('admin','store_owner','shopper') NOT NULL DEFAULT 'shopper',
  `is_removable` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_system_only` enum('Y','N') NOT NULL DEFAULT 'Y',
  `status` enum('active','inactive') NOT NULL DEFAULT 'inactive',
  `date_entered` datetime NOT NULL,
  `entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `permission_groups`
--

INSERT INTO `permission_groups` (`id`, `_default_permission`, `name`, `notes`, `group_type`, `group_category`, `is_removable`, `is_system_only`, `status`, `date_entered`, `entered_by`, `last_updated`, `last_updated_by`) VALUES
(1, 1, 'Clout Owner', 'The Default Clout Owner Group', 'clout_owner', 'admin', 'N', 'Y', 'active', '2015-07-24 00:00:00', 1, '2016-05-16 15:20:13', 1),
(2, 1, 'Clout Admin User', 'The Default Clout Admin User Group', 'clout_admin_user', 'admin', 'N', 'Y', 'active', '2015-08-27 15:30:29', 1, '2016-05-02 14:49:07', 1),
(3, 1, 'Store Owner Owner', 'The Default Store Owner Owner Group', 'store_owner_owner', 'store_owner', 'N', 'Y', 'active', '2015-08-27 15:31:33', 1, '2015-08-27 15:31:33', 1),
(4, 1, 'Store Owner Admin', 'The Default Store Owner Admin User', 'store_owner_admin_user', 'store_owner', 'N', 'Y', 'active', '2015-08-27 15:31:33', 1, '2015-12-03 12:47:35', 1),
(5, 1, 'Invited Shopper', 'The Default Invited Shopper Group', 'invited_shopper', 'shopper', 'N', 'Y', 'active', '2015-07-24 00:00:00', 1, '2016-05-02 14:48:16', 1),
(6, 1, 'Random Shopper', 'The Default Random Shopper Group', 'random_shopper', 'shopper', 'N', 'Y', 'active', '2015-07-24 00:00:00', 1, '2016-02-29 20:03:11', 1),
(7, 1, 'Store Data Entry', 'Clout Data Entry', 'store_owner_admin_user', 'store_owner', 'Y', 'Y', 'active', '2016-01-08 09:40:00', 1, '2016-01-08 11:29:49', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `permission_group_mapping_permissions`
--

CREATE TABLE IF NOT EXISTS `permission_group_mapping_permissions` (
  `id` bigint(20) NOT NULL,
  `_group_id` bigint(20) DEFAULT NULL,
  `_permission_id` bigint(20) DEFAULT NULL,
  `entered_by` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=96 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `permission_group_mapping_permissions`
--

INSERT INTO `permission_group_mapping_permissions` (`id`, `_group_id`, `_permission_id`, `entered_by`, `date_entered`) VALUES
(3, 3, 1, 1, '2015-08-27 15:31:33'),
(21, 4, 1, 1, '2015-12-03 12:47:35'),
(60, 7, 1, 1, '2016-01-08 09:51:13'),
(68, 6, 1, 1, '2016-02-29 20:03:11'),
(69, 6, 6, 1, '2016-02-29 20:03:11'),
(91, 5, 1, 1, '2016-05-02 14:48:16'),
(92, 5, 2, 1, '2016-05-02 14:48:16'),
(93, 5, 3, 1, '2016-05-02 14:48:16'),
(94, 5, 4, 1, '2016-05-02 14:48:16'),
(95, 5, 5, 1, '2016-05-02 14:48:16');

-- --------------------------------------------------------

--
-- Структура таблицы `permission_group_mapping_rules`
--

CREATE TABLE IF NOT EXISTS `permission_group_mapping_rules` (
  `id` bigint(20) NOT NULL,
  `_group_id` bigint(20) DEFAULT NULL,
  `_rule_id` bigint(20) DEFAULT NULL,
  `entered_by` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=75 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `permission_group_mapping_rules`
--

INSERT INTO `permission_group_mapping_rules` (`id`, `_group_id`, `_rule_id`, `entered_by`, `date_entered`) VALUES
(5, 3, 1, 1, '2015-08-27 15:34:10'),
(6, 3, 4, 1, '2015-08-27 15:34:10'),
(24, 4, 3, 1, '2015-12-03 12:47:35'),
(25, 4, 4, 1, '2015-12-03 12:47:35'),
(36, 7, 3, 1, '2016-01-08 09:51:13'),
(40, 6, 1, 1, '2016-02-29 20:03:11'),
(47, 2, 1, 1, '2016-05-02 14:49:08'),
(48, 2, 4, 1, '2016-05-02 14:49:08'),
(74, 1, 3, 1, '2016-05-16 15:20:13');

-- --------------------------------------------------------

--
-- Структура таблицы `queries`
--

CREATE TABLE IF NOT EXISTS `queries` (
  `id` bigint(20) NOT NULL,
  `code` varchar(300) NOT NULL,
  `details` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `queries`
--

INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(1, 'check_user_by_username', 'SELECT * FROM `clout_v1_3iam`.user_access WHERE user_name=''_USER_NAME_'' AND password=''_PASSWORD_'''),
(2, 'get_users_in_group_type', 'SELECT A.user_id\nFROM`clout_v1_3iam`.user_access A \nLEFT JOIN `clout_v1_3iam`.permission_groups G ON (G.id=A.permission_group_id)\nWHERE G.group_type IN (''_GROUP_TYPE_'') _LIMIT_TEXT_'),
(3, 'save_access_details', 'INSERT INTO `clout_v1_3iam`.user_access (user_id, permission_group_id, user_name, password, last_updated) VALUES (''_USER_ID_'', ''_PERMISSION_GROUP_ID_'', ''_USER_NAME_'', ''_PASSWORD_'', NOW())'),
(4, 'update_user_password', 'UPDATE `clout_v1_3iam`.user_access DEST, \r\n(SELECT ''_PASSWORD_'' AS password, password AS old_password_1, old_password_1 AS old_password_2, NOW() AS last_updated FROM `clout_v1_3iam`.user_access WHERE user_id=''_USER_ID_'') SRC \r\nSET DEST.password=SRC.password, DEST.old_password_1=SRC.old_password_1, DEST.old_password_2=SRC.old_password_2, DEST.last_updated=SRC.last_updated \r\nWHERE user_id=''_USER_ID_'''),
(5, 'update_user_group_mapping', 'UPDATE `clout_v1_3iam`.user_access SET permission_group_id=''_NEW_GROUP_ID_'', last_updated=NOW() WHERE user_id IN (''_USER_ID_LIST_'')'),
(6, 'get_permission_group_list', 'SELECT A.*, CONCAT(IF(A.permission_string <> '''', CONCAT(''PERMISSIONS: '', A.permission_string), ''''),'' '', IF(A.rule_string <> '''', CONCAT(''RULES: '', A.rule_string), '''')) AS permission_summary \r\nFROM \r\n(SELECT G.id AS group_id, G.is_removable, \r\nG.name AS group_name, \r\n\r\n(SELECT GROUP_CONCAT(DISTINCT CONCAT(REPLACE(P.category, ''_'', '' ''), '' ('',\r\n	(SELECT COUNT(_permission_id) FROM clout_v1_3iam.permission_group_mapping_permissions PM1 \r\n		LEFT JOIN clout_v1_3iam.permissions P1 ON (PM1._permission_id=P1.id) WHERE PM1._group_id=PM._group_id AND P1.category=P.category),\r\n	'' permissions)'') SEPARATOR '', '')\r\nFROM clout_v1_3iam.permission_group_mapping_permissions PM LEFT JOIN clout_v1_3iam.permissions P ON (PM._permission_id=P.id)\r\nWHERE PM._group_id=G.id) AS permission_string, \r\n\r\n(SELECT GROUP_CONCAT(DISTINCT CONCAT(REPLACE(R.category, ''_'', '' ''), '' ('',\r\n	(SELECT COUNT(_rule_id) FROM clout_v1_3iam.permission_group_mapping_rules RM1 \r\n		LEFT JOIN clout_v1_3iam.rules R1 ON (RM1._rule_id=R1.id) WHERE RM1._group_id=RM._group_id AND R1.category=R.category),\r\n	'' rules)'') SEPARATOR '', '')\r\nFROM clout_v1_3iam.permission_group_mapping_rules RM LEFT JOIN clout_v1_3iam.rules R ON (RM._rule_id=R.id)\r\nWHERE RM._group_id=G.id) AS rule_string, \r\n\r\n(SELECT COUNT(DISTINCT user_id) FROM clout_v1_3iam.user_access WHERE permission_group_id=G.id) AS user_count, \r\n\r\nG.`status`\r\nFROM clout_v1_3iam.permission_groups G\r\nWHERE 1=1 _PHRASE_CONDITION_ _CATEGORY_CONDITION_ \r\n_LIMIT_TEXT_) A'),
(7, 'get_permission_list', 'SELECT P.id AS permission_id, P.code, P.display AS name, P.details AS description, P.category, P.url, P.status FROM clout_v1_3iam.permissions P \r\nWHERE 1=1 _PHRASE_CONDITION_ \r\n_LIMIT_TEXT_'),
(8, 'get_rule_category_list', 'SELECT * FROM (\nSELECT DISTINCT category, cap_first_letter_in_words(REPLACE(category, ''_'', '' '')) AS category_display FROM clout_v1_3iam.rules WHERE user_type <> ''system'') A WHERE 1=1 _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(9, 'get_rule_name_list', 'SELECT id, code, display AS name, category, cap_first_letter_in_words(REPLACE(category, ''_'', '' '')) AS category_display, status FROM clout_v1_3iam.rules WHERE user_type <> ''system'' _CATEGORY_CONDITION_ _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(10, 'get_group_by_id', 'SELECT id, name, group_type, group_category, is_removable FROM clout_v1_3iam.`permission_groups` WHERE id=''_GROUP_ID_'''),
(11, 'get_group_rules', 'SELECT R.id, R.code, R.display AS name, R.category, cap_first_letter_in_words(REPLACE(R.category, ''_'', '' '')) AS category_display, R.status FROM clout_v1_3iam.permission_group_mapping_rules M LEFT JOIN clout_v1_3iam.rules R ON (M._rule_id=R.id) WHERE M._group_id=''_GROUP_ID_'''),
(12, 'get_group_permissions', 'SELECT P.id AS permission_id, P.code, P.display AS name, P.details AS description, P.category, P.url, P.status FROM \r\nclout_v1_3iam.permission_group_mapping_permissions M \r\nLEFT JOIN clout_v1_3iam.permissions P ON (M._permission_id=P.id)\r\nWHERE M._group_id=''_GROUP_ID_'''),
(13, 'add_permission_group', 'INSERT IGNORE INTO clout_v1_3iam.permission_groups (name, notes, group_type, group_category, _default_permission, is_removable, status, date_entered, entered_by, last_updated, last_updated_by) VALUES \n\n(''_NAME_'', ''_NAME_'', ''_GROUP_TYPE_'', ''_GROUP_CATEGORY_'', ''1'', ''_IS_REMOVABLE_'', ''_STATUS_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'')'),
(14, 'update_permission_group', 'UPDATE clout_v1_3iam.permission_groups SET name=''_NAME_'', group_type=''_GROUP_TYPE_'', last_updated_by=''_USER_ID_'', last_updated=NOW() WHERE id=''_GROUP_ID_'''),
(15, 'delete_group_permissions', 'DELETE FROM clout_v1_3iam.`permission_group_mapping_permissions` WHERE _group_id=''_GROUP_ID_'''),
(16, 'add_group_permissions', 'INSERT IGNORE INTO clout_v1_3iam.`permission_group_mapping_permissions` (_group_id, _permission_id, entered_by, date_entered) \n\n(SELECT ''_GROUP_ID_'' AS _group_id, P.id AS _permission_id, ''_USER_ID_'' AS entered_by, NOW() AS date_entered FROM clout_v1_3iam.permissions P WHERE P.id IN (''_PERMISSION_IDS_''))'),
(17, 'delete_group_rules', 'DELETE FROM clout_v1_3iam.`permission_group_mapping_rules` WHERE _group_id=''_GROUP_ID_'''),
(18, 'add_group_rules', 'INSERT IGNORE INTO clout_v1_3iam.`permission_group_mapping_rules` (_group_id, _rule_id, entered_by, date_entered) \r\n\r\n(SELECT ''_GROUP_ID_'' AS _group_id, R.id AS _rule_id, ''_USER_ID_'' AS entered_by, NOW() AS date_entered FROM clout_v1_3iam.rules R WHERE R.id IN (''_RULE_IDS_''))'),
(19, 'update_permission_group_status', 'UPDATE clout_v1_3iam.`permission_groups` SET status=''_STATUS_'', last_updated_by=''_USER_ID_'', last_updated=NOW() WHERE id=''_GROUP_ID_'''),
(20, 'get_rule_settings_list', 'SELECT R.id AS rule_id, R.user_type, R.code, R.display AS name, R.details AS description, R.category,  R.status, \r\n\r\n(SELECT COUNT(DISTINCT UA.user_id) FROM clout_v1_3iam.permission_group_mapping_rules MR \r\nLEFT JOIN clout_v1_3iam.user_access UA ON (MR._group_id=UA.permission_group_id)\r\nWHERE MR._rule_id=R.id) AS user_count, \r\n\r\n(SELECT cap_first_letter_in_words(REPLACE(GROUP_CONCAT(DISTINCT group_type SEPARATOR '', ''), ''_'', '' '')) FROM clout_v1_3iam.permission_group_mapping_rules MR \r\nLEFT JOIN clout_v1_3iam.permission_groups G ON (MR._group_id=G.id)\r\nWHERE MR._rule_id=R.id) AS user_groups\r\n\r\nFROM clout_v1_3iam.rules R \r\nWHERE 1=1 _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(21, 'update_rule_setting_status', 'UPDATE clout_v1_3iam.rules SET status=''_STATUS_'' WHERE id=''_RULE_ID_'''),
(22, 'get_rule_setting', 'SELECT * FROM clout_v1_3iam.rules WHERE id=''_RULE_ID_'''),
(23, 'update_setting_value', 'UPDATE clout_v1_3iam.rules SET details=REPLACE(details, ''_PREVIOUS_VALUE_STRING_'', ''_NEW_VALUE_STRING_'') WHERE id=''_SETTING_ID_'''),
(24, 'get_user_group_types', 'SELECT DISTINCT G.group_type FROM clout_v1_3iam.user_access A LEFT JOIN clout_v1_3iam.permission_groups G ON (A.permission_group_id=G.id) WHERE A.user_id=''_USER_ID_'''),
(25, 'get_user_permissions', 'SELECT P.code AS permission_code, P.category FROM clout_v1_3iam.user_access A \r\nLEFT JOIN clout_v1_3iam.permission_group_mapping_permissions PM ON (A.permission_group_id=PM._group_id) \r\nLEFT JOIN clout_v1_3iam.permissions P ON (PM._permission_id=P.id) \r\n\r\nWHERE A.user_id=''_USER_ID_'''),
(26, 'get_user_rules', 'SELECT R.code AS rule_code FROM clout_v1_3iam.user_access A \r\nLEFT JOIN clout_v1_3iam.permission_group_mapping_rules RM ON (A.permission_group_id=RM._group_id) \r\nLEFT JOIN clout_v1_3iam.rules R ON (RM._rule_id=R.id) \r\n\r\nWHERE A.user_id=''_USER_ID_'''),
(27, 'get_rule_by_code', 'SELECT id AS rule_id, user_type, details FROM clout_v1_3iam.rules WHERE code=''_CODE_'' AND status=''active'''),
(28, 'add_user_permission_group', 'INSERT INTO clout_v1_3iam.user_access (user_id, permission_group_id, user_name, password, last_updated) \n(SELECT ''_USER_ID_'' AS user_id, G.id AS permission_group_id, ''_USER_NAME_'' AS user_name, ''_PASSWORD_'' AS password, NOW() AS last_updated FROM clout_v1_3iam.permission_groups G WHERE LOWER(G.name)=LOWER(''_GROUP_NAME_''))\n\nON DUPLICATE KEY UPDATE password=VALUES(password), last_updated=VALUES(last_updated)'),
(29, 'get_user_settings', 'SELECT _FIELDS_ FROM (\r\nSELECT UNIX_TIMESTAMP(last_updated) AS passwordLastUpdated,\r\n\r\nIFNULL((SELECT G.name FROM clout_v1_3iam.permission_groups G WHERE G.id=U.permission_group_id LIMIT 1),'''') AS groupName,\r\n\r\nIFNULL((SELECT G.group_type FROM clout_v1_3iam.permission_groups G WHERE G.id=U.permission_group_id LIMIT 1),'''') AS groupType,\r\n\r\nU.permission_group_id AS groupId\r\n\r\nFROM user_access U WHERE U.user_id=''_USER_ID_''\r\n) A '),
(30, 'is_rule_applied_to_user', 'SELECT \nIF((SELECT PR._rule_id FROM clout_v1_3iam.permission_group_mapping_rules PR \nLEFT JOIN clout_v1_3iam.user_access UA ON (UA.permission_group_id=PR._group_id)\nWHERE PR._rule_id=''_RULE_ID_'' AND UA.user_id=''_USER_ID_''\n) IS NOT NULL, ''Y'', ''N'') AS is_applied'),
(31, 'remove_user_permission_group', 'DELETE FROM user_access WHERE user_id=''_USER_ID_'''),
(32, 'delete_permission_group_rules', 'DELETE FROM `clout_v1_3iam`.permission_group_mapping_rules WHERE _group_id=''_GROUP_ID_'''),
(33, 'delete_permission_group_permissions', 'DELETE FROM `clout_v1_3iam`.permission_group_mapping_permissions WHERE _group_id=''_GROUP_ID_'''),
(34, 'delete_permission_group', 'DELETE FROM `clout_v1_3iam`.permission_groups WHERE id=''_GROUP_ID_'''),
(35, 'set_user_access_group_by_field', 'UPDATE `clout_v1_3iam`.user_access SET permission_group_id=''_GROUP_ID_'' WHERE _FIELD_NAME_=''_FIELD_VALUE_'''),
(36, 'get_user_view_details', 'SELECT * FROM view__user_details_iam WHERE user_id IN (''_ID_LIST_'')'),
(39, 'get_user_email', 'SELECT user_name AS email_address FROM user_access WHERE user_id=''_USER_ID_'''),
(40, 'get_user_permission_types', 'SELECT A.user_id, G.group_type AS type FROM clout_v1_3iam.user_access A LEFT JOIN clout_v1_3iam.permission_groups G ON (A.permission_group_id=G.id) WHERE user_id IN (''_USER_IDS_'') _ORDER_CONDITION_'),
(41, 'update_user_access_by_group_name', 'UPDATE clout_v1_3iam.user_access SET \n\npermission_group_id = (SELECT id FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1), \n\nlast_updated=NOW()\n\nWHERE user_id = ''_USER_ID_'' \nAND (SELECT id FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1) IS NOT NULL'),
(42, 'update_user_type_by_group_name', 'UPDATE user_security_settings SET user_type = (SELECT group_type FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1), \n\nlast_updated=NOW()\n\nWHERE _user_id = ''_USER_ID_'' \nAND (SELECT group_type FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1) IS NOT NULL'),
(43, 'filter_users_by_group_name', 'SELECT DISTINCT A.user_id\r\nFROM user_access A \r\nLEFT JOIN permission_groups G ON (A.permission_group_id=G.id)\r\nWHERE LOWER(G.name) = LOWER(''_GROUP_NAME_'') AND A.user_id IN (''_ID_LIST_'')'),
(44, 'get_group_by_name', 'SELECT id, name, group_type, is_removable FROM clout_v1_3iam.`permission_groups` WHERE LOWER(name) = LOWER(''_GROUP_NAME_'')'),
(45, 'delete_activity_log', 'DELETE FROM activity_log WHERE user_id=''_USER_ID_'''),
(46, 'delete_security_answers', 'DELETE FROM security_answers WHERE user_id=''_USER_ID_'''),
(47, 'delete_user_access', 'DELETE FROM user_access WHERE user_id=''_USER_ID_'''),
(48, 'add_event_log', 'INSERT INTO activity_log (user_id, activity_code, result, uri, log_details, ip_address, event_time)\r\nVALUES (''_USER_ID_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_IP_ADDRESS_'', NOW())'),
(49, 'get_permission_group_types', 'SELECT DISTINCT group_type AS type_code, cap_first_letter_in_words(REPLACE(group_type,''_'','' '')) AS type_display FROM `clout_v1_3iam`.permission_groups WHERE 1=1 _CATEGORY_CONDITION_ ORDER BY group_type ');

-- --------------------------------------------------------

--
-- Структура таблицы `rules`
--

CREATE TABLE IF NOT EXISTS `rules` (
  `id` bigint(20) NOT NULL,
  `code` varchar(300) NOT NULL,
  `display` varchar(500) NOT NULL,
  `details` text NOT NULL,
  `category` varchar(100) NOT NULL,
  `user_type` varchar(100) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `rules`
--

INSERT INTO `rules` (`id`, `code`, `display`, `details`, `category`, `user_type`, `status`) VALUES
(1, 'invite_daily_limit_10', 'Invite Daily Limit 10', 'Limits invite messages sent by the user to others to [daily_limit=10] per day.', 'invite_limit', 'any', 'inactive'),
(2, 'invite_daily_limit_30', 'Invite Daily Limit 30', 'Limits invite messages sent by the user to others to [daily_limit=30] per day.', 'invite_limit', 'any', 'inactive'),
(3, 'invite_daily_limit_unlimited', 'Invite Daily Limit Unlimited', 'Limits invite messages sent by the user to others to [daily_limit=unlimited] per day.', 'invite_limit', 'any', 'active'),
(4, 'stop_new_invite_sending', 'Stop New Invite Sending', 'Do not send invites with [invite_status=pending] status.', 'invite_limit', 'system', 'inactive'),
(5, 'stop_all_invite_sending', 'Stop All Invite Sending', 'Do not send invites with [invite_status=any] status (any status = pending, resending, new).', 'invite_limit', 'system', 'inactive'),
(6, 'new_inclusion_list_user', 'Assign Default Permission Group To Invited Users', 'As a first priority over all other rules, if a new user joins who was invited by a member on the Inclusion List (regardless of whether they clicked the referral link), assign that new user to the [permission_group=Invited Shopper] permission group and to the network of the member in the highest access group, ranked in the following order: clout owner > clout admin user > store owner owner > store owner admin user > invited shopper > random shopper, and if the invite was sent by more than one member in the same access group, then the user who first sent the invite will be given credit for the invite.\n', 'network_priority', 'system', 'active'),
(7, 'the_inclusion_list', 'The Inclusion List', 'Automatically track members on the following list [inclusion_list=*@clout.com,azziwa@gmail.com,fmkholdings@gmail.com] as the inclusion list.', 'access_control', 'system', 'active'),
(8, 'new_random_user', 'New Random User', 'Assign a new random user who joins without a link to the [permission_group=Random Shopper] permission group.', 'access_control', 'system', 'active'),
(9, 'new_user_referred_by_random_user', 'New User Referred By Random User', 'If a new user clicks a referral link of a user who belongs to the Random User permission group, assign that new user to the [permission_group=Random Shopper] permission group and to the network associated with the referral link.', 'access_control', 'system', 'active'),
(10, 'new_user_referred_by_invited_user', 'New User Referred By Invited User', 'If a new user clicks a referral link of a user who belongs to the Invited User permission group, assign that new user to the [permission_group=Invited Shopper] permission group and to the network associated with the referral link.', 'access_control', 'system', 'active');

-- --------------------------------------------------------

--
-- Структура таблицы `security_answers`
--

CREATE TABLE IF NOT EXISTS `security_answers` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `_question_id` bigint(20) DEFAULT NULL,
  `answer_details` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `security_questions`
--

CREATE TABLE IF NOT EXISTS `security_questions` (
  `id` bigint(20) NOT NULL,
  `question` varchar(300) NOT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `user_access`
--

CREATE TABLE IF NOT EXISTS `user_access` (
  `user_id` bigint(20) DEFAULT NULL,
  `permission_group_id` bigint(20) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `password` varchar(300) NOT NULL,
  `old_password_1` varchar(300) NOT NULL,
  `old_password_2` varchar(300) NOT NULL,
  `last_updated` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_access`
--

INSERT INTO `user_access` (`user_id`, `permission_group_id`, `user_name`, `password`, `old_password_1`, `old_password_2`, `last_updated`) VALUES
(1, 1, 'admin@clout.com', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', 'f865b53623b121fd34ee5426c792e5c33af8c227', 'f865b53623b121fd34ee5426c792e5c33af8c227', '2016-01-26 12:27:35'),
(12, 4, 'bog@ram.ru', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2015-12-03 16:02:13'),
(13, 5, 'azziwa@gmail.gov', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2016-03-16 16:11:44'),
(14, 6, 'azziwa@gmail.me', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2015-12-16 18:52:33'),
(18, 3, 'al.zziwa@gmail.com', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2016-01-04 11:30:59'),
(21, 5, 'jenny.c@gmail.com', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2016-01-08 11:36:37'),
(23, 5, 'tinga@gmail.com', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2015-12-18 11:19:31'),
(44, 6, 'al.zziwa@wexel.com', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2016-04-14 16:00:41'),
(2, 1, 'admin@clout.com', '19382a575ea05d2d762aa0f74d3abeb5b6afe354', 'f865b53623b121fd34ee5426c792e5c33af8c227', 'f865b53623b121fd34ee5426c792e5c33af8c227', '2016-01-26 12:27:35'),
(45, 6, 'al.zziwa@tech.gov', 'f865b53623b121fd34ee5426c792e5c33af8c227', '', '', '2016-03-01 13:00:57'),
(54, 6, 'bog@ram.ru', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2016-08-18 23:59:26'),
(55, 6, 'gggobboggo@ram.ru', 'a642a77abd7d4f51bf9226ceaf891fcbb5b299b8', '', '', '2016-08-19 02:30:54'),
(56, 6, 'fgooo@ram.rtu', '85305fbdb56e98b1333695cf1d00a1899ab04028', '', '', '2016-08-19 03:05:26'),
(57, 6, 'etertt@rrr.ru', 'dcb45a989eb99d1b914739ae815c3c0cad38049d', '', '', '2016-08-19 03:09:34'),
(58, 6, 'fsdfsdf@ram.ru', 'd24c9bfe3590b17ad68a433e4cf1d8fcefebeb64', '', '', '2016-08-19 03:11:17'),
(59, 6, 'boggo@ram.ru', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2016-08-19 03:14:31'),
(60, 6, 'boggoo@ram.ru', 'd24c9bfe3590b17ad68a433e4cf1d8fcefebeb64', '', '', '2016-08-19 03:17:27'),
(61, 6, 'fffobnbono@ram.ru', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2016-08-19 03:25:44'),
(62, 6, 'ggobgo@ram.ru', '77bce9fb18f977ea576bbcd143b2b521073f0cd6', '', '', '2016-08-19 03:28:27'),
(73, 6, 'bogdfdf@df.com', '2eb9e5c8f139f96e138456eea80973475cce9d08', '', '', '2016-08-19 04:24:40'),
(74, 6, 'bogdandvini@gmail.com', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2016-08-19 04:31:40'),
(75, 6, 'bog@fdfsdfsdf.ram', 'fea7f657f56a2a448da7d4b535ee5e279caf3d9a', '', '', '2016-08-19 04:41:55'),
(76, 6, 'boggfgdfgo@ram.ru', 'ee6965cb953e2771ef77d502cd397126c240b747', '', '', '2016-08-19 04:47:19'),
(77, 6, 'bogoo@fsdfds.com', 'b5cc17d3a35877ca8b76f0b2e07497039c250696', '', '', '2016-08-19 04:49:06'),
(78, 6, 'pulghjghjsar557@gmail.com', '601f1889667efaebb33b8c12572835da3f027f78', '', '', '2016-08-23 02:41:58'),
(80, 6, 'pul45tghjghjsar557@gmail.com', 'c9cdfd909fc13351c9acffbe65b5f89d50c15c55', '', '', '2016-08-23 02:46:46'),
(82, 6, 'pul45tghjfghghjsar557@gmail.com', 'c9cdfd909fc13351c9acffbe65b5f89d50c15c55', '', '', '2016-08-23 02:47:26'),
(83, 6, 'pulf45tghjfghghjsar557@gmail.com', '46a9cc4275faef8ea1a4f47c3a856261eaa49219', '', '', '2016-08-23 02:50:12'),
(84, 6, 'pulf45tghgjfghghjsar557@gmail.com', 'c1e5cd133887a00935b55d912025bd12ff893c34', '', '', '2016-08-23 02:52:22'),
(86, 6, 'pulfgh45tghgjfghghjsar557@gmail.com', 'c1e5cd133887a00935b55d912025bd12ff893c34', '', '', '2016-08-23 02:52:50'),
(87, 6, 'puglfgh45tghgjfghghjsar557@gmail.com', 'c1e5cd133887a00935b55d912025bd12ff893c34', '', '', '2016-08-23 02:53:25'),
(89, 6, '2016-12-23', '3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d', '', '', '2016-08-23 04:03:54'),
(90, 6, '0', 'da39a3ee5e6b4b0d3255bfef95601890afd80709', '', '', '2016-08-23 04:10:17'),
(91, 6, 'pulsahhhr557@gmail.com', '5da26138676148f8c79ccb8a082826a5cea54f8f', '', '', '2016-08-23 04:11:41');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__user_details_iam`
--
CREATE TABLE IF NOT EXISTS `view__user_details_iam` (
`user_id` bigint(20)
,`permission_group` varchar(100)
,`user_type` varchar(22)
);

-- --------------------------------------------------------

--
-- Структура для представления `view__user_details_iam`
--
DROP TABLE IF EXISTS `view__user_details_iam`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__user_details_iam` AS select `U`.`user_id` AS `user_id`,(select `G`.`name` from `permission_groups` `G` where (`U`.`permission_group_id` = `G`.`id`) limit 1) AS `permission_group`,(select `G`.`group_type` from `permission_groups` `G` where (`U`.`permission_group_id` = `G`.`id`) limit 1) AS `user_type` from `user_access` `U` where (`U`.`user_id` > 0);

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `activity_log`
--
ALTER TABLE `activity_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_activity_log__user_id` (`user_id`);

--
-- Индексы таблицы `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `permission_groups`
--
ALTER TABLE `permission_groups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `permission_group_mapping_permissions`
--
ALTER TABLE `permission_group_mapping_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `permission_group_mapping_rules`
--
ALTER TABLE `permission_group_mapping_rules`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `queries`
--
ALTER TABLE `queries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `rules`
--
ALTER TABLE `rules`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `security_answers`
--
ALTER TABLE `security_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_security_answers__question_id` (`_question_id`);

--
-- Индексы таблицы `security_questions`
--
ALTER TABLE `security_questions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `user_access`
--
ALTER TABLE `user_access`
  ADD UNIQUE KEY `_user_id` (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`permission_group_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `permissions`
--
ALTER TABLE `permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `permission_groups`
--
ALTER TABLE `permission_groups`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT для таблицы `permission_group_mapping_permissions`
--
ALTER TABLE `permission_group_mapping_permissions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=96;
--
-- AUTO_INCREMENT для таблицы `permission_group_mapping_rules`
--
ALTER TABLE `permission_group_mapping_rules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=75;
--
-- AUTO_INCREMENT для таблицы `queries`
--
ALTER TABLE `queries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=50;
--
-- AUTO_INCREMENT для таблицы `rules`
--
ALTER TABLE `rules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `security_answers`
--
ALTER TABLE `security_answers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `security_questions`
--
ALTER TABLE `security_questions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
