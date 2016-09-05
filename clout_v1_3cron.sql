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
-- База данных: `clout_v1_3cron`
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
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `activity_log`
--

INSERT INTO `activity_log` (`id`, `user_id`, `activity_code`, `result`, `uri`, `log_details`, `device`, `ip_address`, `event_time`) VALUES
(1, 44, 'plaid_api_login', 'SUCCESS', 'main/index', 'user_email=al.zziwa@wexel.com|bank_user_name=plaid_test|bank_code=wells', '', '127.0.0.1', '2016-02-18 15:38:53'),
(2, 44, 'plaid_api_response', 'FAIL', 'main/index', 'user_id=44|bank_code=wells|bank_id=38698', '', '127.0.0.1', '2016-02-18 15:38:54'),
(3, 44, 'plaid_api_login', 'FAIL', 'main/index', 'user_email=al.zziwa@wexel.com|bank_user_name=plaid_test|bank_code=wells', '', '127.0.0.1', '2016-02-18 15:48:11'),
(4, 44, 'plaid_api_response', 'FAIL', 'main/index', 'user_id=44|bank_code=wells|bank_id=38698', '', '127.0.0.1', '2016-02-18 15:48:11'),
(5, 44, 'plaid_api_login', 'FAIL', 'main/index', 'user_email=al.zziwa@wexel.com|bank_user_name=plaid_test|bank_code=wells', '', '127.0.0.1', '2016-02-18 15:48:37'),
(6, 44, 'plaid_api_response', 'FAIL', 'main/index', 'user_id=44|bank_code=wells|bank_id=38698', '', '127.0.0.1', '2016-02-18 15:48:38'),
(7, 44, 'plaid_api_login', 'FAIL', 'main/index', 'user_email=al.zziwa@wexel.com|bank_user_name=plaid_test|bank_code=wells', '', '127.0.0.1', '2016-02-18 15:50:34'),
(8, 44, 'plaid_api_response', 'FAIL', 'main/index', 'user_id=44|bank_code=wells|bank_id=38698', '', '127.0.0.1', '2016-02-18 15:50:34'),
(9, 44, 'plaid_api_login', 'FAIL', 'main/index', 'user_email=al.zziwa@wexel.com|bank_user_name=plaid_test|bank_code=wells', '', '127.0.0.1', '2016-02-18 15:54:50'),
(10, 44, 'plaid_api_response', 'FAIL', 'main/index', 'user_id=44|bank_code=wells|bank_id=38698', '', '127.0.0.1', '2016-02-18 15:54:50');

-- --------------------------------------------------------

--
-- Структура таблицы `advert_and_promo_tracking`
--

CREATE TABLE IF NOT EXISTS `advert_and_promo_tracking` (
  `id` bigint(20) NOT NULL,
  `_advertisement_id` bigint(20) DEFAULT NULL,
  `_promotion_id` bigint(20) DEFAULT NULL,
  `promotion_type` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `is_viewed` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_clicked` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_used` enum('Y','N') NOT NULL DEFAULT 'N',
  `view_period` int(11) NOT NULL,
  `view_date` datetime NOT NULL,
  `use_date` datetime NOT NULL,
  `view_location` varchar(300) NOT NULL,
  `score_when_viewed` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Триггеры `advert_and_promo_tracking`
--
DELIMITER $$
CREATE TRIGGER `triggerupdate__advert_and_promo_tracking` AFTER UPDATE ON `advert_and_promo_tracking`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.use_date <> '0000-00-00 00:00:00' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET last_promo_use_date=NEW.use_date WHERE user_id=NEW._user_id;

		IF NEW.promotion_type = 'perk' THEN
			UPDATE clout_v1_3cron.datatable__user_data SET total_perks_used=(total_perks_used+1) WHERE user_id=NEW._user_id;
		END IF;

		IF NEW.promotion_type = 'cashback' THEN
			UPDATE clout_v1_3cron.datatable__user_data SET total_cashback_used=(total_cashback_used+1) WHERE user_id=NEW._user_id;
		END IF;
    END IF;

	IF NEW.is_clicked = 'Y' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_clicks=(total_clicks+1) WHERE user_id=NEW._user_id;
    END IF;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `banks`
--

CREATE TABLE IF NOT EXISTS `banks` (
  `id` bigint(20) NOT NULL,
  `third_party_id` varchar(100) NOT NULL,
  `institution_name` varchar(300) NOT NULL,
  `institution_code` varchar(100) NOT NULL,
  `home_url` varchar(300) NOT NULL,
  `logo_url` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `is_featured` enum('Y','N') NOT NULL DEFAULT 'N',
  `address_line_1` varchar(300) NOT NULL,
  `address_line_2` varchar(300) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(100) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `email_address` varchar(100) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `username_placeholder` varchar(250) NOT NULL,
  `password_placeholder` varchar(250) NOT NULL,
  `has_mfa` enum('Y','N') NOT NULL DEFAULT 'N',
  `mfa_details` varchar(500) NOT NULL,
  `status` enum('active','inactive','suspended','pending') NOT NULL DEFAULT 'active',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `banks`
--

INSERT INTO `banks` (`id`, `third_party_id`, `institution_name`, `institution_code`, `home_url`, `logo_url`, `phone_number`, `is_featured`, `address_line_1`, `address_line_2`, `city`, `state`, `_country_code`, `email_address`, `currency_code`, `username_placeholder`, `password_placeholder`, `has_mfa`, `mfa_details`, `status`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, '20537', '1199 SEIU FCU (New York, NY)', '20537', 'http://www.1199federalcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Member Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(2, '6275', '121 Financial Credit Union', '6275', 'https://121fcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(3, '15761', '167th TFR FCU', '15761', 'http://www.167tfrfcu.com/ASP/home.asp', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Member Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(4, 'bofa', '1880 Bank', '14512', 'http://1880bank.com/', 'banklogo_bofa.png', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Access ID', 'Passcode', 'Y', 'list|questions', 'active', '2016-02-15 19:02:46', 1, '2016-02-15 19:39:37', 1),
(5, '3860', '1N Bank (now Susquehanna Bank)', '3860', 'http://www.susquehanna.net/', 'banklogo_3860.png', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Internet Banker ID', 'Internet Banker Password', '', '', 'active', '2016-02-15 19:02:46', 1, '2016-02-15 19:39:37', 1),
(11, '12619', '1Point Solutions HSA Account', '12619', 'http://www.1pointsolutions.com/part.html', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'Password', '', '', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(12, '20364', '1ST Mississippi FCU', '20364', 'http://www.1stmsfcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Access ID', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(13, '16489', '1st Advantage Bank (MO)', '16489', 'http://www.1stadvantagebank.com/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User Name', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(14, '24613', '1st Advantage Bank Business Banking', '24613', 'http://www.1stadvantagebank.com/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'User Password', '', '', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(15, '4989', '1st Advantage FCU', '4989', 'http://www.1stadvantage.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Account Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:38', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `banks_raw`
--

CREATE TABLE IF NOT EXISTS `banks_raw` (
  `id` bigint(20) NOT NULL,
  `third_party_id` varchar(100) NOT NULL,
  `institution_name` varchar(300) NOT NULL,
  `institution_code` varchar(100) NOT NULL,
  `home_url` varchar(300) NOT NULL,
  `logo_url` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `is_featured` enum('Y','N') NOT NULL DEFAULT 'N',
  `address_line_1` varchar(300) NOT NULL,
  `address_line_2` varchar(300) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(100) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `email_address` varchar(100) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `username_placeholder` varchar(250) NOT NULL,
  `password_placeholder` varchar(250) NOT NULL,
  `has_mfa` enum('Y','N') NOT NULL DEFAULT 'N',
  `mfa_details` varchar(500) NOT NULL,
  `status` enum('active','inactive','suspended','pending') NOT NULL DEFAULT 'active',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `banks_raw`
--

INSERT INTO `banks_raw` (`id`, `third_party_id`, `institution_name`, `institution_code`, `home_url`, `logo_url`, `phone_number`, `is_featured`, `address_line_1`, `address_line_2`, `city`, `state`, `_country_code`, `email_address`, `currency_code`, `username_placeholder`, `password_placeholder`, `has_mfa`, `mfa_details`, `status`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, '20537', '1199 SEIU FCU (New York, NY)', '20537', 'http://www.1199federalcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Member Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(2, '6275', '121 Financial Credit Union', '6275', 'https://121fcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(3, '15761', '167th TFR FCU', '15761', 'http://www.167tfrfcu.com/ASP/home.asp', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Member Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:02:45', 1, '2016-02-15 19:39:37', 1),
(4, 'bofa', '1880 Bank', '14512', 'http://1880bank.com/', 'banklogo_bofa.png', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Access ID', 'Passcode', 'Y', 'list|questions', 'active', '2016-02-15 19:02:46', 1, '2016-02-15 19:39:37', 1),
(5, '3860', '1N Bank (now Susquehanna Bank)', '3860', 'http://www.susquehanna.net/', 'banklogo_3860.png', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Internet Banker ID', 'Internet Banker Password', '', '', 'active', '2016-02-15 19:02:46', 1, '2016-02-15 19:39:37', 1),
(11, '12619', '1Point Solutions HSA Account', '12619', 'http://www.1pointsolutions.com/part.html', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'Password', '', '', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(12, '20364', '1ST Mississippi FCU', '20364', 'http://www.1stmsfcu.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Access ID', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(13, '16489', '1st Advantage Bank (MO)', '16489', 'http://www.1stadvantagebank.com/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User Name', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(14, '24613', '1st Advantage Bank Business Banking', '24613', 'http://www.1stadvantagebank.com/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'User ID', 'User Password', '', '', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:37', 1),
(15, '4989', '1st Advantage FCU', '4989', 'http://www.1stadvantage.org/', '', '', 'N', '', '', '', '', 'USA', '', 'USD', 'Account Number', 'Password', 'Y', 'list|questions', 'active', '2016-02-15 19:18:01', 1, '2016-02-15 19:39:38', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `bank_accounts`
--

CREATE TABLE IF NOT EXISTS `bank_accounts` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `account_type` varchar(100) NOT NULL,
  `account_id` varchar(100) NOT NULL,
  `account_number` varchar(100) NOT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `issue_bank_name` varchar(300) NOT NULL,
  `routing_number` varchar(100) NOT NULL,
  `card_holder_full_name` varchar(300) NOT NULL,
  `account_nickname` varchar(100) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `billing_address_line_1` varchar(300) NOT NULL,
  `billing_address_line_2` varchar(300) NOT NULL,
  `billing_city` varchar(200) NOT NULL,
  `billing_state` varchar(200) NOT NULL,
  `billing_zipcode` varchar(10) NOT NULL,
  `billing_country` varchar(200) NOT NULL,
  `is_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','deleted') NOT NULL DEFAULT 'pending',
  `last_sync_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `bank_accounts`
--

INSERT INTO `bank_accounts` (`id`, `_user_id`, `account_type`, `account_id`, `account_number`, `_bank_id`, `issue_bank_name`, `routing_number`, `card_holder_full_name`, `account_nickname`, `currency_code`, `billing_address_line_1`, `billing_address_line_2`, `billing_city`, `billing_state`, `billing_zipcode`, `billing_country`, `is_verified`, `status`, `last_sync_date`) VALUES
(1, 1, 'bank', '53e12f52935345fb2626aec8', '3060', 8502, 'Chase Bank', '', 'Francis Konig', 'Bus Select Hy Sav', 'USD', '', '', '', '', '', '', 'Y', 'active', '2015-07-16 08:17:51'),
(2, 1, 'credit', '53da8de3f793d1be4d50fe96', '3705', 3832, 'Bank of America', '', 'Francis Konig', 'AAA Washington Platinum Plus Visa', 'USD', '', '', '', '', '', '', 'Y', 'active', '2015-07-16 07:42:17'),
(3, 1, 'other', 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', '9606', 3832, 'Bank of America', '', '', 'Plaid Savings', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(4, 1, 'other', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '1702', 3832, 'Bank of America', '', '', 'Plaid Checking', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(5, 1, 'other', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '5204', 3832, 'Bank of America', '', '', 'Plaid Premier Checking', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(6, 1, 'credit', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '3002', 3832, 'Bank of America', '', '', 'Plaid Credit Card', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(7, 1, 'other', 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', '9606', 11396, 'USAA Bank', '', '', 'Plaid Savings', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(8, 1, 'other', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '1702', 11396, 'USAA Bank', '', '', 'Plaid Checking', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(9, 1, 'other', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '5204', 11396, 'USAA Bank', '', '', 'Plaid Premier Checking', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(10, 13, 'credit', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '3002', 11396, 'USAA Bank', '', '', 'Plaid Credit Card', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00'),
(11, 54, 'other', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '5204', 11396, 'USAA Bank', '', '', 'Plaid Premier Checking', 'USD', '', '', '', '', '', '', 'Y', 'active', '0000-00-00 00:00:00');

--
-- Триггеры `bank_accounts`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__bank_accounts` AFTER INSERT ON `bank_accounts`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET bank_verified_and_active='Y', total_linked_accounts=(total_linked_accounts+1) WHERE user_id=NEW._user_id;


	IF NEW._bank_id > 0 AND (SELECT id FROM clout_v1_3cron.bank_accounts WHERE _user_id=NEW._user_id AND _bank_id=NEW._bank_id LIMIT 1) IS NULL THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_linked_banks=(total_linked_banks+1) WHERE user_id=NEW._user_id;
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `bank_accounts_credit_raw`
--

CREATE TABLE IF NOT EXISTS `bank_accounts_credit_raw` (
  `id` bigint(20) NOT NULL,
  `account_id` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `status` varchar(100) NOT NULL,
  `account_number` varchar(250) NOT NULL,
  `account_number_real` varchar(250) NOT NULL,
  `account_nickname` varchar(250) NOT NULL,
  `display_position` varchar(10) NOT NULL,
  `_institution_id` bigint(20) DEFAULT NULL,
  `description` varchar(250) NOT NULL,
  `registered_user_name` varchar(100) NOT NULL,
  `balance_amount` decimal(20,4) NOT NULL,
  `balance_date` datetime NOT NULL,
  `balance_previous_amount` decimal(20,4) NOT NULL,
  `last_transaction_date` datetime NOT NULL,
  `aggr_success_date` datetime NOT NULL,
  `aggr_attempt_date` datetime NOT NULL,
  `aggr_status_code` varchar(100) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `bank_id` varchar(100) NOT NULL,
  `institution_login_id` varchar(100) NOT NULL,
  `credit_account_type` varchar(100) NOT NULL,
  `detailed_description` varchar(250) NOT NULL,
  `interest_rate` float NOT NULL,
  `credit_available_amount` float NOT NULL,
  `credit_max_amount` float NOT NULL,
  `cash_advance_available_amount` float NOT NULL,
  `cash_advance_max_amount` float NOT NULL,
  `cash_advance_balance` decimal(20,4) NOT NULL,
  `cash_advance_interest_rate` float NOT NULL,
  `current_balance` decimal(20,4) NOT NULL,
  `payment_min_amount` float NOT NULL,
  `payment_due_date` date NOT NULL,
  `previous_balance` float NOT NULL,
  `statement_end_date` date NOT NULL,
  `statement_purchase_amount` float NOT NULL,
  `statement_finance_amount` float NOT NULL,
  `past_due_amount` float NOT NULL,
  `last_payment_amount` float NOT NULL,
  `last_payment_date` datetime NOT NULL,
  `statement_close_balance` decimal(20,4) NOT NULL,
  `statement_late_fee_amount` float NOT NULL,
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `last_updated` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `bank_accounts_credit_raw`
--

INSERT INTO `bank_accounts_credit_raw` (`id`, `account_id`, `_user_id`, `status`, `account_number`, `account_number_real`, `account_nickname`, `display_position`, `_institution_id`, `description`, `registered_user_name`, `balance_amount`, `balance_date`, `balance_previous_amount`, `last_transaction_date`, `aggr_success_date`, `aggr_attempt_date`, `aggr_status_code`, `currency_code`, `bank_id`, `institution_login_id`, `credit_account_type`, `detailed_description`, `interest_rate`, `credit_available_amount`, `credit_max_amount`, `cash_advance_available_amount`, `cash_advance_max_amount`, `cash_advance_balance`, `cash_advance_interest_rate`, `current_balance`, `payment_min_amount`, `payment_due_date`, `previous_balance`, `statement_end_date`, `statement_purchase_amount`, `statement_finance_amount`, `past_due_amount`, `last_payment_amount`, `last_payment_date`, `statement_close_balance`, `statement_late_fee_amount`, `is_saved`, `last_updated`) VALUES
(1, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38698, 'PLAID - ', '', '2275.5800', '2015-09-29 13:38:59', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2015-09-29 13:38:55'),
(2, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38693, 'PLAID - ', '', '2275.5800', '2015-09-29 16:59:06', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2015-09-29 16:59:02'),
(3, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38698, 'PLAID - ', '', '2275.5800', '2016-02-18 19:47:07', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-02-18 19:46:48'),
(4, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38693, 'PLAID - ', '', '2275.5800', '2016-02-18 19:49:29', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-02-18 19:49:11'),
(5, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 6, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38698, 'PLAID - ', '', '2275.5800', '2016-03-01 10:39:03', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-03-01 10:39:02'),
(6, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 45, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38693, 'PLAID - ', '', '2275.5800', '2016-03-01 10:43:43', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-03-01 10:43:43'),
(7, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 0, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38694, 'PLAID - ', '', '2275.5800', '2016-05-10 17:21:46', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-05-10 17:21:05'),
(13, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 13, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38694, 'PLAID - ', 'Aloysious Zziwa', '2275.5800', '2016-05-10 17:35:59', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-05-10 17:35:25'),
(14, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 38694, 'PLAID - ', 'Al Zious', '2275.5800', '2016-04-15 15:18:22', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-04-15 15:18:16'),
(16, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 13, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '3002', 'Plaid Credit Card', '', 22192, 'PLAID - ', 'Aloysious Zziwa', '2275.5800', '2016-04-20 15:18:00', '0.0000', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '', 0, 9930, 12500, 0, 0, '0.0000', 0, '0.0000', 0, '0000-00-00', 0, '0000-00-00', 0, 0, 0, 0, '0000-00-00 00:00:00', '0.0000', 0, 'N', '2016-04-20 15:17:48');

-- --------------------------------------------------------

--
-- Структура таблицы `bank_accounts_other_raw`
--

CREATE TABLE IF NOT EXISTS `bank_accounts_other_raw` (
  `id` bigint(20) NOT NULL,
  `account_id` varchar(250) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `status` varchar(100) NOT NULL,
  `account_number` varchar(250) NOT NULL,
  `account_number_real` varchar(250) NOT NULL,
  `account_nickname` varchar(250) NOT NULL,
  `display_position` varchar(250) NOT NULL,
  `_institution_id` bigint(20) DEFAULT NULL,
  `description` varchar(250) NOT NULL,
  `registered_user_name` varchar(100) NOT NULL,
  `balance_amount` float NOT NULL,
  `balance_date` datetime NOT NULL,
  `balance_previous_amount` float NOT NULL,
  `last_transaction_date` datetime NOT NULL,
  `aggr_success_date` datetime NOT NULL,
  `aggr_attempt_date` datetime NOT NULL,
  `aggr_status_code` varchar(100) NOT NULL,
  `currency_code` varchar(10) NOT NULL,
  `bank_id` varchar(250) NOT NULL,
  `institution_login_id` varchar(250) NOT NULL,
  `banking_account_type` varchar(100) NOT NULL,
  `posted_date` date NOT NULL,
  `available_balance_amount` float NOT NULL,
  `interest_type` varchar(100) NOT NULL,
  `origination_date` date NOT NULL,
  `open_date` datetime NOT NULL,
  `period_interest_rate` varchar(10) NOT NULL,
  `period_deposit_amount` float NOT NULL,
  `period_interest_amount` float NOT NULL,
  `interest_amount_ytd` float NOT NULL,
  `interest_prior_amount_ytd` float NOT NULL,
  `maturity_date` datetime NOT NULL,
  `maturity_amount` float NOT NULL,
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `last_updated` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `bank_accounts_other_raw`
--

INSERT INTO `bank_accounts_other_raw` (`id`, `account_id`, `_user_id`, `status`, `account_number`, `account_number_real`, `account_nickname`, `display_position`, `_institution_id`, `description`, `registered_user_name`, `balance_amount`, `balance_date`, `balance_previous_amount`, `last_transaction_date`, `aggr_success_date`, `aggr_attempt_date`, `aggr_status_code`, `currency_code`, `bank_id`, `institution_login_id`, `banking_account_type`, `posted_date`, `available_balance_amount`, `interest_type`, `origination_date`, `open_date`, `period_interest_rate`, `period_deposit_amount`, `period_interest_amount`, `interest_amount_ytd`, `interest_prior_amount_ytd`, `maturity_date`, `maturity_amount`, `is_saved`, `last_updated`) VALUES
(1, 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '9606', 'Plaid Savings', '', 38698, 'PLAID - ', '', 1274.93, '2015-09-29 13:38:59', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1203.42, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 13:38:55'),
(2, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '1702', 'Plaid Checking', '', 38698, 'PLAID - ', '', 1253.32, '2015-09-29 13:38:59', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1081.78, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 13:38:55'),
(3, 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '5204', 'Plaid Premier Checking', '', 38698, 'PLAID - ', '', 7255.23, '2015-09-29 13:38:59', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 7205.23, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 13:38:55'),
(4, 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '9606', 'Plaid Savings', '', 38693, 'PLAID - ', '', 1274.93, '2015-09-29 16:59:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1203.42, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 16:59:02'),
(5, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '1702', 'Plaid Checking', '', 38693, 'PLAID - ', '', 1253.32, '2015-09-29 16:59:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1081.78, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 16:59:02'),
(6, 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', 1, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '5204', 'Plaid Premier Checking', '', 38693, 'PLAID - ', '', 7255.23, '2015-09-29 16:59:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 7205.23, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2015-09-29 16:59:02'),
(7, 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '9606', 'Plaid Savings', '', 38698, 'PLAID - ', '', 1274.93, '2016-02-18 19:47:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1203.42, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2016-02-18 19:46:48'),
(8, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '1702', 'Plaid Checking', '', 38698, 'PLAID - ', '', 1253.32, '2016-02-18 19:47:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1081.78, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2016-02-18 19:46:48'),
(9, 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '5204', 'Plaid Premier Checking', '', 38698, 'PLAID - ', '', 7255.23, '2016-02-18 19:47:06', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 7205.23, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2016-02-18 19:46:48'),
(10, 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', 44, '', 'KdDjmojBERUKx3JkDd9RuxA5EvejA4SENO4AA', '9606', 'Plaid Savings', '', 38693, 'PLAID - ', '', 1274.93, '2016-02-18 19:49:28', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '', 'USD', '', '', '', '0000-00-00', 1203.42, '', '0000-00-00', '0000-00-00 00:00:00', '0.0', 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 'N', '2016-02-18 19:49:10');

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__clout_score`
--

CREATE TABLE IF NOT EXISTS `cacheview__clout_score` (
  `user_id` bigint(20) DEFAULT NULL,
  `facebook_connected` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `email_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `mobile_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `profile_photo_added` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `location_services_activated` enum('Y','N') NOT NULL,
  `push_notifications_activated` enum('Y','N') NOT NULL,
  `first_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_payment_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `first_adrelated_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_promo_payment_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `has_first_public_checkin_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_public_checkin_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `has_answered_survey_in_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `number_of_surveys_answered_in_last90days` bigint(21) DEFAULT NULL,
  `number_of_direct_referrals_last180days` bigint(21) DEFAULT NULL,
  `number_of_direct_referrals_last360days` bigint(21) DEFAULT NULL,
  `total_direct_referrals` bigint(21) DEFAULT NULL,
  `number_of_network_referrals_last180days` bigint(24) DEFAULT NULL,
  `number_of_network_referrals_last360days` bigint(24) NOT NULL,
  `total_network_referrals` bigint(24) DEFAULT NULL,
  `spending_of_direct_referrals_last180days` decimal(42,4) DEFAULT NULL,
  `spending_of_direct_referrals_last360days` decimal(42,4) DEFAULT NULL,
  `total_spending_of_direct_referrals` decimal(42,4) DEFAULT NULL,
  `spending_of_network_referrals_last180days` decimal(42,4) DEFAULT NULL,
  `spending_of_network_referrals_last360days` decimal(42,4) DEFAULT NULL,
  `total_spending_of_network_referrals` decimal(42,4) DEFAULT NULL,
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `ad_spending_last180days` decimal(42,4) DEFAULT NULL,
  `ad_spending_last360days` decimal(42,4) DEFAULT NULL,
  `ad_spending_total` decimal(42,4) DEFAULT NULL,
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL,
  `facebook_connected_score` varchar(100) DEFAULT NULL,
  `email_verified_score` varchar(100) DEFAULT NULL,
  `mobile_verified_score` varchar(100) DEFAULT NULL,
  `profile_photo_added_score` varchar(100) DEFAULT NULL,
  `bank_verified_and_active_score` varchar(100) DEFAULT NULL,
  `credit_verified_and_active_score` varchar(100) DEFAULT NULL,
  `location_services_activated_score` varchar(100) DEFAULT NULL,
  `push_notifications_activated_score` varchar(100) DEFAULT NULL,
  `first_payment_success_score` varchar(100) DEFAULT NULL,
  `member_processed_payment_last7days_score` varchar(100) DEFAULT NULL,
  `first_adrelated_payment_success_score` varchar(100) DEFAULT NULL,
  `member_processed_promo_payment_last7days_score` varchar(100) DEFAULT NULL,
  `has_first_public_checkin_success_score` varchar(100) DEFAULT NULL,
  `has_public_checkin_last7days_score` varchar(100) DEFAULT NULL,
  `has_answered_survey_in_last90days_score` varchar(100) DEFAULT NULL,
  `number_of_surveys_answered_in_last90days_score` varchar(100) DEFAULT NULL,
  `number_of_direct_referrals_last180days_score` double DEFAULT NULL,
  `number_of_direct_referrals_last360days_score` double DEFAULT NULL,
  `total_direct_referrals_score` double DEFAULT NULL,
  `number_of_network_referrals_last180days_score` double DEFAULT NULL,
  `number_of_network_referrals_last360days_score` double NOT NULL,
  `total_network_referrals_score` double DEFAULT NULL,
  `spending_of_direct_referrals_last180days_score` double DEFAULT NULL,
  `spending_of_direct_referrals_last360days_score` double DEFAULT NULL,
  `total_spending_of_direct_referrals_score` double DEFAULT NULL,
  `spending_of_network_referrals_last180days_score` double DEFAULT NULL,
  `spending_of_network_referrals_last360days_score` double DEFAULT NULL,
  `total_spending_of_network_referrals_score` double DEFAULT NULL,
  `spending_last180days_score` double DEFAULT NULL,
  `spending_last360days_score` double DEFAULT NULL,
  `spending_total_score` double DEFAULT NULL,
  `ad_spending_last180days_score` double DEFAULT NULL,
  `ad_spending_last360days_score` double DEFAULT NULL,
  `ad_spending_total_score` double DEFAULT NULL,
  `cash_balance_today_score` double DEFAULT NULL,
  `average_cash_balance_last24months_score` double DEFAULT NULL,
  `credit_balance_today_score` double DEFAULT NULL,
  `average_credit_balance_last24months_score` double DEFAULT NULL,
  `total_score` double DEFAULT NULL,
  `is_reported` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__clout_score`
--

INSERT INTO `cacheview__clout_score` (`user_id`, `facebook_connected`, `email_verified`, `mobile_verified`, `profile_photo_added`, `bank_verified_and_active`, `credit_verified_and_active`, `location_services_activated`, `push_notifications_activated`, `first_payment_success`, `member_processed_payment_last7days`, `first_adrelated_payment_success`, `member_processed_promo_payment_last7days`, `has_first_public_checkin_success`, `has_public_checkin_last7days`, `has_answered_survey_in_last90days`, `number_of_surveys_answered_in_last90days`, `number_of_direct_referrals_last180days`, `number_of_direct_referrals_last360days`, `total_direct_referrals`, `number_of_network_referrals_last180days`, `number_of_network_referrals_last360days`, `total_network_referrals`, `spending_of_direct_referrals_last180days`, `spending_of_direct_referrals_last360days`, `total_spending_of_direct_referrals`, `spending_of_network_referrals_last180days`, `spending_of_network_referrals_last360days`, `total_spending_of_network_referrals`, `spending_last180days`, `spending_last360days`, `spending_total`, `ad_spending_last180days`, `ad_spending_last360days`, `ad_spending_total`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`, `facebook_connected_score`, `email_verified_score`, `mobile_verified_score`, `profile_photo_added_score`, `bank_verified_and_active_score`, `credit_verified_and_active_score`, `location_services_activated_score`, `push_notifications_activated_score`, `first_payment_success_score`, `member_processed_payment_last7days_score`, `first_adrelated_payment_success_score`, `member_processed_promo_payment_last7days_score`, `has_first_public_checkin_success_score`, `has_public_checkin_last7days_score`, `has_answered_survey_in_last90days_score`, `number_of_surveys_answered_in_last90days_score`, `number_of_direct_referrals_last180days_score`, `number_of_direct_referrals_last360days_score`, `total_direct_referrals_score`, `number_of_network_referrals_last180days_score`, `number_of_network_referrals_last360days_score`, `total_network_referrals_score`, `spending_of_direct_referrals_last180days_score`, `spending_of_direct_referrals_last360days_score`, `total_spending_of_direct_referrals_score`, `spending_of_network_referrals_last180days_score`, `spending_of_network_referrals_last360days_score`, `total_spending_of_network_referrals_score`, `spending_last180days_score`, `spending_last360days_score`, `spending_total_score`, `ad_spending_last180days_score`, `ad_spending_last360days_score`, `ad_spending_total_score`, `cash_balance_today_score`, `average_cash_balance_last24months_score`, `credit_balance_today_score`, `average_credit_balance_last24months_score`, `total_score`, `is_reported`) VALUES
(2, '', 'N', 'N', 'N', '', '', 'N', 'N', 'N', '', 'N', '', 'N', '', '', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0, 'N'),
(1, 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 6, 6, 6, 15, 1, 15, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '113327.7000', '330034.0500', '467012.6402', '0.0000', '0.0000', '0.0000', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, '20', '20', '0', '20', '20', '20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 20, 20, 20, 20, 20, 20, NULL, NULL, NULL, NULL, NULL, NULL, 50, 40, 50, NULL, NULL, NULL, 50, 50, 50, 50, 620, 'N'),
(12, 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '0', '20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 40, 50, 0, 0, 0, 0, 0, 0, 0, 160, 'N'),
(13, 'Y', 'Y', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '20', '20', '0', '0', '20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 60, 'N'),
(76, 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 1, 0, 1, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '20', '20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 20, 20, 20, 20, 0, 20, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1100, 'N'),
(18, 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '0', '20', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 20, 'N'),
(21, 'N', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 2, 0, 2, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '0', '20', '30', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 15, 15, 15, 15, 0, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 170, 'N'),
(23, 'N', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 1, 0, 1, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0, '0', '20', '30', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', 13.333333333, 13.333333333, 13.333333333, 15, 0, 15, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 161.666666665, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__clout_score_data`
--

CREATE TABLE IF NOT EXISTS `cacheview__clout_score_data` (
  `user_id` bigint(20) DEFAULT NULL,
  `facebook_connected` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `email_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `mobile_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `profile_photo_added` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `location_services_activated` enum('Y','N') NOT NULL,
  `push_notifications_activated` enum('Y','N') NOT NULL,
  `first_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_payment_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `first_adrelated_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_promo_payment_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `has_first_public_checkin_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_public_checkin_last7days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `has_answered_survey_in_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `number_of_surveys_answered_in_last90days` bigint(21) DEFAULT NULL,
  `number_of_direct_referrals_last180days` bigint(21) DEFAULT NULL,
  `number_of_direct_referrals_last360days` bigint(21) DEFAULT NULL,
  `total_direct_referrals` bigint(21) DEFAULT NULL,
  `number_of_network_referrals_last180days` bigint(24) DEFAULT NULL,
  `number_of_network_referrals_last360days` bigint(24) NOT NULL,
  `total_network_referrals` bigint(24) DEFAULT NULL,
  `spending_of_direct_referrals_last180days` decimal(42,4) DEFAULT NULL,
  `spending_of_direct_referrals_last360days` decimal(42,4) DEFAULT NULL,
  `total_spending_of_direct_referrals` decimal(42,4) DEFAULT NULL,
  `spending_of_network_referrals_last180days` decimal(42,4) DEFAULT NULL,
  `spending_of_network_referrals_last360days` decimal(42,4) DEFAULT NULL,
  `total_spending_of_network_referrals` decimal(42,4) DEFAULT NULL,
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `ad_spending_last180days` decimal(42,4) DEFAULT NULL,
  `ad_spending_last360days` decimal(42,4) DEFAULT NULL,
  `ad_spending_total` decimal(42,4) DEFAULT NULL,
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__clout_score_data`
--

INSERT INTO `cacheview__clout_score_data` (`user_id`, `facebook_connected`, `email_verified`, `mobile_verified`, `profile_photo_added`, `bank_verified_and_active`, `credit_verified_and_active`, `location_services_activated`, `push_notifications_activated`, `first_payment_success`, `member_processed_payment_last7days`, `first_adrelated_payment_success`, `member_processed_promo_payment_last7days`, `has_first_public_checkin_success`, `has_public_checkin_last7days`, `has_answered_survey_in_last90days`, `number_of_surveys_answered_in_last90days`, `number_of_direct_referrals_last180days`, `number_of_direct_referrals_last360days`, `total_direct_referrals`, `number_of_network_referrals_last180days`, `number_of_network_referrals_last360days`, `total_network_referrals`, `spending_of_direct_referrals_last180days`, `spending_of_direct_referrals_last360days`, `total_spending_of_direct_referrals`, `spending_of_network_referrals_last180days`, `spending_of_network_referrals_last360days`, `total_spending_of_network_referrals`, `spending_last180days`, `spending_last360days`, `spending_total`, `ad_spending_last180days`, `ad_spending_last360days`, `ad_spending_total`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`) VALUES
(2, '', 'N', 'N', 'N', '', '', 'N', 'N', 'N', '', 'N', '', 'N', '', '', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(1, 'Y', 'Y', 'N', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 6, 6, 6, 15, 1, 15, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '113327.7000', '330034.0500', '467012.6402', '0.0000', '0.0000', '0.0000', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
(12, 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0),
(13, 'Y', 'Y', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0),
(76, 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 1, 0, 1, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0),
(18, 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, 0, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0),
(21, 'N', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 2, 0, 2, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0),
(23, 'N', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 1, 1, 1, 1, 0, 1, '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 0, 0, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__promotions_summary`
--

CREATE TABLE IF NOT EXISTS `cacheview__promotions_summary` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `owner_id` bigint(20) NOT NULL,
  `owner_type` enum('person','store','merchant','system','other') NOT NULL,
  `promotion_type` enum('cashback','perk') NOT NULL,
  `start_score` float NOT NULL,
  `end_score` float NOT NULL,
  `number_viewed` int(11) NOT NULL,
  `number_redeemed` int(11) NOT NULL,
  `new_customers` int(11) NOT NULL,
  `gross_sales` float NOT NULL,
  `is_boosted` enum('Y','N') NOT NULL DEFAULT 'N',
  `boost_budget` float NOT NULL,
  `boost_start_date` datetime NOT NULL,
  `boost_end_date` datetime NOT NULL,
  `boost_remaining` float NOT NULL,
  `name` varchar(300) NOT NULL,
  `amount` float NOT NULL,
  `description` text NOT NULL,
  `status` enum('active','pending','inactive','deleted') NOT NULL DEFAULT 'pending',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL,
  `advert_id` bigint(20) NOT NULL DEFAULT '0',
  `store_name` varchar(500) DEFAULT NULL,
  `logo_url` varchar(300) DEFAULT NULL,
  `small_cover_image` varchar(300) DEFAULT NULL,
  `large_cover_image` varchar(300) DEFAULT NULL,
  `price_range` int(11) DEFAULT NULL,
  `latitude` varchar(10) DEFAULT NULL,
  `longitude` varchar(10) DEFAULT NULL,
  `store_id` bigint(20) NOT NULL,
  `sub_category_tags` text,
  `category_image` varchar(100) DEFAULT NULL,
  `table_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1049 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__promotions_summary`
--

INSERT INTO `cacheview__promotions_summary` (`id`, `owner_id`, `owner_type`, `promotion_type`, `start_score`, `end_score`, `number_viewed`, `number_redeemed`, `new_customers`, `gross_sales`, `is_boosted`, `boost_budget`, `boost_start_date`, `boost_end_date`, `boost_remaining`, `name`, `amount`, `description`, `status`, `start_date`, `end_date`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`, `advert_id`, `store_name`, `logo_url`, `small_cover_image`, `large_cover_image`, `price_range`, `latitude`, `longitude`, `store_id`, `sub_category_tags`, `category_image`, `table_id`) VALUES
(1, 10029873, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 1, '7080 HOLLYWOOD', '', 'banner_10029873.png', '', 0, '34.10113', '-118.34441', 10029873, 'HOMES & RESIDENTIAL REAL ESTATE', 'blue_real_estate_icon.png', 1039),
(2, 10041523, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 2, 'BESO', '', '', '', 0, '41.63935', '-74.17695', 10041523, 'AMERICAN RESTAURANTS, RESTAURANTS', 'blue_restaurant_icon.png', 1040),
(3, 10065137, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 3, 'EXXONMOBIL', '', '', '', 0, '35.14188', '-89.7954', 10065137, 'GAS STATIONS, SERVICE STATIONS, CONVENIENCE STORES', 'blue_automotive_icon.png', 1041),
(4, 10100258, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 4, 'GJELINA', '', 'banner_10100258.png', '', 0, '33.99068', '-118.46528', 10100258, 'AMERICAN RESTAURANTS, RESTAURANTS', 'blue_restaurant_icon.png', 1042),
(5, 10161035, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 5, 'KITCHEN', '', '', '', 0, '26.01363', '-80.14409', 10161035, 'KITCHEN CABINETS & EQUIPMENT DEALERS', 'blue_home_services_icon.png', 1043),
(6, 10255193, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 6, 'PALISADES LEVITY LIVE LLC', '', '', '', 0, '41.09937', '-73.95591', 10255193, 'LEGAL SERVICE PLANS', 'blue_financial_services_icon.png', 1044),
(7, 10390294, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '40% OFF', 40, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 7, 'ALASKA AIRLINES', '', '', '', 0, '33.43581', '-112.02371', 10390294, 'AIRLINES', 'blue_hotel_and_travel_icon.png', 1045),
(8, 10415595, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 8, 'FLEMINGS', '', '', '', 0, '27.23342', '-82.49752', 10415595, 'FURNITURE STORES', 'blue_shopping_icon.png', 1046),
(9, 10434056, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 9, 'MUSTACHE MIKES ITALIAN ICE', '', 'banner_10434056.png', '', 0, '33.86268', '-117.83634', 10434056, 'ITALIAN RESTAURANTS', 'blue_restaurant_icon.png', 1047),
(10, 10443914, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '40% OFF', 40, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, 10, 'US AIRWAYS', '', '', '', 0, '38.1859', '-85.74577', 10443914, 'AIRLINES', 'blue_hotel_and_travel_icon.png', 1048);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_scores_previous`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_scores_previous` (
  `id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `store_id` bigint(20) NOT NULL,
  `user_id-store_id` varchar(300) NOT NULL,
  `score` int(11) NOT NULL,
  `date_entered` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_by_category`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_by_category` (
  `store_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_store_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_store_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_store_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_category_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_category_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_last12months` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL,
  `my_store_spending_last90days_score` double DEFAULT '0',
  `my_store_spending_last12months_score` double DEFAULT '0',
  `my_store_spending_lifetime_score` double DEFAULT '0',
  `my_chain_spending_last90days_score` double DEFAULT '0',
  `my_chain_spending_last12months_score` double DEFAULT '0',
  `my_chain_spending_lifetime_score` double DEFAULT '0',
  `did_store_survey_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last12months_score` double DEFAULT '0',
  `my_direct_competitors_spending_lifetime_score` double DEFAULT '0',
  `did_competitor_store_survey_last90days_score` double DEFAULT '0',
  `my_category_spending_last90days_score` double DEFAULT '0',
  `my_category_spending_last12months_score` double DEFAULT '0',
  `my_category_spending_lifetime_score` double DEFAULT '0',
  `did_my_category_survey_last90days_score` double DEFAULT '0',
  `related_categories_spending_last90days_score` double DEFAULT '0',
  `related_categories_spending_last12months_score` double DEFAULT '0',
  `related_categories_spending_lifetime_score` double DEFAULT '0',
  `did_related_categories_survey_last90days_score` double DEFAULT '0',
  `spending_last180days_score` double DEFAULT '0',
  `spending_last360days_score` double DEFAULT '0',
  `spending_total_score` double DEFAULT '0',
  `bank_verified_and_active_score` double DEFAULT '0',
  `credit_verified_and_active_score` double DEFAULT '0',
  `cash_balance_today_score` double DEFAULT '0',
  `average_cash_balance_last24months_score` double DEFAULT '0',
  `credit_balance_today_score` double DEFAULT '0',
  `average_credit_balance_last24months_score` double DEFAULT '0',
  `total_score` double DEFAULT '0',
  `is_reported` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_by_category`
--

INSERT INTO `cacheview__store_score_by_category` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`, `my_store_spending_last90days_score`, `my_store_spending_last12months_score`, `my_store_spending_lifetime_score`, `my_chain_spending_last90days_score`, `my_chain_spending_last12months_score`, `my_chain_spending_lifetime_score`, `did_store_survey_last90days_score`, `my_direct_competitors_spending_last90days_score`, `my_direct_competitors_spending_last12months_score`, `my_direct_competitors_spending_lifetime_score`, `did_competitor_store_survey_last90days_score`, `my_category_spending_last90days_score`, `my_category_spending_last12months_score`, `my_category_spending_lifetime_score`, `did_my_category_survey_last90days_score`, `related_categories_spending_last90days_score`, `related_categories_spending_last12months_score`, `related_categories_spending_lifetime_score`, `did_related_categories_survey_last90days_score`, `spending_last180days_score`, `spending_last360days_score`, `spending_total_score`, `bank_verified_and_active_score`, `credit_verified_and_active_score`, `cash_balance_today_score`, `average_cash_balance_last24months_score`, `credit_balance_today_score`, `average_credit_balance_last24months_score`, `total_score`, `is_reported`) VALUES
('', '10', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '9.0000', '48.5000', '48.5000', 'N', '9.0000', '1677.5399', '1956.6199', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 680, 'N'),
('', '100', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 630, 'N'),
('', '1000', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '257.6100', '429.7600', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 630, 'N'),
('', '1001', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '54.8700', '54.8700', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 630, 'N'),
('', '1008', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '7.8700', '7.8700', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 630, 'N'),
('', '1009', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '38.6100', '426.9000', '561.4100', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 680, 'N'),
('', '1009', '12', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', '', NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 0, 0, 0, 0, 0, 0, 440, 'N'),
('', '101', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 630, 'N'),
('', '1011', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '1177.4300', '5295.6600', '6495.5600', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 680, 'N'),
('', '1011', '12', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', '', NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 50, 50, 50, 0, 50, 40, 50, 0, 0, 0, 0, 0, 0, 340, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_by_default`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_by_default` (
  `store_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_store_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_store_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_store_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_category_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_category_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_last12months` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL,
  `my_store_spending_last90days_score` double DEFAULT '0',
  `my_store_spending_last12months_score` double DEFAULT '0',
  `my_store_spending_lifetime_score` double DEFAULT '0',
  `my_chain_spending_last90days_score` double DEFAULT '0',
  `my_chain_spending_last12months_score` double DEFAULT '0',
  `my_chain_spending_lifetime_score` double DEFAULT '0',
  `did_store_survey_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last12months_score` double DEFAULT '0',
  `my_direct_competitors_spending_lifetime_score` double DEFAULT '0',
  `did_competitor_store_survey_last90days_score` double DEFAULT '0',
  `my_category_spending_last90days_score` double DEFAULT '0',
  `my_category_spending_last12months_score` double DEFAULT '0',
  `my_category_spending_lifetime_score` double DEFAULT '0',
  `did_my_category_survey_last90days_score` double DEFAULT '0',
  `related_categories_spending_last90days_score` double DEFAULT '0',
  `related_categories_spending_last12months_score` double DEFAULT '0',
  `related_categories_spending_lifetime_score` double DEFAULT '0',
  `did_related_categories_survey_last90days_score` double DEFAULT '0',
  `spending_last180days_score` double DEFAULT '0',
  `spending_last360days_score` double DEFAULT '0',
  `spending_total_score` double DEFAULT '0',
  `bank_verified_and_active_score` double DEFAULT '0',
  `credit_verified_and_active_score` double DEFAULT '0',
  `cash_balance_today_score` double DEFAULT '0',
  `average_cash_balance_last24months_score` double DEFAULT '0',
  `credit_balance_today_score` double DEFAULT '0',
  `average_credit_balance_last24months_score` double DEFAULT '0',
  `total_score` double DEFAULT '0',
  `is_reported` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_by_default`
--

INSERT INTO `cacheview__store_score_by_default` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`, `my_store_spending_last90days_score`, `my_store_spending_last12months_score`, `my_store_spending_lifetime_score`, `my_chain_spending_last90days_score`, `my_chain_spending_last12months_score`, `my_chain_spending_lifetime_score`, `did_store_survey_last90days_score`, `my_direct_competitors_spending_last90days_score`, `my_direct_competitors_spending_last12months_score`, `my_direct_competitors_spending_lifetime_score`, `did_competitor_store_survey_last90days_score`, `my_category_spending_last90days_score`, `my_category_spending_last12months_score`, `my_category_spending_lifetime_score`, `did_my_category_survey_last90days_score`, `related_categories_spending_last90days_score`, `related_categories_spending_last12months_score`, `related_categories_spending_lifetime_score`, `did_related_categories_survey_last90days_score`, `spending_last180days_score`, `spending_last360days_score`, `spending_total_score`, `bank_verified_and_active_score`, `credit_verified_and_active_score`, `cash_balance_today_score`, `average_cash_balance_last24months_score`, `credit_balance_today_score`, `average_credit_balance_last24months_score`, `total_score`, `is_reported`) VALUES
('', '', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, 50, 40, 50, 20, 20, 50, 50, 50, 25, 355, 'N'),
('', '', '12', NULL, NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', NULL, NULL, NULL, '', '', NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 50, 40, 50, 0, 0, 0, 0, 0, 0, 140, 'N'),
('', '', '2', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '579.0000', '579.0000', 'N', '0.0000', '579.0000', '579.0000', 'N', '50165.4399', '50165.4399', '50165.4399', 'Y', 'Y', 4255.33984375, 2627.669921875, 1500, 4310.619954427083, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, NULL, 50, 50, 0, 50, 50, 50, 20, 20, 50, 50, 50, 50, 590, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_by_store`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_by_store` (
  `store_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_store_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_store_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_store_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_category_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_category_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_last12months` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL,
  `my_store_spending_last90days_score` double DEFAULT '0',
  `my_store_spending_last12months_score` double DEFAULT '0',
  `my_store_spending_lifetime_score` double DEFAULT '0',
  `my_chain_spending_last90days_score` double DEFAULT '0',
  `my_chain_spending_last12months_score` double DEFAULT '0',
  `my_chain_spending_lifetime_score` double DEFAULT '0',
  `did_store_survey_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last90days_score` double DEFAULT '0',
  `my_direct_competitors_spending_last12months_score` double DEFAULT '0',
  `my_direct_competitors_spending_lifetime_score` double DEFAULT '0',
  `did_competitor_store_survey_last90days_score` double DEFAULT '0',
  `my_category_spending_last90days_score` double DEFAULT '0',
  `my_category_spending_last12months_score` double DEFAULT '0',
  `my_category_spending_lifetime_score` double DEFAULT '0',
  `did_my_category_survey_last90days_score` double DEFAULT '0',
  `related_categories_spending_last90days_score` double DEFAULT '0',
  `related_categories_spending_last12months_score` double DEFAULT '0',
  `related_categories_spending_lifetime_score` double DEFAULT '0',
  `did_related_categories_survey_last90days_score` double DEFAULT '0',
  `spending_last180days_score` double DEFAULT '0',
  `spending_last360days_score` double DEFAULT '0',
  `spending_total_score` double DEFAULT '0',
  `bank_verified_and_active_score` double DEFAULT '0',
  `credit_verified_and_active_score` double DEFAULT '0',
  `cash_balance_today_score` double DEFAULT '0',
  `average_cash_balance_last24months_score` double DEFAULT '0',
  `credit_balance_today_score` double DEFAULT '0',
  `average_credit_balance_last24months_score` double DEFAULT '0',
  `total_score` double DEFAULT '0',
  `is_reported` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_by_store`
--

INSERT INTO `cacheview__store_score_by_store` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`, `my_store_spending_last90days_score`, `my_store_spending_last12months_score`, `my_store_spending_lifetime_score`, `my_chain_spending_last90days_score`, `my_chain_spending_last12months_score`, `my_chain_spending_lifetime_score`, `did_store_survey_last90days_score`, `my_direct_competitors_spending_last90days_score`, `my_direct_competitors_spending_last12months_score`, `my_direct_competitors_spending_lifetime_score`, `did_competitor_store_survey_last90days_score`, `my_category_spending_last90days_score`, `my_category_spending_last12months_score`, `my_category_spending_lifetime_score`, `did_my_category_survey_last90days_score`, `related_categories_spending_last90days_score`, `related_categories_spending_last12months_score`, `related_categories_spending_lifetime_score`, `did_related_categories_survey_last90days_score`, `spending_last180days_score`, `spending_last360days_score`, `spending_total_score`, `bank_verified_and_active_score`, `credit_verified_and_active_score`, `cash_balance_today_score`, `average_cash_balance_last24months_score`, `credit_balance_today_score`, `average_credit_balance_last24months_score`, `total_score`, `is_reported`) VALUES
('1', '', '1', '0.0000', '50.0400', '50.0400', '0.0000', '50.0400', '50.0400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '50.0400', '50.0400', 'N', '1.0000', '140.9600', '142.2100', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 830, 'N'),
('10', '', '1', '0.0000', '134.6400', '134.6400', '0.0000', '134.6400', '134.6400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '179.0200', '229.6800', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 830, 'N'),
('11', '', '1', '367.5800', '1893.0400', '1893.0400', '367.5800', '1893.0400', '1893.0400', 'N', '0.0000', '0.0000', '0.0000', 'N', '367.5800', '1978.9800', '1978.9800', 'N', '367.5800', '1978.9800', '1978.9800', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, 50, 50, 50, 50, 50, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 980, 'N'),
('2', '', '1', '36.7300', '53.6700', '53.6700', '36.7300', '53.6700', '53.6700', 'N', '0.0000', '0.0000', '0.0000', 'N', '36.7300', '93.6700', '93.6700', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, 50, 50, 50, 50, 50, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 980, 'N'),
('3', '', '76', '0.0000', '17.4900', '28.6400', '0.0000', '17.4900', '28.6400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '179.0200', '229.6800', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 1020, 'N'),
('4', '', '76', '44.4000', '126.0000', '133.3000', '44.4000', '126.0000', '133.3000', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1938.6400', '2475.6900', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, 50, 50, 50, 50, 50, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 1010, 'N'),
('6', '', '76', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '37.5000', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, NULL, 50, NULL, NULL, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 1030, 'N'),
('7', '', '1', '0.0000', '118.2800', '187.2800', '0.0000', '118.2800', '187.2800', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 880, 'N'),
('8', '', '1', '0.0000', '115.2500', '154.8800', '0.0000', '115.2500', '154.8800', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, 50, 50, 50, 0, 50, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 880, 'N'),
('9', '', '1', '0.0000', '20.1700', '20.1700', '0.0000', '20.1700', '20.1700', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '20.1700', '20.1700', 'N', '0.0000', '20.1700', '20.1700', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625, NULL, 50, 50, NULL, 50, 50, 0, NULL, NULL, NULL, 0, NULL, 50, 50, 0, NULL, 50, 50, 0, 50, 40, 50, 20, 20, 50, 50, 50, 50, 780, 'N');

--
-- Триггеры `cacheview__store_score_by_store`
--
DELIMITER $$
CREATE TRIGGER `triggerupdate__cacheview__store_score_by_store` AFTER UPDATE ON `cacheview__store_score_by_store`
 FOR EACH ROW BEGIN
	-- reset is_reported if the score changes by more than 5 points
	IF NEW.total_score <> OLD.total_score AND (NEW.total_score - OLD.total_score) > 5 THEN
		UPDATE cacheview__store_score_by_store SET is_reported = 'N' WHERE user_id=OLD.user_id AND store_id=OLD.store_id;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_data_by_category`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_data_by_category` (
  `store_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_store_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_store_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_store_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_category_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_category_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_last12months` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_data_by_category`
--

INSERT INTO `cacheview__store_score_data_by_category` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`) VALUES
('', '10', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '9.0000', '48.5000', '48.5000', 'N', '9.0000', '1677.5399', '1956.6199', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '100', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '1000', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '257.6100', '429.7600', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '1001', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '54.8700', '54.8700', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '1008', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '7.8700', '7.8700', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '1009', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '38.6100', '426.9000', '561.4100', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '101', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '1011', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '1177.4300', '5295.6600', '6495.5600', 'N', '1978.3000', '12749.8800', '15750.5300', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '102', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('', '104', '1', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '203.4900', '203.4900', 'N', '242.1100', '1224.9000', '6536.2101', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_data_by_default`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_data_by_default` (
  `store_id` char(0) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` char(0) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` bigint(20) DEFAULT NULL,
  `my_store_spending_last90days` int(1) NOT NULL DEFAULT '0',
  `my_store_spending_last12months` int(1) NOT NULL DEFAULT '0',
  `my_store_spending_lifetime` int(1) NOT NULL DEFAULT '0',
  `my_chain_spending_last90days` int(1) NOT NULL DEFAULT '0',
  `my_chain_spending_last12months` int(1) NOT NULL DEFAULT '0',
  `my_chain_spending_lifetime` int(1) NOT NULL DEFAULT '0',
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` int(1) NOT NULL DEFAULT '0',
  `my_direct_competitors_spending_last12months` int(1) NOT NULL DEFAULT '0',
  `my_direct_competitors_spending_lifetime` int(1) NOT NULL DEFAULT '0',
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` int(1) NOT NULL DEFAULT '0',
  `my_category_spending_last12months` int(1) NOT NULL DEFAULT '0',
  `my_category_spending_lifetime` int(1) NOT NULL DEFAULT '0',
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` int(1) NOT NULL DEFAULT '0',
  `related_categories_spending_last12months` int(1) NOT NULL DEFAULT '0',
  `related_categories_spending_lifetime` int(1) NOT NULL DEFAULT '0',
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_data_by_default`
--

INSERT INTO `cacheview__store_score_data_by_default` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`) VALUES
('', '', 2, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 'N', 0, 579, 579, 'N', 0, 579, 579, 'N', '50165.4399', '50165.4399', '50165.4399', 'Y', 'Y', 4255.33984375, 2627.669921875, 1500, 4310.619954427083),
('', '', 1, 0, 0, 0, 0, 0, 0, 'N', 0, 0, 0, 'N', 0, 0, 0, 'N', 0, 0, 0, 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__store_score_data_by_store`
--

CREATE TABLE IF NOT EXISTS `cacheview__store_score_data_by_store` (
  `store_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `sub_category_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `user_id` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_store_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_store_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_store_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_chain_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_direct_competitors_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_direct_competitors_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_competitor_store_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `my_category_spending_last90days` decimal(42,4) DEFAULT NULL,
  `my_category_spending_last12months` decimal(42,4) DEFAULT NULL,
  `my_category_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_my_category_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `related_categories_spending_last90days` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_last12months` decimal(42,4) DEFAULT NULL,
  `related_categories_spending_lifetime` decimal(42,4) DEFAULT NULL,
  `did_related_categories_survey_last90days` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `spending_last180days` decimal(42,4) DEFAULT NULL,
  `spending_last360days` decimal(42,4) DEFAULT NULL,
  `spending_total` decimal(42,4) DEFAULT NULL,
  `bank_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `credit_verified_and_active` varchar(1) CHARACTER SET utf8 NOT NULL DEFAULT '',
  `cash_balance_today` double DEFAULT NULL,
  `average_cash_balance_last24months` double DEFAULT NULL,
  `credit_balance_today` double DEFAULT NULL,
  `average_credit_balance_last24months` double DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__store_score_data_by_store`
--

INSERT INTO `cacheview__store_score_data_by_store` (`store_id`, `sub_category_id`, `user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `did_store_survey_last90days`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `did_competitor_store_survey_last90days`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `spending_last180days`, `spending_last360days`, `spending_total`, `bank_verified_and_active`, `credit_verified_and_active`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`) VALUES
('10013396', '', '1', '0.0000', '50.0400', '50.0400', '0.0000', '50.0400', '50.0400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '50.0400', '50.0400', 'N', '1.0000', '140.9600', '142.2100', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('10313031', '', '1', '36.7300', '53.6700', '53.6700', '36.7300', '53.6700', '53.6700', 'N', '0.0000', '0.0000', '0.0000', 'N', '36.7300', '93.6700', '93.6700', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('10393638', '', '1', '0.0000', '17.4900', '28.6400', '0.0000', '17.4900', '28.6400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '179.0200', '229.6800', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('10605995', '', '1', '44.4000', '126.0000', '133.3000', '44.4000', '126.0000', '133.3000', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1938.6400', '2475.6900', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('10717594', '', '1', '0.0000', '0.0000', '37.5000', '0.0000', '0.0000', '37.5000', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('11308935', '', '1', '0.0000', '118.2800', '187.2800', '0.0000', '118.2800', '187.2800', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('11369610', '', '1', '0.0000', '115.2500', '154.8800', '0.0000', '115.2500', '154.8800', 'N', '0.0000', '0.0000', '0.0000', 'N', '347.3500', '1876.1700', '2413.2200', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('11428483', '', '1', '0.0000', '20.1700', '20.1700', '0.0000', '20.1700', '20.1700', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '20.1700', '20.1700', 'N', '0.0000', '20.1700', '20.1700', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('11652154', '', '1', '0.0000', '134.6400', '134.6400', '0.0000', '134.6400', '134.6400', 'N', '0.0000', '0.0000', '0.0000', 'N', '0.0000', '179.0200', '229.6800', 'N', '415.0700', '2290.4400', '2984.9000', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625),
('11672238', '', '1', '367.5800', '1893.0400', '1893.0400', '367.5800', '1893.0400', '1893.0400', 'N', '0.0000', '0.0000', '0.0000', 'N', '367.5800', '1978.9800', '1978.9800', 'N', '367.5800', '1978.9800', '1978.9800', 'N', '113327.7000', '330034.0500', '467012.6402', 'Y', 'Y', 23822.2998046875, 3102.7874755859375, 6051.16015625, 3496.60400390625);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__where_user_shopped`
--

CREATE TABLE IF NOT EXISTS `cacheview__where_user_shopped` (
  `store_id` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `store_score` double DEFAULT NULL,
  `frequency` bigint(21) DEFAULT NULL,
  `name` varchar(250) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `table_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__where_user_shopped`
--

INSERT INTO `cacheview__where_user_shopped` (`store_id`, `user_id`, `store_score`, `frequency`, `name`, `zipcode`, `table_id`) VALUES
('1', '838616', 1100, 1, 'ENTERPRISE RENT-A-CAR', '90015', 64),
('1', '1465485', 1050, 1, 'PARADISE COVE BEACH CAFE', '90265', 65),
('1', '5895038', 1150, 1, 'PINK TACO - LOS ANGELES', '90067', 66),
('1', '225740', 1100, 2, 'SOHO', '33607', 67),
('1', '8949127', 900, 1, 'CHEVRON STATION AGOURA HILLS', '91301', 68),
('1', '9576276', 1100, 1, 'BEST BUY', '33020', 69),
('1', '15304466', 1000, 1, 'RITE AID', '48442', 70),
('1', '11774533', 1100, 9, 'GODADDY.COM INC', '94086', 71),
('1', '10769924', 1100, 1, 'GILT CITY', '90210', 72),
('1', '6536039', 1050, 1, 'TERRONI - BEVERLEY', '90036', 73);

-- --------------------------------------------------------

--
-- Структура таблицы `chain_match_rules`
--

CREATE TABLE IF NOT EXISTS `chain_match_rules` (
  `id` bigint(20) NOT NULL,
  `rule_type` enum('match','reject') NOT NULL DEFAULT 'match',
  `confidence` float NOT NULL,
  `match_chain_id` varchar(100) NOT NULL,
  `descriptor_id` bigint(20) NOT NULL,
  `details` varchar(600) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chain_match_rules`
--

INSERT INTO `chain_match_rules` (`id`, `rule_type`, `confidence`, `match_chain_id`, `descriptor_id`, `details`, `is_active`) VALUES
(8, 'reject', 100, '3', 82, '''_PAYEE_NAME_'' LIKE ''%Check%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Check%''', 'Y'),
(17, 'match', 100, '259', 82, '''_PAYEE_NAME_'' LIKE ''%Online Transfer to Chk ...7376 Transaction#:%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Online Transfer to Chk ...7376 Transaction#:%''', 'Y'),
(19, 'match', 100, '16880484', 213, '''_PAYEE_NAME_'' LIKE ''%amazon%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%amazon%''', 'Y'),
(30, 'match', 100, '16880603', 225, '''_PAYEE_NAME_'' LIKE ''%Online Transfer to CHK ...7384%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Online Transfer to CHK ...7384%''', 'Y'),
(31, 'match', 100, '16880606', 192, '''_PAYEE_NAME_'' LIKE ''%BMW BANK BMWFS PYMT%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%BMW BANK BMWFS PYMT%''', 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `commissions_alerts`
--

CREATE TABLE IF NOT EXISTS `commissions_alerts` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `alert_type` varchar(100) NOT NULL,
  `details` varchar(500) NOT NULL,
  `event_date` datetime NOT NULL,
  `status` enum('saved','active','expired','deleted') NOT NULL DEFAULT 'active',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL,
  `expiry_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `commissions_network`
--

CREATE TABLE IF NOT EXISTS `commissions_network` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_source_user_id` bigint(20) NOT NULL,
  `source_network_level` int(11) NOT NULL,
  `pay_out` float NOT NULL,
  `fee` float NOT NULL,
  `status` enum('pending','rejected','approved','paid','expired') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL,
  `expiry_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `commissions_transactions`
--

CREATE TABLE IF NOT EXISTS `commissions_transactions` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `_promotion_id` bigint(20) NOT NULL,
  `cashback` float NOT NULL,
  `transaction_amount` float NOT NULL,
  `pay_out` float NOT NULL,
  `fee` float NOT NULL,
  `status` enum('pending','rejected','approved','paid','expired') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL,
  `expiry_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `commissions_transactions`
--

INSERT INTO `commissions_transactions` (`id`, `_user_id`, `_transaction_id`, `_store_id`, `_promotion_id`, `cashback`, `transaction_amount`, `pay_out`, `fee`, `status`, `date_entered`, `last_updated`, `_last_updated_by`, `expiry_date`) VALUES
(1, 1, 914, 1, 14, 15, 22.56, 3.38, 0, 'pending', '2015-09-23 21:56:54', '0000-00-00 00:00:00', 0, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `commissions_transfers`
--

CREATE TABLE IF NOT EXISTS `commissions_transfers` (
  `id` bigint(20) NOT NULL,
  `_payee_id` bigint(20) NOT NULL,
  `_bank_id` bigint(20) NOT NULL,
  `account_number` varchar(300) NOT NULL,
  `account_name` varchar(500) NOT NULL,
  `routing_number` varchar(300) NOT NULL,
  `source` varchar(300) NOT NULL,
  `notes` text NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `amount` float NOT NULL,
  `bank_fees` float NOT NULL,
  `other_fees` float NOT NULL,
  `status` enum('pending','initiated','complete','failed','cancelled','rejected') NOT NULL DEFAULT 'pending',
  `is_deposit` enum('N','Y') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `cron_external_schedule`
--

CREATE TABLE IF NOT EXISTS `cron_external_schedule` (
  `id` bigint(20) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `job_code` varchar(300) NOT NULL,
  `job_string` varchar(500) NOT NULL,
  `scheduler` varchar(100) NOT NULL,
  `processer` varchar(100) NOT NULL,
  `is_scheduled` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_done` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `when_ran` datetime NOT NULL,
  `last_duration` int(11) NOT NULL,
  `last_result` enum('success','fail','none') NOT NULL DEFAULT 'none',
  `repeat_code` varchar(100) NOT NULL DEFAULT 'never'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `cron_log`
--

CREATE TABLE IF NOT EXISTS `cron_log` (
  `id` bigint(20) NOT NULL,
  `_cron_job_id` bigint(20) DEFAULT NULL,
  `user_id` varchar(100) NOT NULL,
  `job_type` varchar(100) NOT NULL,
  `activity_code` varchar(100) NOT NULL,
  `result` varchar(100) NOT NULL,
  `uri` varchar(300) NOT NULL,
  `log_details` varchar(500) NOT NULL,
  `record_count` bigint(20) NOT NULL,
  `ip_address` varchar(100) NOT NULL,
  `event_time` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cron_log`
--

INSERT INTO `cron_log` (`id`, `_cron_job_id`, `user_id`, `job_type`, `activity_code`, `result`, `uri`, `log_details`, `record_count`, `ip_address`, `event_time`) VALUES
(1, 1, '1', 'transaction_data', 'pull_all_user_transactions', 'success', 'transaction/pull_all_user_transactions/bankid=8502', 'ip=0.0.0.0', 164, '0.0.0.0', '2015-08-28 00:00:00'),
(2, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:51:33'),
(3, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:53:36'),
(4, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:54:19'),
(5, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:56:37'),
(6, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:58:27'),
(7, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:58:39'),
(8, 7, '', 'cron', 'backup_cron_log', 'fail', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:58:52'),
(9, 7, '', 'cron', 'backup_cron_log', 'success', 'cron/backup_cron_log/jobid/7', '', 1, '127.0.0.1', '2015-10-07 20:59:47'),
(10, 13, 'system', 'message_cron', 'send_pending_invitations', 'fail', 'message_cron/send_pending_invitations/jobid/13', '', 1, '127.0.0.1', '2015-12-17 18:47:39');

-- --------------------------------------------------------

--
-- Структура таблицы `cron_schedule`
--

CREATE TABLE IF NOT EXISTS `cron_schedule` (
  `id` bigint(20) NOT NULL,
  `job_type` varchar(100) NOT NULL,
  `activity_code` varchar(100) NOT NULL,
  `cron_value` varchar(300) NOT NULL,
  `is_scheduled` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_done` enum('Y','N') NOT NULL DEFAULT 'N',
  `run_time` datetime NOT NULL,
  `when_ran` datetime NOT NULL,
  `last_result` enum('none','success','fail') NOT NULL DEFAULT 'none',
  `repeat_code` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cron_schedule`
--

INSERT INTO `cron_schedule` (`id`, `job_type`, `activity_code`, `cron_value`, `is_scheduled`, `is_done`, `run_time`, `when_ran`, `last_result`, `repeat_code`) VALUES
(1, 'transaction_cron', 'pull_all_user_transactions', 'user=1,bankcode=chase,bankid=8502', 'N', 'Y', '2015-08-26 00:00:00', '2015-08-27 00:00:00', 'success', 'end_of_day'),
(2, 'cron', 'fetch_and_run_sys_jobs', '', 'N', 'N', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'default'),
(3, 'cron', 'update_query_cache', '', 'N', 'Y', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'end_of_day'),
(4, 'cron', 'update_message_cache', '', 'N', 'Y', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'end_of_day'),
(5, 'transaction_cron', 'pull_all_user_transactions', 'user=1,bankcode=bofa,bankid=3832', 'N', 'Y', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'now'),
(6, 'transaction_cron', 'pull_all_user_transactions', 'user=1,bankcode=usaa,bankid=11396', 'N', 'Y', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'now'),
(7, 'cron', 'backup_cron_log', '', 'N', 'N', '0000-00-00 00:00:00', '2015-10-07 20:59:49', 'success', 'end_of_day'),
(10, 'message_cron', 'activate_more_messages', '', 'N', 'N', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'none', 'end_of_day'),
(11, 'message_cron', 'send_first_reminder', '', 'N', 'N', '0000-00-00 00:00:00', '2015-12-17 19:15:24', 'success', 'every_hour'),
(12, 'message_cron', 'send_second_reminder', '', 'N', 'N', '0000-00-00 00:00:00', '2015-12-17 19:13:56', 'fail', 'every_hour');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_ad_spending_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_ad_spending_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_ad_spending_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_ad_spending_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_ad_spending_total`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_ad_spending_total` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_average_cash_balance_last24months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_average_cash_balance_last24months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_average_cash_balance_last24months`
--

INSERT INTO `datatable__frequency_average_cash_balance_last24months` (`data_value`, `frequency`) VALUES
(3276, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_average_credit_balance_last24months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_average_credit_balance_last24months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_average_credit_balance_last24months`
--

INSERT INTO `datatable__frequency_average_credit_balance_last24months` (`data_value`, `frequency`) VALUES
(2259, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_cash_balance_today`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_cash_balance_today` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_cash_balance_today`
--

INSERT INTO `datatable__frequency_cash_balance_today` (`data_value`, `frequency`) VALUES
(0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_credit_balance_today`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_credit_balance_today` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_credit_balance_today`
--

INSERT INTO `datatable__frequency_credit_balance_today` (`data_value`, `frequency`) VALUES
(0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_category_spending_last12months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_category_spending_last12months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_category_spending_last12months`
--

INSERT INTO `datatable__frequency_my_category_spending_last12months` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 2),
(4, 2),
(5, 0),
(6, 9),
(8, 8),
(9, 0),
(10, 3),
(11, 0),
(12, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_category_spending_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_category_spending_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_category_spending_last90days`
--

INSERT INTO `datatable__frequency_my_category_spending_last90days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_category_spending_lifetime`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_category_spending_lifetime` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_category_spending_lifetime`
--

INSERT INTO `datatable__frequency_my_category_spending_lifetime` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 2),
(4, 2),
(5, 0),
(6, 9),
(8, 8),
(9, 0),
(10, 3),
(11, 0),
(12, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_chain_spending_last12months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_chain_spending_last12months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_chain_spending_last12months`
--

INSERT INTO `datatable__frequency_my_chain_spending_last12months` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 1),
(4, 2),
(5, 3),
(6, 2),
(8, 4),
(9, 3),
(10, 4),
(11, 0),
(12, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_chain_spending_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_chain_spending_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_chain_spending_last90days`
--

INSERT INTO `datatable__frequency_my_chain_spending_last90days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_chain_spending_lifetime`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_chain_spending_lifetime` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_chain_spending_lifetime`
--

INSERT INTO `datatable__frequency_my_chain_spending_lifetime` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 1),
(4, 2),
(5, 3),
(6, 2),
(8, 4),
(9, 3),
(10, 4),
(11, 0),
(12, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_direct_competitors_spending_last12months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_direct_competitors_spending_last12months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_direct_competitors_spending_last12months`
--

INSERT INTO `datatable__frequency_my_direct_competitors_spending_last12months` (`data_value`, `frequency`) VALUES
(2, 1),
(8, 1),
(10, 1),
(15, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_direct_competitors_spending_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_direct_competitors_spending_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_direct_competitors_spending_lifetime`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_direct_competitors_spending_lifetime` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_store_spending_last12months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_store_spending_last12months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_store_spending_last12months`
--

INSERT INTO `datatable__frequency_my_store_spending_last12months` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 1),
(4, 2),
(5, 3),
(6, 2),
(8, 4),
(9, 3),
(10, 4),
(11, 0),
(12, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_store_spending_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_store_spending_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_store_spending_last90days`
--

INSERT INTO `datatable__frequency_my_store_spending_last90days` (`data_value`, `frequency`) VALUES
(0, 0),
(40, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_my_store_spending_lifetime`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_my_store_spending_lifetime` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_my_store_spending_lifetime`
--

INSERT INTO `datatable__frequency_my_store_spending_lifetime` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 1),
(4, 2),
(5, 3),
(6, 2),
(8, 4),
(9, 3),
(10, 4),
(11, 0),
(12, 2);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_number_of_direct_referrals_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_number_of_direct_referrals_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_number_of_direct_referrals_last180days`
--

INSERT INTO `datatable__frequency_number_of_direct_referrals_last180days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_number_of_direct_referrals_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_number_of_direct_referrals_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_number_of_direct_referrals_last360days`
--

INSERT INTO `datatable__frequency_number_of_direct_referrals_last360days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_number_of_network_referrals_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_number_of_network_referrals_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_number_of_network_referrals_last180days`
--

INSERT INTO `datatable__frequency_number_of_network_referrals_last180days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_number_of_network_referrals_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_number_of_network_referrals_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_number_of_network_referrals_last360days`
--

INSERT INTO `datatable__frequency_number_of_network_referrals_last360days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_number_of_surveys_answered_in_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_number_of_surveys_answered_in_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_number_of_surveys_answered_in_last90days`
--

INSERT INTO `datatable__frequency_number_of_surveys_answered_in_last90days` (`data_value`, `frequency`) VALUES
(1, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_related_categories_spending_last12months`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_related_categories_spending_last12months` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_related_categories_spending_last12months`
--

INSERT INTO `datatable__frequency_related_categories_spending_last12months` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 0),
(4, 1),
(5, 0),
(6, 7),
(8, 1),
(9, 0),
(10, 3),
(11, 0),
(12, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_related_categories_spending_last90days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_related_categories_spending_last90days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_related_categories_spending_last90days`
--

INSERT INTO `datatable__frequency_related_categories_spending_last90days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_related_categories_spending_lifetime`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_related_categories_spending_lifetime` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_related_categories_spending_lifetime`
--

INSERT INTO `datatable__frequency_related_categories_spending_lifetime` (`data_value`, `frequency`) VALUES
(2, 0),
(3, 0),
(4, 1),
(5, 0),
(6, 1),
(8, 1),
(9, 0),
(10, 3),
(11, 0),
(12, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_spending_last180days`
--

INSERT INTO `datatable__frequency_spending_last180days` (`data_value`, `frequency`) VALUES
(0, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_spending_last360days`
--

INSERT INTO `datatable__frequency_spending_last360days` (`data_value`, `frequency`) VALUES
(1544, 1),
(9252, 0),
(13878, 0),
(18504, 0),
(23130, 0),
(27756, 0),
(32382, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_of_direct_referrals_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_of_direct_referrals_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_of_direct_referrals_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_of_direct_referrals_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_of_network_referrals_last180days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_of_network_referrals_last180days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_of_network_referrals_last360days`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_of_network_referrals_last360days` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_spending_total`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_spending_total` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__frequency_spending_total`
--

INSERT INTO `datatable__frequency_spending_total` (`data_value`, `frequency`) VALUES
(4626, 0),
(9252, 0),
(13878, 0),
(18504, 0),
(23130, 0),
(27756, 0),
(32382, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_total_direct_referrals`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_total_direct_referrals` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_total_network_referrals`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_total_network_referrals` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_total_spending_of_direct_referrals`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_total_spending_of_direct_referrals` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__frequency_total_spending_of_network_referrals`
--

CREATE TABLE IF NOT EXISTS `datatable__frequency_total_spending_of_network_referrals` (
  `data_value` bigint(20) NOT NULL,
  `frequency` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__network_data`
--

CREATE TABLE IF NOT EXISTS `datatable__network_data` (
  `user_id` bigint(20) NOT NULL,
  `level_1` longtext NOT NULL,
  `level_2` longtext NOT NULL,
  `level_3` longtext NOT NULL,
  `level_4` longtext NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__network_data`
--

INSERT INTO `datatable__network_data` (`user_id`, `level_1`, `level_2`, `level_3`, `level_4`, `is_processed`) VALUES
(23, '13', '', '', '', 'N');

--
-- Триггеры `datatable__network_data`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__datatable__network_data` AFTER INSERT ON `datatable__network_data`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET number_of_network_referrals_last180days=(number_of_network_referrals_last180days+1), 
		number_of_network_referrals_last360days=(number_of_network_referrals_last360days+1), 
		total_network_referrals=(total_network_referrals+1)
	WHERE user_id=NEW.user_id;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerupdate__datatable__network_data` AFTER UPDATE ON `datatable__network_data`
 FOR EACH ROW BEGIN

	-- get the previous network referral counts
	SELECT number_of_network_referrals_last180days, number_of_network_referrals_last360days, total_network_referrals 
	FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW.user_id
	INTO @number_of_network_referrals_last180days, @number_of_network_referrals_last360days, @total_network_referrals;

	-- update user cache data
	IF LENGTH(NEW.level_1) > LENGTH(OLD.level_1) OR LENGTH(NEW.level_2) > LENGTH(OLD.level_2) OR LENGTH(NEW.level_3) > LENGTH(OLD.level_3) OR LENGTH(NEW.level_4) > LENGTH(OLD.level_4) THEN
		UPDATE clout_v1_3cron.datatable__user_data SET number_of_network_referrals_last180days=(number_of_network_referrals_last180days+1), 
			number_of_network_referrals_last360days=(number_of_network_referrals_last360days+1), 
			total_network_referrals=(total_network_referrals+1)
		WHERE user_id=NEW.user_id;

		-- update the frequency cache for the ranked data-points
		-- INCREMENT
		INSERT INTO clout_v1_3cron.datatable__frequency_number_of_network_referrals_last180days (data_value, frequency) 
		(SELECT (@number_of_network_referrals_last180days+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

		INSERT INTO clout_v1_3cron.datatable__frequency_number_of_network_referrals_last360days (data_value, frequency) 
		(SELECT (@number_of_network_referrals_last360days+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

		INSERT INTO clout_v1_3cron.datatable__frequency_total_network_referrals (data_value, frequency) 
		(SELECT (@total_network_referrals+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

		-- DECREMENT
		UPDATE clout_v1_3cron.datatable__frequency_number_of_network_referrals_last180days SET frequency=(frequency - 1) WHERE data_value= (@number_of_network_referrals_last180days - 1);
		UPDATE clout_v1_3cron.datatable__frequency_number_of_network_referrals_last360days SET frequency=(frequency - 1) WHERE data_value= (@number_of_network_referrals_last360days - 1);
		UPDATE clout_v1_3cron.datatable__frequency_total_network_referrals SET frequency=(frequency - 1) WHERE data_value= (@total_network_referrals - 1);

	ELSEIF LENGTH(NEW.level_1) < LENGTH(OLD.level_1) OR LENGTH(NEW.level_2) < LENGTH(OLD.level_2) OR LENGTH(NEW.level_3) < LENGTH(OLD.level_3) OR LENGTH(NEW.level_4) < LENGTH(OLD.level_4) THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_network_referrals=(total_network_referrals - 1)
		WHERE user_id=NEW.user_id;

		-- add to the new frequency value
		INSERT INTO clout_v1_3cron.datatable__frequency_total_network_referrals (data_value, frequency) 
		(SELECT (@total_network_referrals - 1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);
		-- remove from the old frequency value
		UPDATE clout_v1_3cron.datatable__frequency_total_network_referrals SET frequency=(frequency - 1) WHERE data_value = @total_network_referrals;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_344269_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_344269_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_344269_data`
--

INSERT INTO `datatable__store_344269_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '45', '0', 'N', '0', '45', '0', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_344269_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_344269_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_344269_data__age`
--

INSERT INTO `datatable__store_344269_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2016-09-12 15:42:08', '2017-06-15 15:42:08', '2016-09-12 15:42:08', '2017-06-15 15:42:08', '2016-09-12 15:42:08', '2017-06-15 15:42:08', '2016-09-12 15:42:08', '2016-11-15 15:42:08', '2016-09-11 11:59:42', '2016-09-12 15:42:08', '2016-11-15 15:42:08', '2016-09-11 11:59:42');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_6334156_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_6334156_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_6334156_data`
--

INSERT INTO `datatable__store_6334156_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 4, 4, 0, 4, 4, 0, 2, 4, '0', '4', '4', 'N', '0', '4', '4', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_6334156_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_6334156_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_6334156_data__age`
--

INSERT INTO `datatable__store_6334156_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:19', '2016-11-08 21:54:19', '2062-08-28 21:54:19', '2016-11-08 21:54:19', '2016-09-12 15:42:08', '2016-11-08 15:42:08', '2062-08-28 21:54:19', '2016-11-08 21:54:19', '0000-00-00 00:00:00', '2062-08-28 21:54:19', '2016-11-08 21:54:19', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_8250262_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_8250262_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_8250262_data`
--

INSERT INTO `datatable__store_8250262_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 53.9, 53.9, 0, 53.9, 53.9, 0, 0, 0, '0', '54', '54', 'N', '0', '54', '54', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_8250262_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_8250262_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_8250262_data__age`
--

INSERT INTO `datatable__store_8250262_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:06', '2016-11-16 21:54:06', '2062-08-28 21:54:06', '2016-11-16 21:54:06', '2016-09-12 15:42:09', '2017-06-15 15:42:09', '2062-08-28 21:54:06', '2016-11-16 21:54:06', '2016-09-11 11:59:42', '2062-08-28 21:54:06', '2016-11-16 21:54:06', '2016-09-11 11:59:42');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_13267924_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_13267924_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_13267924_data`
--

INSERT INTO `datatable__store_13267924_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 40.47, 29, 29, 0, 29, 29, 0, 14.5, 29, '0', '30', '30', 'Y', '0', '30', '30', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_13267924_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_13267924_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_13267924_data__age`
--

INSERT INTO `datatable__store_13267924_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2016-11-16 21:39:43', '2016-10-12 21:54:09', '2062-08-28 21:54:09', '2016-10-12 21:54:09', '2016-09-12 15:42:03', '2016-10-12 15:42:03', '2062-08-28 21:54:09', '2016-10-12 21:54:09', '2016-09-11 12:49:37', '2062-08-28 21:54:09', '2016-10-12 21:54:09', '2016-09-11 12:49:37');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_13536808_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_13536808_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_13536808_data`
--

INSERT INTO `datatable__store_13536808_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 15.4, 15.4, 0, 15.4, 15.4, 0, 7.7, 15.4, '0', '16', '16', 'N', '0', '16', '16', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_13536808_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_13536808_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_13536808_data__age`
--

INSERT INTO `datatable__store_13536808_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:07', '2016-11-15 21:54:07', '2062-08-28 21:54:07', '2016-11-15 21:54:07', '2016-09-12 15:42:03', '2016-11-15 15:42:03', '2062-08-28 21:54:07', '2016-11-15 21:54:07', '2016-09-11 11:59:42', '2062-08-28 21:54:07', '2016-11-15 21:54:07', '2016-09-11 11:59:42');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16365959_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16365959_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16365959_data`
--

INSERT INTO `datatable__store_16365959_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 19.7, 19.7, 0, 19.7, 19.7, 0, 9.85, 19.7, '0', '20', '20', 'N', '0', '20', '20', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16365959_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16365959_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16365959_data__age`
--

INSERT INTO `datatable__store_16365959_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:02', '2016-11-16 21:54:02', '2062-08-28 21:54:02', '2016-11-16 21:54:02', '2016-09-12 15:42:03', '2016-11-16 15:42:03', '2062-08-28 21:54:02', '2016-11-16 21:54:02', '2016-09-11 11:59:42', '2062-08-28 21:54:02', '2016-11-16 21:54:02', '2016-09-11 11:59:42');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960491_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960491_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960491_data`
--

INSERT INTO `datatable__store_16960491_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 67.45, 67.45, 0, 26.98, 26.98, 0, 0, 0, '0', '26', '26', 'N', '0', '26', '26', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960491_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960491_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960491_data__age`
--

INSERT INTO `datatable__store_16960491_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:00', '2016-11-16 21:54:00', '2062-08-28 21:54:00', '2016-11-16 21:54:00', '2016-09-12 15:42:03', '2017-06-15 15:42:03', '2062-08-28 21:54:00', '2016-11-16 21:54:00', '0000-00-00 00:00:00', '2062-08-28 21:54:00', '2016-11-16 21:54:00', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960494_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960494_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960494_data`
--

INSERT INTO `datatable__store_16960494_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 56.72, 56.72, 0, 56.72, 56.72, 0, 0, 0, '0', '56', '56', 'N', '0', '56', '56', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960494_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960494_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960494_data__age`
--

INSERT INTO `datatable__store_16960494_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:03', '2016-11-16 21:54:03', '2062-08-28 21:54:03', '2016-11-16 21:54:03', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:03', '2016-11-16 21:54:03', '0000-00-00 00:00:00', '2062-08-28 21:54:03', '2016-11-16 21:54:03', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960496_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960496_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960496_data`
--

INSERT INTO `datatable__store_16960496_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 22, 22, 0, 22, 22, 0, 0, 0, '0', '22', '22', 'N', '0', '22', '22', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960496_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960496_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960496_data__age`
--

INSERT INTO `datatable__store_16960496_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:04', '2016-11-01 21:54:04', '2062-08-28 21:54:04', '2016-11-01 21:54:04', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:04', '2016-11-01 21:54:04', '0000-00-00 00:00:00', '2062-08-28 21:54:04', '2016-11-01 21:54:04', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960498_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960498_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960498_data`
--

INSERT INTO `datatable__store_16960498_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 67, 67, 0, 67, 67, 0, 0, 0, '0', '68', '68', 'N', '0', '68', '68', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960498_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960498_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960498_data__age`
--

INSERT INTO `datatable__store_16960498_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:08', '2016-11-15 21:54:08', '2062-08-28 21:54:08', '2016-11-15 21:54:08', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:08', '2016-11-15 21:54:08', '0000-00-00 00:00:00', '2062-08-28 21:54:08', '2016-11-15 21:54:08', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960500_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960500_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960500_data`
--

INSERT INTO `datatable__store_16960500_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 85.24, 85.24, 0, 85.24, 85.24, 0, 0, 0, '0', '86', '86', 'N', '0', '86', '86', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960500_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960500_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960500_data__age`
--

INSERT INTO `datatable__store_16960500_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:10', '2016-11-15 21:54:10', '2062-08-28 21:54:10', '2016-11-15 21:54:10', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:10', '2016-11-15 21:54:10', '0000-00-00 00:00:00', '2062-08-28 21:54:10', '2016-11-15 21:54:10', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960502_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960502_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960502_data`
--

INSERT INTO `datatable__store_16960502_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 40.18, 40.18, 0, 40.18, 40.18, 0, 0, 0, '0', '40', '40', 'N', '0', '40', '40', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960502_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960502_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960502_data__age`
--

INSERT INTO `datatable__store_16960502_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:12', '2016-10-21 21:54:12', '2062-08-28 21:54:12', '2016-10-21 21:54:12', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:12', '2016-10-21 21:54:12', '0000-00-00 00:00:00', '2062-08-28 21:54:12', '2016-10-21 21:54:12', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960504_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960504_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960504_data`
--

INSERT INTO `datatable__store_16960504_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 140.72, 140.72, 0, 140.72, 140.72, 0, 0, 0, '0', '140', '140', 'N', '0', '140', '140', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960504_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960504_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960504_data__age`
--

INSERT INTO `datatable__store_16960504_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:13', '2016-10-08 21:54:13', '2062-08-28 21:54:13', '2016-10-08 21:54:13', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:13', '2016-10-08 21:54:13', '0000-00-00 00:00:00', '2062-08-28 21:54:13', '2016-10-08 21:54:13', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960506_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960506_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960506_data`
--

INSERT INTO `datatable__store_16960506_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 59.12, 59.12, 0, 59.12, 59.12, 0, 0, 0, '0', '60', '60', 'N', '0', '60', '60', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960506_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960506_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960506_data__age`
--

INSERT INTO `datatable__store_16960506_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:14', '2016-11-10 21:54:14', '2062-08-28 21:54:14', '2016-11-10 21:54:14', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:14', '2016-11-10 21:54:14', '0000-00-00 00:00:00', '2062-08-28 21:54:14', '2016-11-10 21:54:14', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960508_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960508_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960508_data`
--

INSERT INTO `datatable__store_16960508_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 141.6, 141.6, 0, 141.6, 141.6, 0, 0, 0, '0', '142', '142', 'N', '0', '142', '142', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960508_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960508_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960508_data__age`
--

INSERT INTO `datatable__store_16960508_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:15', '2016-10-14 21:54:15', '2062-08-28 21:54:15', '2016-10-14 21:54:15', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:15', '2016-10-14 21:54:15', '0000-00-00 00:00:00', '2062-08-28 21:54:15', '2016-10-14 21:54:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960510_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960510_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960510_data`
--

INSERT INTO `datatable__store_16960510_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 5.98, 5.98, 0, 5.98, 5.98, 0, 0, 0, '0', '6', '6', 'N', '0', '6', '6', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960510_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960510_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960510_data__age`
--

INSERT INTO `datatable__store_16960510_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:17', '2016-11-10 21:54:17', '2062-08-28 21:54:17', '2016-11-10 21:54:17', '2016-09-12 15:42:04', '2017-06-15 15:42:04', '2062-08-28 21:54:17', '2016-11-10 21:54:17', '0000-00-00 00:00:00', '2062-08-28 21:54:17', '2016-11-10 21:54:17', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960512_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960512_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960512_data`
--

INSERT INTO `datatable__store_16960512_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.5, 7.5, 0, 7.5, 7.5, 0, 0, 0, '0', '8', '8', 'N', '0', '8', '8', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960512_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960512_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960512_data__age`
--

INSERT INTO `datatable__store_16960512_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:18', '2016-10-19 21:54:18', '2062-08-28 21:54:18', '2016-10-19 21:54:18', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:18', '2016-10-19 21:54:18', '0000-00-00 00:00:00', '2062-08-28 21:54:18', '2016-10-19 21:54:18', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960514_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960514_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960514_data`
--

INSERT INTO `datatable__store_16960514_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 809.08, 809.08, 0, 809.08, 809.08, 0, 0, 0, '0', '810', '810', 'N', '0', '810', '810', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960514_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960514_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960514_data__age`
--

INSERT INTO `datatable__store_16960514_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:20', '2016-10-07 21:54:20', '2062-08-28 21:54:20', '2016-10-07 21:54:20', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:20', '2016-10-07 21:54:20', '0000-00-00 00:00:00', '2062-08-28 21:54:20', '2016-10-07 21:54:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960516_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960516_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960516_data`
--

INSERT INTO `datatable__store_16960516_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 23.7, 23.7, 0, 23.7, 23.7, 0, 0, 0, '0', '24', '24', 'N', '0', '24', '24', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960516_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960516_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960516_data__age`
--

INSERT INTO `datatable__store_16960516_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:22', '2016-11-09 21:54:22', '2062-08-28 21:54:22', '2016-11-09 21:54:22', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:22', '2016-11-09 21:54:22', '0000-00-00 00:00:00', '2062-08-28 21:54:22', '2016-11-09 21:54:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960518_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960518_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960518_data`
--

INSERT INTO `datatable__store_16960518_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 15.5, 15.5, 0, 15.5, 15.5, 0, 0, 0, '0', '16', '16', 'N', '0', '16', '16', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960518_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960518_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960518_data__age`
--

INSERT INTO `datatable__store_16960518_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:23', '2016-11-08 21:54:23', '2062-08-28 21:54:23', '2016-11-08 21:54:23', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:23', '2016-11-08 21:54:23', '0000-00-00 00:00:00', '2062-08-28 21:54:23', '2016-11-08 21:54:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960520_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960520_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960520_data`
--

INSERT INTO `datatable__store_16960520_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 15.96, 15.96, 0, 15.96, 15.96, 0, 0, 0, '0', '16', '16', 'N', '0', '16', '16', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960520_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960520_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960520_data__age`
--

INSERT INTO `datatable__store_16960520_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:24', '2016-11-08 21:54:24', '2062-08-28 21:54:24', '2016-11-08 21:54:24', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:24', '2016-11-08 21:54:24', '0000-00-00 00:00:00', '2062-08-28 21:54:24', '2016-11-08 21:54:24', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960522_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960522_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960522_data`
--

INSERT INTO `datatable__store_16960522_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 9, 9, 0, 9, 9, 0, 0, 0, '0', '10', '10', 'N', '0', '10', '10', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960522_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960522_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960522_data__age`
--

INSERT INTO `datatable__store_16960522_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:25', '2016-11-08 21:54:25', '2062-08-28 21:54:25', '2016-11-08 21:54:25', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:25', '2016-11-08 21:54:25', '0000-00-00 00:00:00', '2062-08-28 21:54:25', '2016-11-08 21:54:25', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960524_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960524_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960524_data`
--

INSERT INTO `datatable__store_16960524_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 80.64, 80.64, 0, 80.64, 80.64, 0, 0, 0, '0', '80', '80', 'N', '0', '80', '80', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960524_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960524_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960524_data__age`
--

INSERT INTO `datatable__store_16960524_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:27', '2016-11-08 21:54:27', '2062-08-28 21:54:27', '2016-11-08 21:54:27', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:27', '2016-11-08 21:54:27', '0000-00-00 00:00:00', '2062-08-28 21:54:27', '2016-11-08 21:54:27', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960526_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960526_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960526_data`
--

INSERT INTO `datatable__store_16960526_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 73.7, 73.7, 0, 73.7, 73.7, 0, 0, 0, '0', '74', '74', 'N', '0', '74', '74', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960526_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960526_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960526_data__age`
--

INSERT INTO `datatable__store_16960526_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:28', '2016-11-02 21:54:28', '2062-08-28 21:54:28', '2016-11-02 21:54:28', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:28', '2016-11-02 21:54:28', '0000-00-00 00:00:00', '2062-08-28 21:54:28', '2016-11-02 21:54:28', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960528_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960528_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960528_data`
--

INSERT INTO `datatable__store_16960528_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 33, 33, 0, 33, 33, 0, 0, 0, '0', '34', '34', 'N', '0', '34', '34', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960528_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960528_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960528_data__age`
--

INSERT INTO `datatable__store_16960528_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:29', '2016-11-08 21:54:29', '2062-08-28 21:54:29', '2016-11-08 21:54:29', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:29', '2016-11-08 21:54:29', '0000-00-00 00:00:00', '2062-08-28 21:54:29', '2016-11-08 21:54:29', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960530_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960530_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960530_data`
--

INSERT INTO `datatable__store_16960530_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 12.12, 12.12, 0, 12.12, 12.12, 0, 0, 0, '0', '12', '12', 'N', '0', '12', '12', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960530_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960530_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960530_data__age`
--

INSERT INTO `datatable__store_16960530_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:31', '2016-11-08 21:54:31', '2062-08-28 21:54:31', '2016-11-08 21:54:31', '2016-09-12 15:42:05', '2017-06-15 15:42:05', '2062-08-28 21:54:31', '2016-11-08 21:54:31', '0000-00-00 00:00:00', '2062-08-28 21:54:31', '2016-11-08 21:54:31', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960532_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960532_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960532_data`
--

INSERT INTO `datatable__store_16960532_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 36.42, 36.42, 0, 36.42, 36.42, 0, 0, 0, '0', '36', '36', 'N', '0', '36', '36', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960532_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960532_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960532_data__age`
--

INSERT INTO `datatable__store_16960532_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:32', '2016-11-05 21:54:32', '2062-08-28 21:54:32', '2016-11-05 21:54:32', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:32', '2016-11-05 21:54:32', '0000-00-00 00:00:00', '2062-08-28 21:54:32', '2016-11-05 21:54:32', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960536_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960536_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960536_data`
--

INSERT INTO `datatable__store_16960536_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 77.58, 77.58, 0, 77.58, 77.58, 0, 0, 0, '0', '78', '78', 'N', '0', '78', '78', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960536_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960536_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960536_data__age`
--

INSERT INTO `datatable__store_16960536_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:33', '2016-11-03 21:54:33', '2062-08-28 21:54:33', '2016-11-03 21:54:33', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:33', '2016-11-03 21:54:33', '0000-00-00 00:00:00', '2062-08-28 21:54:33', '2016-11-03 21:54:33', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960538_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960538_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960538_data`
--

INSERT INTO `datatable__store_16960538_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 241.88, 241.88, 0, 241.88, 241.88, 0, 0, 0, '0', '242', '242', 'N', '0', '242', '242', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960538_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960538_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960538_data__age`
--

INSERT INTO `datatable__store_16960538_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:34', '2016-10-04 21:54:34', '2062-08-28 21:54:34', '2016-10-04 21:54:34', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:34', '2016-10-04 21:54:34', '0000-00-00 00:00:00', '2062-08-28 21:54:34', '2016-10-04 21:54:34', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960540_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960540_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960540_data`
--

INSERT INTO `datatable__store_16960540_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 223.96, 223.96, 0, 223.96, 223.96, 0, 0, 0, '0', '224', '224', 'N', '0', '224', '224', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960540_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960540_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960540_data__age`
--

INSERT INTO `datatable__store_16960540_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:36', '2016-11-02 21:54:36', '2062-08-28 21:54:36', '2016-11-02 21:54:36', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:36', '2016-11-02 21:54:36', '0000-00-00 00:00:00', '2062-08-28 21:54:36', '2016-11-02 21:54:36', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960542_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960542_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960542_data`
--

INSERT INTO `datatable__store_16960542_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 17.06, 17.06, 0, 17.06, 17.06, 0, 0, 0, '0', '18', '18', 'N', '0', '18', '18', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960542_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960542_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960542_data__age`
--

INSERT INTO `datatable__store_16960542_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:37', '2016-11-01 21:54:37', '2062-08-28 21:54:37', '2016-11-01 21:54:37', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:37', '2016-11-01 21:54:37', '0000-00-00 00:00:00', '2062-08-28 21:54:37', '2016-11-01 21:54:37', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960544_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960544_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960544_data`
--

INSERT INTO `datatable__store_16960544_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 9.78, 9.78, 0, 9.78, 9.78, 0, 0, 0, '0', '10', '10', 'N', '0', '10', '10', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960544_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960544_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960544_data__age`
--

INSERT INTO `datatable__store_16960544_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:38', '2016-11-01 21:54:38', '2062-08-28 21:54:38', '2016-11-01 21:54:38', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:38', '2016-11-01 21:54:38', '0000-00-00 00:00:00', '2062-08-28 21:54:38', '2016-11-01 21:54:38', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960546_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960546_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960546_data`
--

INSERT INTO `datatable__store_16960546_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 1137.92, 1137.92, 0, 1137.92, 1137.92, 0, 0, 0, '0', '1138', '1138', 'N', '0', '1138', '1138', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960546_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960546_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960546_data__age`
--

INSERT INTO `datatable__store_16960546_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:42', '2016-10-25 21:54:42', '2062-08-28 21:54:42', '2016-10-25 21:54:42', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:42', '2016-10-25 21:54:42', '0000-00-00 00:00:00', '2062-08-28 21:54:42', '2016-10-25 21:54:42', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960548_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960548_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960548_data`
--

INSERT INTO `datatable__store_16960548_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 60, 60, 0, 60, 60, 0, 0, 0, '0', '60', '60', 'N', '0', '60', '60', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960548_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960548_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960548_data__age`
--

INSERT INTO `datatable__store_16960548_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:39', '2016-10-29 21:54:39', '2062-08-28 21:54:39', '2016-10-29 21:54:39', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:39', '2016-10-29 21:54:39', '0000-00-00 00:00:00', '2062-08-28 21:54:39', '2016-10-29 21:54:39', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960553_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960553_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960553_data`
--

INSERT INTO `datatable__store_16960553_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 30, 30, 0, 30, 30, 0, 0, 0, '0', '30', '30', 'N', '0', '30', '30', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960553_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960553_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960553_data__age`
--

INSERT INTO `datatable__store_16960553_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:41', '2016-10-28 21:54:41', '2062-08-28 21:54:41', '2016-10-28 21:54:41', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:41', '2016-10-28 21:54:41', '0000-00-00 00:00:00', '2062-08-28 21:54:41', '2016-10-28 21:54:41', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960555_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960555_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960555_data`
--

INSERT INTO `datatable__store_16960555_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 20.76, 20.76, 0, 20.76, 20.76, 0, 0, 0, '0', '20', '20', 'N', '0', '20', '20', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960555_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960555_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960555_data__age`
--

INSERT INTO `datatable__store_16960555_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:44', '2016-10-25 21:54:44', '2062-08-28 21:54:44', '2016-10-25 21:54:44', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:44', '2016-10-25 21:54:44', '0000-00-00 00:00:00', '2062-08-28 21:54:44', '2016-10-25 21:54:44', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960557_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960557_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960557_data`
--

INSERT INTO `datatable__store_16960557_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 60.1, 60.1, 0, 60.1, 60.1, 0, 0, 0, '0', '60', '60', 'N', '0', '60', '60', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960557_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960557_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960557_data__age`
--

INSERT INTO `datatable__store_16960557_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:45', '2016-10-25 21:54:45', '2062-08-28 21:54:45', '2016-10-25 21:54:45', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:45', '2016-10-25 21:54:45', '0000-00-00 00:00:00', '2062-08-28 21:54:45', '2016-10-25 21:54:45', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960559_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960559_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960559_data`
--

INSERT INTO `datatable__store_16960559_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 58.26, 58.26, 0, 58.26, 58.26, 0, 0, 0, '0', '58', '58', 'N', '0', '58', '58', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960559_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960559_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960559_data__age`
--

INSERT INTO `datatable__store_16960559_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:46', '2016-10-25 21:54:46', '2062-08-28 21:54:46', '2016-10-25 21:54:46', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:46', '2016-10-25 21:54:46', '0000-00-00 00:00:00', '2062-08-28 21:54:46', '2016-10-25 21:54:46', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960561_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960561_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960561_data`
--

INSERT INTO `datatable__store_16960561_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 51.4, 51.4, 0, 51.4, 51.4, 0, 0, 0, '0', '52', '52', 'N', '0', '52', '52', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960561_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960561_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960561_data__age`
--

INSERT INTO `datatable__store_16960561_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:47', '2016-10-25 21:54:47', '2062-08-28 21:54:47', '2016-10-25 21:54:47', '2016-09-12 15:42:06', '2017-06-15 15:42:06', '2062-08-28 21:54:47', '2016-10-25 21:54:47', '0000-00-00 00:00:00', '2062-08-28 21:54:47', '2016-10-25 21:54:47', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960563_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960563_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960563_data`
--

INSERT INTO `datatable__store_16960563_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 1039.84, 1039.84, 0, 1039.84, 1039.84, 0, 0, 0, '0', '1040', '1040', 'N', '0', '1040', '1040', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960563_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960563_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960563_data__age`
--

INSERT INTO `datatable__store_16960563_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:49', '2016-10-18 21:54:49', '2062-08-28 21:54:49', '2016-10-18 21:54:49', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:49', '2016-10-18 21:54:49', '0000-00-00 00:00:00', '2062-08-28 21:54:49', '2016-10-18 21:54:49', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960565_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960565_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960565_data`
--

INSERT INTO `datatable__store_16960565_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 24, 24, 0, 24, 24, 0, 0, 0, '0', '24', '24', 'N', '0', '24', '24', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960565_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960565_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960565_data__age`
--

INSERT INTO `datatable__store_16960565_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:50', '2016-10-15 21:54:50', '2062-08-28 21:54:50', '2016-10-15 21:54:50', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:50', '2016-10-15 21:54:50', '0000-00-00 00:00:00', '2062-08-28 21:54:50', '2016-10-15 21:54:50', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960567_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960567_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960567_data`
--

INSERT INTO `datatable__store_16960567_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 60.88, 60.88, 0, 60.88, 60.88, 0, 0, 0, '0', '60', '60', 'N', '0', '60', '60', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960567_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960567_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960567_data__age`
--

INSERT INTO `datatable__store_16960567_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:51', '2016-10-14 21:54:51', '2062-08-28 21:54:51', '2016-10-14 21:54:51', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:51', '2016-10-14 21:54:51', '0000-00-00 00:00:00', '2062-08-28 21:54:51', '2016-10-14 21:54:51', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960569_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960569_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960569_data`
--

INSERT INTO `datatable__store_16960569_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 116.8, 116.8, 0, 116.8, 116.8, 0, 0, 0, '0', '116', '116', 'N', '0', '116', '116', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960569_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960569_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960569_data__age`
--

INSERT INTO `datatable__store_16960569_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:53', '2016-10-12 21:54:53', '2062-08-28 21:54:53', '2016-10-12 21:54:53', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:53', '2016-10-12 21:54:53', '0000-00-00 00:00:00', '2062-08-28 21:54:53', '2016-10-12 21:54:53', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960571_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960571_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960571_data`
--

INSERT INTO `datatable__store_16960571_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 20.4, 20.4, 0, 20.4, 20.4, 0, 0, 0, '0', '20', '20', 'N', '0', '20', '20', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960571_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960571_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960571_data__age`
--

INSERT INTO `datatable__store_16960571_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:54', '2016-10-11 21:54:54', '2062-08-28 21:54:54', '2016-10-11 21:54:54', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:54', '2016-10-11 21:54:54', '0000-00-00 00:00:00', '2062-08-28 21:54:54', '2016-10-11 21:54:54', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960573_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960573_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960573_data`
--

INSERT INTO `datatable__store_16960573_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 102.62, 102.62, 0, 102.62, 102.62, 0, 0, 0, '0', '102', '102', 'N', '0', '102', '102', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960573_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960573_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960573_data__age`
--

INSERT INTO `datatable__store_16960573_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:56', '2016-10-07 21:54:56', '2062-08-28 21:54:56', '2016-10-07 21:54:56', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:56', '2016-10-07 21:54:56', '0000-00-00 00:00:00', '2062-08-28 21:54:56', '2016-10-07 21:54:56', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960575_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960575_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960575_data`
--

INSERT INTO `datatable__store_16960575_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 114.72, 114.72, 0, 114.72, 114.72, 0, 0, 0, '0', '114', '114', 'N', '0', '114', '114', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960575_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960575_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960575_data__age`
--

INSERT INTO `datatable__store_16960575_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:57', '2016-10-08 21:54:57', '2062-08-28 21:54:57', '2016-10-08 21:54:57', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:57', '2016-10-08 21:54:57', '0000-00-00 00:00:00', '2062-08-28 21:54:57', '2016-10-08 21:54:57', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960577_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960577_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960577_data`
--

INSERT INTO `datatable__store_16960577_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 70, 70, 0, 70, 70, 0, 0, 0, '0', '70', '70', 'N', '0', '70', '70', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960577_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960577_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960577_data__age`
--

INSERT INTO `datatable__store_16960577_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:58', '2016-10-08 21:54:58', '2062-08-28 21:54:58', '2016-10-08 21:54:58', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:58', '2016-10-08 21:54:58', '0000-00-00 00:00:00', '2062-08-28 21:54:58', '2016-10-08 21:54:58', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960579_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960579_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960579_data`
--

INSERT INTO `datatable__store_16960579_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 85.18, 85.18, 0, 85.18, 85.18, 0, 0, 0, '0', '86', '86', 'N', '0', '86', '86', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960579_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960579_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960579_data__age`
--

INSERT INTO `datatable__store_16960579_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:54:59', '2016-10-08 21:54:59', '2062-08-28 21:54:59', '2016-10-08 21:54:59', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:54:59', '2016-10-08 21:54:59', '0000-00-00 00:00:00', '2062-08-28 21:54:59', '2016-10-08 21:54:59', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960583_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960583_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960583_data`
--

INSERT INTO `datatable__store_16960583_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 50.84, 50.84, 0, 50.84, 50.84, 0, 0, 0, '0', '50', '50', 'N', '0', '50', '50', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960583_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960583_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960583_data__age`
--

INSERT INTO `datatable__store_16960583_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:01', '2016-10-07 21:55:01', '2062-08-28 21:55:01', '2016-10-07 21:55:01', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:55:01', '2016-10-07 21:55:01', '0000-00-00 00:00:00', '2062-08-28 21:55:01', '2016-10-07 21:55:01', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960585_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960585_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960585_data`
--

INSERT INTO `datatable__store_16960585_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 73.8, 73.8, 0, 73.8, 73.8, 0, 0, 0, '0', '74', '74', 'N', '0', '74', '74', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960585_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960585_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960585_data__age`
--

INSERT INTO `datatable__store_16960585_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:02', '2016-10-07 21:55:02', '2062-08-28 21:55:02', '2016-10-07 21:55:02', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:55:02', '2016-10-07 21:55:02', '0000-00-00 00:00:00', '2062-08-28 21:55:02', '2016-10-07 21:55:02', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960587_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960587_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960587_data`
--

INSERT INTO `datatable__store_16960587_data` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_store_spending_lifetime`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_chain_spending_lifetime`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_direct_competitors_spending_lifetime`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 9, 9, 0, 9, 9, 0, 0, 0, '0', '10', '10', 'N', '0', '10', '10', 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_16960587_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_16960587_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__store_16960587_data__age`
--

INSERT INTO `datatable__store_16960587_data__age` (`user_id`, `my_store_spending_last90days`, `my_store_spending_last12months`, `my_chain_spending_last90days`, `my_chain_spending_last12months`, `my_direct_competitors_spending_last90days`, `my_direct_competitors_spending_last12months`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:03', '2016-10-07 21:55:03', '2062-08-28 21:55:03', '2016-10-07 21:55:03', '2016-09-12 15:42:07', '2017-06-15 15:42:07', '2062-08-28 21:55:03', '2016-10-07 21:55:03', '0000-00-00 00:00:00', '2062-08-28 21:55:03', '2016-10-07 21:55:03', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_CACHE_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_CACHE_data` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` float NOT NULL,
  `my_store_spending_last12months` float NOT NULL,
  `my_store_spending_lifetime` float NOT NULL,
  `my_chain_spending_last90days` float NOT NULL,
  `my_chain_spending_last12months` float NOT NULL,
  `my_chain_spending_lifetime` float NOT NULL,
  `my_direct_competitors_spending_last90days` float NOT NULL,
  `my_direct_competitors_spending_last12months` float NOT NULL,
  `my_direct_competitors_spending_lifetime` float NOT NULL,
  `my_category_spending_last90days` decimal(10,0) NOT NULL,
  `my_category_spending_last12months` decimal(10,0) NOT NULL,
  `my_category_spending_lifetime` decimal(10,0) NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` decimal(10,0) NOT NULL,
  `related_categories_spending_last12months` decimal(10,0) NOT NULL,
  `related_categories_spending_lifetime` decimal(10,0) NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_CACHE_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__store_CACHE_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_store_spending_last90days` datetime NOT NULL,
  `my_store_spending_last12months` datetime NOT NULL,
  `my_chain_spending_last90days` datetime NOT NULL,
  `my_chain_spending_last12months` datetime NOT NULL,
  `my_direct_competitors_spending_last90days` datetime NOT NULL,
  `my_direct_competitors_spending_last12months` datetime NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__store_chain_CACHE_data`
--

CREATE TABLE IF NOT EXISTS `datatable__store_chain_CACHE_data` (
  `id` bigint(20) NOT NULL,
  `chain_id` bigint(20) NOT NULL,
  `other_store_id` bigint(20) NOT NULL,
  `match_store_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_6_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_6_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_6_data`
--

INSERT INTO `datatable__subcategory_6_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 35, 35, 'N', 0, 35, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_6_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_6_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_6_data__age`
--

INSERT INTO `datatable__subcategory_6_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:38', '2016-10-08 21:55:38', '0000-00-00 00:00:00', '2016-09-12 15:42:18', '2016-10-08 15:42:18', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_93_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_93_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_93_data`
--

INSERT INTO `datatable__subcategory_93_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 519.92, 519.92, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_93_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_93_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_93_data__age`
--

INSERT INTO `datatable__subcategory_93_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:32', '2016-10-18 21:55:32', '0000-00-00 00:00:00', '2016-09-12 15:42:21', '2016-10-07 15:42:21', '2016-09-11 15:42:21');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_108_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_108_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_108_data`
--

INSERT INTO `datatable__subcategory_108_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 519.92, 519.92, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_108_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_108_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_108_data__age`
--

INSERT INTO `datatable__subcategory_108_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:33', '2016-10-18 21:55:33', '0000-00-00 00:00:00', '2016-09-12 15:42:10', '2016-10-07 15:42:10', '2016-09-11 15:42:10');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_112_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_112_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_112_data`
--

INSERT INTO `datatable__subcategory_112_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 258.32, 258.32, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_112_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_112_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_112_data__age`
--

INSERT INTO `datatable__subcategory_112_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:12', '2016-10-14 21:55:12', '0000-00-00 00:00:00', '2016-09-12 15:42:10', '2016-10-07 15:42:10', '2016-09-11 15:42:10');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_119_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_119_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_119_data`
--

INSERT INTO `datatable__subcategory_119_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 258.32, 258.32, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_119_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_119_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_119_data__age`
--

INSERT INTO `datatable__subcategory_119_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:12', '2016-10-14 21:55:12', '0000-00-00 00:00:00', '2016-09-12 15:42:11', '2016-10-07 15:42:11', '2016-09-11 15:42:11');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_125_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_125_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_125_data`
--

INSERT INTO `datatable__subcategory_125_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 45.5, 45.5, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_125_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_125_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_125_data__age`
--

INSERT INTO `datatable__subcategory_125_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:13', '2016-10-07 21:55:13', '0000-00-00 00:00:00', '2016-09-12 15:42:12', '2016-10-07 15:42:12', '2016-09-11 15:42:12');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_126_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_126_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_126_data`
--

INSERT INTO `datatable__subcategory_126_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 45.5, 45.5, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_126_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_126_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_126_data__age`
--

INSERT INTO `datatable__subcategory_126_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:14', '2016-10-07 21:55:14', '0000-00-00 00:00:00', '2016-09-12 15:42:12', '2016-10-07 15:42:12', '2016-09-11 15:42:12');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_127_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_127_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_127_data`
--

INSERT INTO `datatable__subcategory_127_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 45.5, 45.5, 'Y', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_127_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_127_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_127_data__age`
--

INSERT INTO `datatable__subcategory_127_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:14', '2016-10-07 21:55:14', '2016-09-11 15:42:12', '2016-09-12 15:42:12', '2016-10-07 15:42:12', '2016-09-11 15:42:12');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_128_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_128_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_128_data`
--

INSERT INTO `datatable__subcategory_128_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 45.5, 45.5, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_128_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_128_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_128_data__age`
--

INSERT INTO `datatable__subcategory_128_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:14', '2016-10-07 21:55:14', '0000-00-00 00:00:00', '2016-09-12 15:42:13', '2016-10-07 15:42:13', '2016-09-11 15:42:13');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_129_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_129_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_129_data`
--

INSERT INTO `datatable__subcategory_129_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 258.32, 258.32, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_129_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_129_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_129_data__age`
--

INSERT INTO `datatable__subcategory_129_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:13', '2016-10-14 21:55:13', '0000-00-00 00:00:00', '2016-09-12 15:42:13', '2016-10-07 15:42:13', '2016-09-11 15:42:13');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_135_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_135_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_135_data`
--

INSERT INTO `datatable__subcategory_135_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 258.32, 258.32, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_135_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_135_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_135_data__age`
--

INSERT INTO `datatable__subcategory_135_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:13', '2016-10-14 21:55:13', '0000-00-00 00:00:00', '2016-09-12 15:42:13', '2016-10-07 15:42:13', '2016-09-11 15:42:13');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_147_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_147_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_147_data`
--

INSERT INTO `datatable__subcategory_147_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 519.92, 519.92, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_147_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_147_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_147_data__age`
--

INSERT INTO `datatable__subcategory_147_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:34', '2016-10-18 21:55:34', '0000-00-00 00:00:00', '2016-09-12 15:42:13', '2016-10-07 15:42:13', '2016-09-11 15:42:13');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_148_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_148_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_148_data`
--

INSERT INTO `datatable__subcategory_148_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 258.32, 258.32, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_148_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_148_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_148_data__age`
--

INSERT INTO `datatable__subcategory_148_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:13', '2016-10-14 21:55:13', '0000-00-00 00:00:00', '2016-09-12 15:42:14', '2016-10-07 15:42:14', '2016-09-11 15:42:14');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_160_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_160_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_160_data`
--

INSERT INTO `datatable__subcategory_160_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 519.92, 519.92, 'N', 0, 671.83, 0, 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_160_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_160_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_160_data__age`
--

INSERT INTO `datatable__subcategory_160_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:35', '2016-10-18 21:55:35', '0000-00-00 00:00:00', '2016-09-12 15:42:14', '2016-10-07 15:42:14', '2016-09-11 15:42:14');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_210_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_210_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_210_data`
--

INSERT INTO `datatable__subcategory_210_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 35, 35, 'N', 0, 35, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_210_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_210_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_210_data__age`
--

INSERT INTO `datatable__subcategory_210_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:39', '2016-10-08 21:55:39', '0000-00-00 00:00:00', '2016-09-12 15:42:16', '2016-10-08 15:42:16', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_450_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_450_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_450_data`
--

INSERT INTO `datatable__subcategory_450_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 216.22, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_450_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_450_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_450_data__age`
--

INSERT INTO `datatable__subcategory_450_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:09', '2016-10-14 21:55:09', '0000-00-00 00:00:00', '2016-09-12 15:42:17', '2016-10-14 15:42:17', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_918_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_918_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_918_data`
--

INSERT INTO `datatable__subcategory_918_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 140.72, 140.72, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_918_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_918_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_918_data__age`
--

INSERT INTO `datatable__subcategory_918_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:14', '2016-10-08 21:55:14', '0000-00-00 00:00:00', '2016-09-12 15:42:19', '2016-10-07 15:42:19', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_921_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_921_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_921_data`
--

INSERT INTO `datatable__subcategory_921_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 5.98, 5.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_921_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_921_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_921_data__age`
--

INSERT INTO `datatable__subcategory_921_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:15', '2016-11-10 21:55:15', '0000-00-00 00:00:00', '2016-09-12 15:42:19', '2016-10-07 15:42:19', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_924_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_924_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_924_data`
--

INSERT INTO `datatable__subcategory_924_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 15.5, 15.5, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_924_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_924_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_924_data__age`
--

INSERT INTO `datatable__subcategory_924_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:16', '2016-11-08 21:55:16', '0000-00-00 00:00:00', '2016-09-12 15:42:19', '2016-10-07 15:42:19', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_925_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_925_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_925_data`
--

INSERT INTO `datatable__subcategory_925_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 26.98, 26.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_925_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_925_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_925_data__age`
--

INSERT INTO `datatable__subcategory_925_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:08', '2016-11-16 21:55:08', '0000-00-00 00:00:00', '2016-09-12 15:42:20', '2016-10-07 15:42:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_926_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_926_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_926_data`
--

INSERT INTO `datatable__subcategory_926_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.98, 7.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_926_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_926_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_926_data__age`
--

INSERT INTO `datatable__subcategory_926_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:18', '2016-11-08 21:55:18', '0000-00-00 00:00:00', '2016-09-12 15:42:20', '2016-10-07 15:42:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_927_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_927_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_927_data`
--

INSERT INTO `datatable__subcategory_927_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 25.7, 25.7, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_927_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_927_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_927_data__age`
--

INSERT INTO `datatable__subcategory_927_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:31', '2016-10-25 21:55:31', '0000-00-00 00:00:00', '2016-09-12 15:42:20', '2016-10-07 15:42:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_930_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_930_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_930_data`
--

INSERT INTO `datatable__subcategory_930_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_930_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_930_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_930_data__age`
--

INSERT INTO `datatable__subcategory_930_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:09', '2016-10-14 21:55:09', '0000-00-00 00:00:00', '2016-09-12 15:42:20', '2016-10-07 15:42:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_931_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_931_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_931_data`
--

INSERT INTO `datatable__subcategory_931_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 25.42, 25.42, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_931_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_931_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_931_data__age`
--

INSERT INTO `datatable__subcategory_931_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:42', '2016-10-07 21:55:42', '0000-00-00 00:00:00', '2016-09-12 15:42:20', '2016-10-07 15:42:20', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_933_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_933_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_933_data`
--

INSERT INTO `datatable__subcategory_933_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 25.7, 25.7, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_933_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_933_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_933_data__age`
--

INSERT INTO `datatable__subcategory_933_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:31', '2016-10-25 21:55:31', '0000-00-00 00:00:00', '2016-09-12 15:42:21', '2016-10-07 15:42:21', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_934_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_934_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_934_data`
--

INSERT INTO `datatable__subcategory_934_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_934_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_934_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_934_data__age`
--

INSERT INTO `datatable__subcategory_934_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:09', '2016-10-14 21:55:09', '0000-00-00 00:00:00', '2016-09-12 15:42:21', '2016-10-07 15:42:21', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_936_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_936_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_936_data`
--

INSERT INTO `datatable__subcategory_936_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 5.98, 5.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_936_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_936_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_936_data__age`
--

INSERT INTO `datatable__subcategory_936_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:15', '2016-11-10 21:55:15', '0000-00-00 00:00:00', '2016-09-12 15:42:21', '2016-10-07 15:42:21', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_940_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_940_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_940_data`
--

INSERT INTO `datatable__subcategory_940_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_940_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_940_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_940_data__age`
--

INSERT INTO `datatable__subcategory_940_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:10', '2016-10-14 21:55:10', '0000-00-00 00:00:00', '2016-09-12 15:42:21', '2016-10-07 15:42:21', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_943_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_943_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_943_data`
--

INSERT INTO `datatable__subcategory_943_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 57.43, 57.43, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_943_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_943_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_943_data__age`
--

INSERT INTO `datatable__subcategory_943_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:21', '2016-10-11 21:55:21', '0000-00-00 00:00:00', '2016-09-12 15:42:22', '2016-10-07 15:42:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_947_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_947_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_947_data`
--

INSERT INTO `datatable__subcategory_947_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 115.76, 115.76, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_947_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_947_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_947_data__age`
--

INSERT INTO `datatable__subcategory_947_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:36', '2016-10-08 21:55:36', '0000-00-00 00:00:00', '2016-09-12 15:42:22', '2016-10-07 15:42:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_955_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_955_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_955_data`
--

INSERT INTO `datatable__subcategory_955_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_955_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_955_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_955_data__age`
--

INSERT INTO `datatable__subcategory_955_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:10', '2016-10-14 21:55:10', '0000-00-00 00:00:00', '2016-09-12 15:42:22', '2016-10-07 15:42:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_960_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_960_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_960_data`
--

INSERT INTO `datatable__subcategory_960_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.98, 7.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_960_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_960_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_960_data__age`
--

INSERT INTO `datatable__subcategory_960_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:19', '2016-11-08 21:55:19', '0000-00-00 00:00:00', '2016-09-12 15:42:22', '2016-10-07 15:42:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_963_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_963_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_963_data`
--

INSERT INTO `datatable__subcategory_963_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_963_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_963_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_963_data__age`
--

INSERT INTO `datatable__subcategory_963_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:10', '2016-10-14 21:55:10', '0000-00-00 00:00:00', '2016-09-12 15:42:22', '2016-10-07 15:42:22', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_965_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_965_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_965_data`
--

INSERT INTO `datatable__subcategory_965_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 115.76, 115.76, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_965_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_965_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_965_data__age`
--

INSERT INTO `datatable__subcategory_965_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:37', '2016-10-08 21:55:37', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_971_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_971_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_971_data`
--

INSERT INTO `datatable__subcategory_971_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 38.79, 38.79, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_971_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_971_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_971_data__age`
--

INSERT INTO `datatable__subcategory_971_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:28', '2016-11-03 21:55:28', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_972_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_972_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_972_data`
--

INSERT INTO `datatable__subcategory_972_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 38.79, 38.79, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_972_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_972_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_972_data__age`
--

INSERT INTO `datatable__subcategory_972_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:29', '2016-11-03 21:55:29', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_975_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_975_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_975_data`
--

INSERT INTO `datatable__subcategory_975_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_975_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_975_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_975_data__age`
--

INSERT INTO `datatable__subcategory_975_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:10', '2016-10-14 21:55:10', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_977_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_977_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_977_data`
--

INSERT INTO `datatable__subcategory_977_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 26.98, 26.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_977_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_977_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_977_data__age`
--

INSERT INTO `datatable__subcategory_977_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:08', '2016-11-16 21:55:08', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_978_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_978_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_978_data`
--

INSERT INTO `datatable__subcategory_978_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_978_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_978_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_978_data__age`
--

INSERT INTO `datatable__subcategory_978_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:11', '2016-10-14 21:55:11', '0000-00-00 00:00:00', '2016-09-12 15:42:23', '2016-10-07 15:42:23', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_989_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_989_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_989_data`
--

INSERT INTO `datatable__subcategory_989_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 38.79, 38.79, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_989_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_989_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_989_data__age`
--

INSERT INTO `datatable__subcategory_989_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:30', '2016-11-03 21:55:30', '0000-00-00 00:00:00', '2016-09-12 15:42:24', '2016-10-07 15:42:24', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_993_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_993_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_993_data`
--

INSERT INTO `datatable__subcategory_993_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.75, 15.5, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_993_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_993_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_993_data__age`
--

INSERT INTO `datatable__subcategory_993_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:16', '2016-11-08 21:55:16', '0000-00-00 00:00:00', '2016-09-12 15:42:24', '2016-10-07 15:42:24', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_995_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_995_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_995_data`
--

INSERT INTO `datatable__subcategory_995_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_995_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_995_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_995_data__age`
--

INSERT INTO `datatable__subcategory_995_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:11', '2016-10-14 21:55:11', '0000-00-00 00:00:00', '2016-09-12 15:42:24', '2016-10-07 15:42:24', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_996_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_996_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_996_data`
--

INSERT INTO `datatable__subcategory_996_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_996_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_996_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_996_data__age`
--

INSERT INTO `datatable__subcategory_996_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:11', '2016-10-14 21:55:11', '0000-00-00 00:00:00', '2016-09-12 15:42:24', '2016-10-07 15:42:24', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1009_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1009_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1009_data`
--

INSERT INTO `datatable__subcategory_1009_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.75, 7.75, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1009_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1009_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1009_data__age`
--

INSERT INTO `datatable__subcategory_1009_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:17', '2016-11-08 21:55:17', '0000-00-00 00:00:00', '2016-09-12 15:42:09', '2016-10-07 15:42:09', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1011_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1011_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1011_data`
--

INSERT INTO `datatable__subcategory_1011_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 432.44, 432.44, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1011_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1011_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1011_data__age`
--

INSERT INTO `datatable__subcategory_1011_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:12', '2016-10-14 21:55:12', '0000-00-00 00:00:00', '2016-09-12 15:42:09', '2016-10-07 15:42:09', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1012_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1012_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1012_data`
--

INSERT INTO `datatable__subcategory_1012_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 26.98, 26.98, 'N', 0, 581.89, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1012_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1012_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1012_data__age`
--

INSERT INTO `datatable__subcategory_1012_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:09', '2016-11-16 21:55:09', '0000-00-00 00:00:00', '2016-09-12 15:42:09', '2016-10-07 15:42:09', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1064_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1064_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1064_data`
--

INSERT INTO `datatable__subcategory_1064_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1064_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1064_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1064_data__age`
--

INSERT INTO `datatable__subcategory_1064_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:23', '2016-11-08 21:55:23', '0000-00-00 00:00:00', '2016-09-12 15:42:09', '2016-11-08 15:42:09', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1065_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1065_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1065_data`
--

INSERT INTO `datatable__subcategory_1065_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1065_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1065_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1065_data__age`
--

INSERT INTO `datatable__subcategory_1065_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:24', '2016-11-08 21:55:24', '0000-00-00 00:00:00', '2016-09-12 15:42:10', '2016-11-08 15:42:10', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1144_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1144_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1144_data`
--

INSERT INTO `datatable__subcategory_1144_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1144_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1144_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1144_data__age`
--

INSERT INTO `datatable__subcategory_1144_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:25', '2016-11-08 21:55:25', '0000-00-00 00:00:00', '2016-09-12 15:42:11', '2016-11-08 15:42:11', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1179_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1179_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1179_data`
--

INSERT INTO `datatable__subcategory_1179_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1179_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1179_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1179_data__age`
--

INSERT INTO `datatable__subcategory_1179_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:25', '2016-11-08 21:55:25', '0000-00-00 00:00:00', '2016-09-12 15:42:11', '2016-11-08 15:42:11', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1180_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1180_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1180_data`
--

INSERT INTO `datatable__subcategory_1180_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1180_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1180_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1180_data__age`
--

INSERT INTO `datatable__subcategory_1180_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:26', '2016-11-08 21:55:26', '0000-00-00 00:00:00', '2016-09-12 15:42:11', '2016-11-08 15:42:11', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1192_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1192_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1192_data`
--

INSERT INTO `datatable__subcategory_1192_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 6.06, 6.06, 'N', 0, 6.06, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1192_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1192_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1192_data__age`
--

INSERT INTO `datatable__subcategory_1192_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:27', '2016-11-08 21:55:27', '0000-00-00 00:00:00', '2016-09-12 15:42:11', '2016-11-08 15:42:11', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1927_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1927_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1927_data`
--

INSERT INTO `datatable__subcategory_1927_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.98, 7.98, 'N', 0, 42.98, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1927_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1927_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1927_data__age`
--

INSERT INTO `datatable__subcategory_1927_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:19', '2016-11-08 21:55:19', '0000-00-00 00:00:00', '2016-09-12 15:42:14', '2016-10-08 15:42:14', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1928_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1928_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1928_data`
--

INSERT INTO `datatable__subcategory_1928_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 7.98, 7.98, 'N', 0, 42.98, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1928_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1928_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1928_data__age`
--

INSERT INTO `datatable__subcategory_1928_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:20', '2016-11-08 21:55:20', '0000-00-00 00:00:00', '2016-09-12 15:42:14', '2016-10-08 15:42:14', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1949_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1949_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1949_data`
--

INSERT INTO `datatable__subcategory_1949_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 35, 35, 'N', 0, 42.98, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1949_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1949_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1949_data__age`
--

INSERT INTO `datatable__subcategory_1949_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:40', '2016-10-08 21:55:40', '0000-00-00 00:00:00', '2016-09-12 15:42:15', '2016-10-08 15:42:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1965_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1965_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1965_data`
--

INSERT INTO `datatable__subcategory_1965_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 35, 35, 'N', 0, 42.98, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_1965_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_1965_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_1965_data__age`
--

INSERT INTO `datatable__subcategory_1965_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:41', '2016-10-08 21:55:41', '0000-00-00 00:00:00', '2016-09-12 15:42:15', '2016-10-08 15:42:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2032_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2032_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2032_data`
--

INSERT INTO `datatable__subcategory_2032_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 4, 4, 'N', 0, 38.9, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2032_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2032_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2032_data__age`
--

INSERT INTO `datatable__subcategory_2032_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:16', '2016-11-08 21:55:16', '0000-00-00 00:00:00', '2016-09-12 15:42:15', '2016-10-07 15:42:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2072_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2072_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2072_data`
--

INSERT INTO `datatable__subcategory_2072_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 36.9, 36.9, 'N', 0, 38.9, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2072_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2072_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2072_data__age`
--

INSERT INTO `datatable__subcategory_2072_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:43', '2016-10-07 21:55:43', '0000-00-00 00:00:00', '2016-09-12 15:42:15', '2016-10-07 15:42:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2096_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2096_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2096_data`
--

INSERT INTO `datatable__subcategory_2096_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 59.12, 59.12, 'N', 0, 549.48, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2096_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2096_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2096_data__age`
--

INSERT INTO `datatable__subcategory_2096_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:15', '2016-11-10 21:55:15', '0000-00-00 00:00:00', '2016-09-12 15:42:15', '2016-10-18 15:42:15', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2155_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2155_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2155_data`
--

INSERT INTO `datatable__subcategory_2155_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 519.92, 519.92, 'N', 0, 549.48, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2155_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2155_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2155_data__age`
--

INSERT INTO `datatable__subcategory_2155_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:36', '2016-10-18 21:55:36', '0000-00-00 00:00:00', '2016-09-12 15:42:16', '2016-10-18 15:42:16', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2165_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2165_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2165_data`
--

INSERT INTO `datatable__subcategory_2165_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 59.12, 59.12, 'N', 0, 549.48, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2165_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2165_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2165_data__age`
--

INSERT INTO `datatable__subcategory_2165_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:15', '2016-11-10 21:55:15', '0000-00-00 00:00:00', '2016-09-12 15:42:17', '2016-10-18 15:42:17', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2166_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2166_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2166_data`
--

INSERT INTO `datatable__subcategory_2166_data` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `my_category_spending_lifetime`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `related_categories_spending_lifetime`, `did_related_categories_survey_last90days`, `is_processed`) VALUES
(12, 0, 16.5, 16.5, 'N', 0, 16.5, 0, 'N', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_2166_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_2166_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__subcategory_2166_data__age`
--

INSERT INTO `datatable__subcategory_2166_data__age` (`user_id`, `my_category_spending_last90days`, `my_category_spending_last12months`, `did_my_category_survey_last90days`, `related_categories_spending_last90days`, `related_categories_spending_last12months`, `did_related_categories_survey_last90days`) VALUES
(12, '2062-08-28 21:55:22', '2016-11-08 21:55:22', '0000-00-00 00:00:00', '2016-09-12 15:42:17', '2016-11-08 15:42:17', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_CACHE_data`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_CACHE_data` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` float NOT NULL,
  `my_category_spending_last12months` float NOT NULL,
  `my_category_spending_lifetime` float NOT NULL,
  `did_my_category_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `related_categories_spending_last90days` float NOT NULL,
  `related_categories_spending_last12months` float NOT NULL,
  `related_categories_spending_lifetime` float NOT NULL,
  `did_related_categories_survey_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__subcategory_CACHE_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__subcategory_CACHE_data__age` (
  `user_id` bigint(20) NOT NULL,
  `my_category_spending_last90days` datetime NOT NULL,
  `my_category_spending_last12months` datetime NOT NULL,
  `did_my_category_survey_last90days` datetime NOT NULL,
  `related_categories_spending_last90days` datetime NOT NULL,
  `related_categories_spending_last12months` datetime NOT NULL,
  `did_related_categories_survey_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__system_stats`
--

CREATE TABLE IF NOT EXISTS `datatable__system_stats` (
  `id` bigint(20) NOT NULL,
  `statistic_code` varchar(300) NOT NULL,
  `code_value` varchar(500) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__system_stats`
--

INSERT INTO `datatable__system_stats` (`id`, `statistic_code`, `code_value`) VALUES
(1, 'number_of_users', '34');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__user_data`
--

CREATE TABLE IF NOT EXISTS `datatable__user_data` (
  `user_id` bigint(20) NOT NULL,
  `number_of_surveys_answered_in_last90days` int(11) NOT NULL,
  `number_of_direct_referrals_last180days` int(11) NOT NULL,
  `number_of_direct_referrals_last360days` int(11) NOT NULL,
  `total_direct_referrals` int(11) NOT NULL,
  `number_of_network_referrals_last180days` int(11) NOT NULL,
  `number_of_network_referrals_last360days` int(11) NOT NULL,
  `total_network_referrals` int(11) NOT NULL,
  `spending_of_direct_referrals_last180days` int(11) NOT NULL,
  `spending_of_direct_referrals_last360days` int(11) NOT NULL,
  `total_spending_of_direct_referrals` decimal(10,0) NOT NULL,
  `spending_of_network_referrals_last180days` decimal(10,0) NOT NULL,
  `spending_of_network_referrals_last360days` decimal(10,0) NOT NULL,
  `total_spending_of_network_referrals` decimal(10,0) NOT NULL,
  `spending_last180days` decimal(10,0) NOT NULL,
  `spending_last360days` decimal(10,0) NOT NULL,
  `spending_total` decimal(10,0) NOT NULL,
  `ad_spending_last180days` decimal(10,0) NOT NULL,
  `ad_spending_last360days` decimal(10,0) NOT NULL,
  `ad_spending_total` decimal(10,0) NOT NULL,
  `commissions_level_1` decimal(10,0) NOT NULL,
  `commissions_level_2` decimal(10,0) NOT NULL,
  `commissions_level_3` decimal(10,0) NOT NULL,
  `commissions_level_4` decimal(10,0) NOT NULL,
  `total_commissions` decimal(10,0) NOT NULL,
  `total_store_commissions` decimal(10,0) NOT NULL,
  `last_commission_pay_date` datetime NOT NULL,
  `cash_balance_today` decimal(10,0) NOT NULL,
  `average_cash_balance_last24months` decimal(10,0) NOT NULL,
  `credit_balance_today` decimal(10,0) NOT NULL,
  `average_credit_balance_last24months` decimal(10,0) NOT NULL,
  `last_transaction_import_date` datetime NOT NULL,
  `last_referral_join_date` datetime NOT NULL,
  `last_login_date` datetime NOT NULL,
  `total_logins` int(11) NOT NULL,
  `total_checkins` int(11) NOT NULL,
  `total_linked_accounts` int(11) NOT NULL,
  `total_linked_banks` int(11) NOT NULL,
  `total_raw_transactions` int(11) NOT NULL,
  `last_promo_use_date` datetime NOT NULL,
  `total_perks_used` int(11) NOT NULL,
  `total_cashback_used` decimal(10,0) NOT NULL,
  `total_reviews` int(11) NOT NULL,
  `total_store_views` int(11) NOT NULL,
  `total_clicks` int(11) NOT NULL,
  `total_searches` int(11) NOT NULL,
  `total_unique_checkin_locations` int(11) NOT NULL,
  `total_ips` int(11) NOT NULL,
  `last_transaction_date` datetime NOT NULL,
  `total_unmatched_amount` int(11) NOT NULL,
  `total_unmatched_transactions` int(11) NOT NULL,
  `total_matched_amount` decimal(10,0) NOT NULL,
  `total_matched_transactions` int(11) NOT NULL,
  `last_transfer_out_request` decimal(10,0) NOT NULL,
  `available_balance` decimal(10,0) NOT NULL,
  `pending_balance` decimal(10,0) NOT NULL,
  `total_withdrawn` decimal(10,0) NOT NULL,
  `funds_expiring_in_30_days` decimal(10,0) NOT NULL,
  `funds_expired` decimal(10,0) NOT NULL,
  `total_withdraw_fees` decimal(10,0) NOT NULL,
  `total_cashback_fees` decimal(10,0) NOT NULL,
  `pending_transfers_out` int(11) NOT NULL,
  `pending_transfers_in` int(11) NOT NULL,
  `driver_license_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `address_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `facebook_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `linkedin_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `twitter_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `mobile_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `email_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `profile_photo_added` enum('Y','N') NOT NULL DEFAULT 'N',
  `bank_verified_and_active` enum('Y','N') NOT NULL DEFAULT 'N',
  `credit_verified_and_active` enum('Y','N') NOT NULL DEFAULT 'N',
  `location_services_activated` enum('Y','N') NOT NULL DEFAULT 'N',
  `push_notifications_activated` enum('Y','N') NOT NULL DEFAULT 'N',
  `first_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_payment_last7days` enum('Y','N') NOT NULL DEFAULT 'N',
  `first_adrelated_payment_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `member_processed_promo_payment_last7days` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_first_public_checkin_success` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_public_checkin_last7days` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_answered_survey_in_last90days` enum('Y','N') NOT NULL DEFAULT 'N',
  `total_imported_contacts` int(11) NOT NULL,
  `total_store_favorites` int(11) NOT NULL,
  `total_locations` int(11) NOT NULL,
  `total_devices` int(11) NOT NULL,
  `total_open_tickets` int(11) NOT NULL,
  `total_closed_tickets` int(11) NOT NULL,
  `last_ticket_on` datetime NOT NULL,
  `total_financial_alerts` int(11) NOT NULL,
  `date_joined` datetime NOT NULL,
  `user_type` varchar(300) NOT NULL,
  `user_status` enum('pending','active','inactive','deleted') NOT NULL DEFAULT 'pending',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__user_data`
--

INSERT INTO `datatable__user_data` (`user_id`, `number_of_surveys_answered_in_last90days`, `number_of_direct_referrals_last180days`, `number_of_direct_referrals_last360days`, `total_direct_referrals`, `number_of_network_referrals_last180days`, `number_of_network_referrals_last360days`, `total_network_referrals`, `spending_of_direct_referrals_last180days`, `spending_of_direct_referrals_last360days`, `total_spending_of_direct_referrals`, `spending_of_network_referrals_last180days`, `spending_of_network_referrals_last360days`, `total_spending_of_network_referrals`, `spending_last180days`, `spending_last360days`, `spending_total`, `ad_spending_last180days`, `ad_spending_last360days`, `ad_spending_total`, `commissions_level_1`, `commissions_level_2`, `commissions_level_3`, `commissions_level_4`, `total_commissions`, `total_store_commissions`, `last_commission_pay_date`, `cash_balance_today`, `average_cash_balance_last24months`, `credit_balance_today`, `average_credit_balance_last24months`, `last_transaction_import_date`, `last_referral_join_date`, `last_login_date`, `total_logins`, `total_checkins`, `total_linked_accounts`, `total_linked_banks`, `total_raw_transactions`, `last_promo_use_date`, `total_perks_used`, `total_cashback_used`, `total_reviews`, `total_store_views`, `total_clicks`, `total_searches`, `total_unique_checkin_locations`, `total_ips`, `last_transaction_date`, `total_unmatched_amount`, `total_unmatched_transactions`, `total_matched_amount`, `total_matched_transactions`, `last_transfer_out_request`, `available_balance`, `pending_balance`, `total_withdrawn`, `funds_expiring_in_30_days`, `funds_expired`, `total_withdraw_fees`, `total_cashback_fees`, `pending_transfers_out`, `pending_transfers_in`, `driver_license_verified`, `address_verified`, `facebook_connected`, `linkedin_connected`, `twitter_connected`, `mobile_connected`, `email_connected`, `profile_photo_added`, `bank_verified_and_active`, `credit_verified_and_active`, `location_services_activated`, `push_notifications_activated`, `first_payment_success`, `member_processed_payment_last7days`, `first_adrelated_payment_success`, `member_processed_promo_payment_last7days`, `has_first_public_checkin_success`, `has_public_checkin_last7days`, `has_answered_survey_in_last90days`, `total_imported_contacts`, `total_store_favorites`, `total_locations`, `total_devices`, `total_open_tickets`, `total_closed_tickets`, `last_ticket_on`, `total_financial_alerts`, `date_joined`, `user_type`, `user_status`, `is_processed`) VALUES
(1, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2016-07-08 14:59:28', 195, 23, 8, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, '46', 4, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'Y', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 0, 0, 23, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-09-08 10:39:00', '', 'active', 'N'),
(2, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '10', 1, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-07-24 00:00:00', '', 'active', 'N'),
(12, 1, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '1544', '32382', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '3276', '0', '2259', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2016-07-05 15:45:11', 2, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-11-25 15:51:33', '', 'active', 'N'),
(13, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2016-07-06 12:14:24', 32, 3, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 1, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 0, 0, 3, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-11-25 15:55:18', '', 'active', 'N'),
(14, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-11-25 16:01:25', '', 'active', 'N'),
(18, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-16 15:35:44', '', 'active', 'N'),
(21, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-17 15:25:01', '', 'active', 'N'),
(23, 0, 1, 1, 1, 1, 1, 1, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-18 11:14:17', '', 'active', 'N'),
(44, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-02-18 11:11:56', '', 'active', 'N'),
(45, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-03-01 07:22:12', '', 'active', 'N'),
(46, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-09 16:53:49', '', 'pending', 'N'),
(49, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-09 16:56:11', '', 'pending', 'N'),
(50, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-18 22:42:28', 'random_shopper', 'pending', 'N'),
(51, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-18 22:47:03', 'random_shopper', 'pending', 'N'),
(52, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-18 23:27:25', 'random_shopper', 'pending', 'N'),
(53, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-18 23:37:51', 'random_shopper', 'pending', 'N'),
(54, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 2, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-18 23:59:20', 'random_shopper', 'pending', 'N'),
(55, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 02:30:51', 'random_shopper', 'pending', 'N'),
(56, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:05:22', 'random_shopper', 'pending', 'N'),
(57, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:09:30', 'random_shopper', 'pending', 'N'),
(58, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:11:13', 'random_shopper', 'pending', 'N'),
(59, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:14:28', 'random_shopper', 'pending', 'N'),
(60, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:17:23', 'random_shopper', 'pending', 'N'),
(61, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:25:40', 'random_shopper', 'pending', 'N'),
(62, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:28:23', 'random_shopper', 'pending', 'N'),
(63, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:47:11', 'random_shopper', 'pending', 'N'),
(68, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 03:59:23', 'random_shopper', 'pending', 'N'),
(69, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:06:16', 'random_shopper', 'pending', 'N'),
(70, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:15:05', 'random_shopper', 'pending', 'N'),
(71, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:18:10', 'random_shopper', 'pending', 'N'),
(72, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:21:10', 'random_shopper', 'pending', 'N'),
(73, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:24:36', 'random_shopper', 'pending', 'N'),
(74, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:31:36', 'random_shopper', 'pending', 'N'),
(75, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:41:51', 'random_shopper', 'pending', 'N'),
(76, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:47:14', 'random_shopper', 'pending', 'N'),
(77, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-19 04:49:01', 'random_shopper', 'pending', 'N'),
(78, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:41:56', 'random_shopper', 'active', 'N'),
(80, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:46:44', 'random_shopper', 'active', 'N'),
(82, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:47:24', 'random_shopper', 'active', 'N'),
(83, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:50:10', 'random_shopper', 'active', 'N'),
(84, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:52:20', 'random_shopper', 'active', 'N'),
(86, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:52:48', 'random_shopper', 'active', 'N'),
(87, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:53:23', 'random_shopper', 'active', 'N'),
(88, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 02:54:05', '', 'pending', 'N'),
(89, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 04:03:51', 'random_shopper', 'active', 'N'),
(90, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'N', 'N', 'N', 'N', '', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 04:10:14', 'random_shopper', 'pending', 'N'),
(91, 0, 0, 0, 0, 0, 0, 0, 0, 0, '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '0000-00-00 00:00:00', '0', '0', '0', '0', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '0', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, 0, '0', 0, '0', '0', '0', '0', '0', '0', '0', '0', 0, 0, 'N', 'N', 'Y', 'N', 'N', 'N', 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-08-23 04:11:39', 'random_shopper', 'active', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `datatable__user_data__age`
--

CREATE TABLE IF NOT EXISTS `datatable__user_data__age` (
  `user_id` bigint(20) NOT NULL,
  `number_of_surveys_answered_in_last90days` datetime NOT NULL,
  `number_of_direct_referrals_last180days` datetime NOT NULL,
  `number_of_direct_referrals_last360days` datetime NOT NULL,
  `number_of_network_referrals_last180days` datetime NOT NULL,
  `number_of_network_referrals_last360days` datetime NOT NULL,
  `spending_of_direct_referrals_last180days` datetime NOT NULL,
  `spending_of_direct_referrals_last360days` datetime NOT NULL,
  `spending_of_network_referrals_last180days` datetime NOT NULL,
  `spending_of_network_referrals_last360days` datetime NOT NULL,
  `spending_last180days` datetime NOT NULL,
  `spending_last360days` datetime NOT NULL,
  `ad_spending_last180days` datetime NOT NULL,
  `ad_spending_last360days` datetime NOT NULL,
  `average_cash_balance_last24months` datetime NOT NULL,
  `average_credit_balance_last24months` datetime NOT NULL,
  `funds_expiring_in_30_days` datetime NOT NULL,
  `member_processed_payment_last7days` datetime NOT NULL,
  `member_processed_promo_payment_last7days` datetime NOT NULL,
  `has_public_checkin_last7days` datetime NOT NULL,
  `has_answered_survey_in_last90days` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `datatable__user_data__age`
--

INSERT INTO `datatable__user_data__age` (`user_id`, `number_of_surveys_answered_in_last90days`, `number_of_direct_referrals_last180days`, `number_of_direct_referrals_last360days`, `number_of_network_referrals_last180days`, `number_of_network_referrals_last360days`, `spending_of_direct_referrals_last180days`, `spending_of_direct_referrals_last360days`, `spending_of_network_referrals_last180days`, `spending_of_network_referrals_last360days`, `spending_last180days`, `spending_last360days`, `ad_spending_last180days`, `ad_spending_last360days`, `average_cash_balance_last24months`, `average_credit_balance_last24months`, `funds_expiring_in_30_days`, `member_processed_payment_last7days`, `member_processed_promo_payment_last7days`, `has_public_checkin_last7days`, `has_answered_survey_in_last90days`) VALUES
(12, '2016-09-11 15:31:28', '2016-12-10 15:31:28', '2017-06-09 15:31:28', '2016-12-10 15:31:28', '2017-06-09 15:31:28', '2016-12-10 15:31:28', '2017-06-09 15:31:28', '2016-12-10 15:31:28', '2017-06-09 15:31:28', '2016-12-10 15:31:28', '2016-09-23 15:31:28', '2016-12-10 15:31:28', '2017-06-09 15:31:28', '2018-05-11 11:07:52', '2018-05-11 11:07:52', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '2016-09-11 15:31:28');

-- --------------------------------------------------------

--
-- Структура таблицы `data_processing_crons`
--

CREATE TABLE IF NOT EXISTS `data_processing_crons` (
  `id` bigint(20) NOT NULL,
  `last_processed_key` bigint(20) NOT NULL,
  `quota` bigint(20) NOT NULL,
  `success` bigint(20) NOT NULL,
  `failed` bigint(20) NOT NULL,
  `already_exist` bigint(20) NOT NULL,
  `job_name` varchar(300) NOT NULL,
  `service_endpoint` varchar(300) NOT NULL,
  `is_active` enum('Y','N') DEFAULT 'Y',
  `last_processed_date` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `data_processing_crons`
--

INSERT INTO `data_processing_crons` (`id`, `last_processed_key`, `quota`, `success`, `failed`, `already_exist`, `job_name`, `service_endpoint`, `is_active`, `last_processed_date`, `created`) VALUES
(1, 0, 15000000, 0, 0, 0, 'crawlerSiteMapJob', '', 'Y', '2016-04-06 20:07:46', '2016-05-30 20:05:30'),
(4, 0, 150000, 0, 0, 0, 'userIdUpdateJob', '', 'Y', '2016-04-14 19:38:06', '2016-05-30 20:05:30'),
(8, 0, 150000, 0, 0, 0, 'staticMapJob', '', 'Y', '2016-04-19 00:00:00', '2016-05-30 20:05:30'),
(9, 150000, 150000, 0, 0, 126848, 'staticMapJob', '', 'Y', '2016-04-19 00:00:00', '2016-05-30 20:05:30'),
(10, 300000, 150000, 28, 0, 131366, 'staticMapJob', '', 'Y', '2016-04-19 00:00:00', '2016-05-30 20:05:30'),
(11, 450000, 150000, 0, 0, 128898, 'staticMapJob', '', 'Y', '2016-05-30 18:57:06', '2016-05-30 20:05:30'),
(12, 600000, 150000, 0, 0, 124399, 'staticMapJob', '', 'Y', '2016-05-30 19:02:27', '2016-05-30 20:05:30'),
(13, 750000, 150000, 0, 0, 129168, 'staticMapJob', '', 'Y', '2016-05-30 20:13:11', '2016-05-30 20:05:30'),
(14, 900000, 150000, 0, 0, 126743, 'staticMapJob', '', 'Y', '2016-05-30 22:33:57', '2016-05-30 20:05:30'),
(15, 1050000, 150000, 0, 0, 125703, 'staticMapJob', '', 'Y', '2016-06-02 11:02:20', '2016-05-30 20:05:30');

-- --------------------------------------------------------

--
-- Структура таблицы `descriptor_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `descriptor_TEMP_JC` (
  `id` bigint(20) NOT NULL,
  `descriptor` varchar(100) NOT NULL DEFAULT '',
  `address` varchar(250) NOT NULL DEFAULT '',
  `city` varchar(250) NOT NULL DEFAULT '',
  `place_type` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `descriptor_TEMP_JC`
--

INSERT INTO `descriptor_TEMP_JC` (`id`, `descriptor`, `address`, `city`, `place_type`) VALUES
(2, ' deli south', '0416 smith street', 'bellmore', 'place'),
(3, ' food n liqor', '0417 7th st', 'oakland', 'place'),
(4, ' in', '0312 sonic drive', 'las vegas', 'place'),
(5, ' in', '1101 sonic drive', 'duarte', 'place'),
(6, ' in', '1031 sonic drive', 'duarte', 'place'),
(7, ' meters', '0331 weho street', 'west hollywood', 'place'),
(8, ' meters', '0226 weho street', 'west hollywood', 'place'),
(9, ' meters', '1216 weho street', 'west hollywood', 'place'),
(10, ' meters', '1211 weho street', 'west hollywood', 'place'),
(11, ' meters', '0924 weho street', 'west hollywood', 'place');

-- --------------------------------------------------------

--
-- Структура таблицы `descriptor_TEMP_JC_RM`
--

CREATE TABLE IF NOT EXISTS `descriptor_TEMP_JC_RM` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `descriptor` varchar(100) NOT NULL DEFAULT '',
  `address` varchar(250) NOT NULL DEFAULT '',
  `city` varchar(250) NOT NULL DEFAULT '',
  `place_type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `descriptor_TEMP_JC_RM`
--

INSERT INTO `descriptor_TEMP_JC_RM` (`id`, `descriptor`, `address`, `city`, `place_type`) VALUES
(2, ' deli south', '0416 smith street', 'bellmore', 'place'),
(3, ' food n liqor', '0417 7th st', 'oakland', 'place'),
(4, ' in', '0312 sonic drive', 'las vegas', 'place'),
(5, ' in', '1101 sonic drive', 'duarte', 'place'),
(6, ' in', '1031 sonic drive', 'duarte', 'place'),
(45, '&#039; la cerveceria', '65 2nd ave', 'new york', 'place'),
(46, '&lt;roshan savio ka', '', 'san francisco', 'place'),
(70, '* t&amp;e authorization apr18 01:51p 5210 at 13:51 the jewel', '', 'new york', 'place'),
(72, '-visa', '', 'bakersfield', 'place'),
(73, '000050eqty index des:tran000050 id:xxxxx5000028632 indn:steven a. topazio co id:xxxxx74104 ppd', '', '', 'special');

-- --------------------------------------------------------

--
-- Структура таблицы `match_history_chains`
--

CREATE TABLE IF NOT EXISTS `match_history_chains` (
  `id` bigint(20) NOT NULL,
  `attempted_by` varchar(100) NOT NULL,
  `_matched_chain_id` bigint(20) DEFAULT NULL,
  `_raw_transaction_id` bigint(20) DEFAULT NULL,
  `_transaction_id` bigint(20) NOT NULL,
  `_rule_id` bigint(20) NOT NULL,
  `confidence` int(11) NOT NULL,
  `match_result` varchar(100) NOT NULL,
  `attempt_date` datetime NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `match_history_chains`
--

INSERT INTO `match_history_chains` (`id`, `attempted_by`, `_matched_chain_id`, `_raw_transaction_id`, `_transaction_id`, `_rule_id`, `confidence`, `match_result`, `attempt_date`, `is_active`) VALUES
(1, 'system', 287, 21839, 1081, 0, 70, 'auto_matched', '2015-12-01 14:51:46', 'Y'),
(2, 'system', 11221278, 21839, 1081, 0, 70, 'auto_matched', '2015-12-01 14:51:46', 'Y'),
(5, 'system', 5393, 21817, 1059, 0, 90, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(6, 'system', 179184, 21818, 1060, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(7, 'system', 8734296, 21834, 1076, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(8, 'system', 14122000, 21835, 1077, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(10, 'system', 15845101, 21861, 1103, 0, 70, 'auto_matched', '2015-12-01 16:12:27', 'Y'),
(11, 'system', 160189, 21877, 1119, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y'),
(12, 'system', 932022, 21883, 1125, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y'),
(13, 'system', 168102, 21891, 1133, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `match_history_stores`
--

CREATE TABLE IF NOT EXISTS `match_history_stores` (
  `id` bigint(20) NOT NULL,
  `attempted_by` varchar(100) NOT NULL,
  `_matched_store_id` bigint(20) DEFAULT NULL,
  `_raw_transaction_id` bigint(20) DEFAULT NULL,
  `_transaction_id` bigint(20) NOT NULL,
  `_rule_id` bigint(20) NOT NULL,
  `confidence` int(11) NOT NULL,
  `match_result` varchar(100) NOT NULL,
  `attempt_date` datetime NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=3469 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `match_history_stores`
--

INSERT INTO `match_history_stores` (`id`, `attempted_by`, `_matched_store_id`, `_raw_transaction_id`, `_transaction_id`, `_rule_id`, `confidence`, `match_result`, `attempt_date`, `is_active`) VALUES
(3453, 'system', 1244918, 21839, 1081, 0, 70, 'auto_matched', '2015-12-01 14:51:46', 'Y'),
(3454, 'system', 11221278, 21839, 1081, 0, 70, 'auto_matched', '2015-12-01 14:51:46', 'Y'),
(3460, 'system', 4808937, 21817, 1059, 0, 90, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(3461, 'system', 12652587, 21818, 1060, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(3462, 'system', 16382023, 21834, 1076, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(3463, 'system', 16411140, 21835, 1077, 0, 70, 'auto_matched', '2015-12-01 16:12:26', 'Y'),
(3465, 'system', 15845101, 21861, 1103, 0, 70, 'auto_matched', '2015-12-01 16:12:27', 'Y'),
(3466, 'system', 5964939, 21877, 1119, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y'),
(3467, 'system', 14959339, 21883, 1125, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y'),
(3468, 'system', 11672238, 21891, 1133, 0, 70, 'auto_matched', '2015-12-01 16:12:28', 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `payee_distinct_temp_jc`
--

CREATE TABLE IF NOT EXISTS `payee_distinct_temp_jc` (
  `payee_name` varchar(100) DEFAULT NULL,
  `address` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `payee_distinct_temp_jc`
--

INSERT INTO `payee_distinct_temp_jc` (`payee_name`, `address`, `city`) VALUES
('Quaker State Liquor', '6901 Melrose Ave', 'Los Angeles'),
('Susina Bakery', '7122 Beverly Blvd', 'Los Angeles'),
('Shell', '8500 W Pico Blvd', 'Los Angeles'),
('Hollywood Juice Bar', '7021  Hollywood Blvd', 'Los Angeles'),
('Palm Thai Restaurant', '5900 Hollywood Blvd', 'Los Angeles'),
('Subway', '1270 S La Cienega Blvd', 'Los Angeles'),
('THE CORNER HOLLYWOOD', '', ''),
('City Center Parking Inc', '220 W 21st St', 'Los Angeles'),
('Republique', '624 La Brea Ave', 'Los Angeles'),
('YOGURTLAND MIRACLEMILE', '', 'Los Angeles');

-- --------------------------------------------------------

--
-- Структура таблицы `plaid_access_token`
--

CREATE TABLE IF NOT EXISTS `plaid_access_token` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `bank_code` varchar(100) NOT NULL,
  `user_email` varchar(300) NOT NULL,
  `access_token` varchar(300) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=50 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `plaid_access_token`
--

INSERT INTO `plaid_access_token` (`id`, `_user_id`, `_bank_id`, `bank_code`, `user_email`, `access_token`, `is_active`, `date_entered`) VALUES
(1, 1, 3832, 'bofa', 'john.doe.test@gmail.com', 'test_bofa', 'Y', '2015-09-29 13:38:45'),
(2, 1, 11396, 'usaa', 'john.doe.test@gmail.com', 'test_usaa', 'Y', '2015-09-29 16:58:54'),
(28, 44, 38698, 'wells', 'al.zziwa@wexel.com', 'test_wells', 'Y', '2016-02-18 19:21:07'),
(35, 44, 38693, 'chase', 'al.zziwa@wexel.com', 'test_chase', 'Y', '2016-02-18 19:48:09'),
(36, 6, 38698, 'wells', 'azziwa@gmail.com', 'test_wells', 'Y', '2016-03-01 10:39:02'),
(37, 45, 38693, 'chase', 'al.zziwa@tech.gov', 'test_chase', 'Y', '2016-03-01 10:39:39'),
(38, 0, 38694, 'amex', '', 'test_amex', 'Y', '2016-04-15 12:45:05'),
(41, 0, 38693, 'chase', '', 'test_chase', 'Y', '2016-04-15 14:04:29'),
(48, 13, 38694, 'amex', 'azziwa@gmail.gov', 'test_amex', 'Y', '2016-04-15 14:16:11'),
(49, 44, 38694, 'amex', 'al.zziwa@wexel.com', 'test_amex', 'Y', '2016-04-15 14:17:43');

-- --------------------------------------------------------

--
-- Структура таблицы `plaid_categories`
--

CREATE TABLE IF NOT EXISTS `plaid_categories` (
  `id` bigint(20) NOT NULL,
  `category_id` varchar(100) NOT NULL,
  `category_string` varchar(100) NOT NULL,
  `level_1` varchar(100) NOT NULL,
  `level_2` varchar(100) NOT NULL,
  `level_3` varchar(100) NOT NULL,
  `level_4` varchar(100) NOT NULL,
  `type` varchar(100) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `plaid_categories`
--

INSERT INTO `plaid_categories` (`id`, `category_id`, `category_string`, `level_1`, `level_2`, `level_3`, `level_4`, `type`) VALUES
(1, '19025004', 'Shops:Food and Beverage Store:Beer, Wine and Spirits', 'Shops', 'Food and Beverage Store', 'Beer, Wine and Spirits', '', 'place'),
(2, '13005000', 'Food and Drink:Restaurants', 'Food and Drink', 'Restaurants', '', '', 'place'),
(3, '22009000', 'Travel:Gas Stations', 'Travel', 'Gas Stations', '', '', 'place'),
(4, '22013000', 'Travel:Parking', 'Travel', 'Parking', '', '', 'place'),
(5, '13005056', 'Food and Drink:Restaurants:Asian', 'Food and Drink', 'Restaurants', 'Asian', '', 'place'),
(6, '19051000', 'Shops:Warehouses and Wholesale Stores', 'Shops', 'Warehouses and Wholesale Stores', '', '', 'place'),
(7, '13005053', 'Food and Drink:Restaurants:Bakery', 'Food and Drink', 'Restaurants', 'Bakery', '', 'place'),
(8, '17001015', 'Recreation:Arts and Entertainment:Bowling', 'Recreation', 'Arts and Entertainment', 'Bowling', '', 'place'),
(9, '13001000', 'Food and Drink:Bar', 'Food and Drink', 'Bar', '', '', 'place'),
(10, '19025000', 'Shops:Food and Beverage Store', 'Shops', 'Food and Beverage Store', '', '', 'place');

-- --------------------------------------------------------

--
-- Структура таблицы `plaid_category_matches`
--

CREATE TABLE IF NOT EXISTS `plaid_category_matches` (
  `id` bigint(20) NOT NULL,
  `plaid_sub_category_id` varchar(100) NOT NULL,
  `_clout_category_id` bigint(20) NOT NULL,
  `_clout_sub_category_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `plaid_category_matches`
--

INSERT INTO `plaid_category_matches` (`id`, `plaid_sub_category_id`, `_clout_category_id`, `_clout_sub_category_id`) VALUES
(1, '14001002', 10, 1013),
(2, '19014000', 7, 634),
(3, '12008003', 8, 875),
(4, '18030000', 13, 1643),
(5, '18033000', 13, 1644),
(6, '22012000', 18, 2076),
(7, '22012000', 18, 2077),
(8, '18020014', 13, 1645),
(9, '18020014', 13, 1646),
(10, '18020014', 13, 1647);

-- --------------------------------------------------------

--
-- Структура таблицы `promotions`
--

CREATE TABLE IF NOT EXISTS `promotions` (
  `id` bigint(20) NOT NULL,
  `owner_id` bigint(20) NOT NULL,
  `owner_type` enum('person','store','merchant','system','other') NOT NULL,
  `promotion_type` enum('cashback','perk') NOT NULL,
  `start_score` float NOT NULL,
  `end_score` float NOT NULL,
  `number_viewed` int(11) NOT NULL,
  `number_redeemed` int(11) NOT NULL,
  `new_customers` int(11) NOT NULL,
  `gross_sales` float NOT NULL,
  `is_event` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_boosted` enum('Y','N') NOT NULL DEFAULT 'N',
  `boost_budget` float NOT NULL,
  `boost_start_date` datetime NOT NULL,
  `boost_end_date` datetime NOT NULL,
  `boost_remaining` float NOT NULL,
  `name` varchar(300) NOT NULL,
  `amount` float NOT NULL,
  `description` varchar(255) NOT NULL,
  `status` enum('active','pending','inactive','deleted') NOT NULL DEFAULT 'pending',
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL,
  `custom_category_id` bigint(20) unsigned zerofill DEFAULT NULL,
  `cash_back_percentage` int(11) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=274 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `promotions`
--

INSERT INTO `promotions` (`id`, `owner_id`, `owner_type`, `promotion_type`, `start_score`, `end_score`, `number_viewed`, `number_redeemed`, `new_customers`, `gross_sales`, `is_event`, `is_boosted`, `boost_budget`, `boost_start_date`, `boost_end_date`, `boost_remaining`, `name`, `amount`, `description`, `status`, `start_date`, `end_date`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`, `custom_category_id`, `cash_back_percentage`) VALUES
(1, 10029873, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(2, 10041523, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(3, 10065137, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(4, 10100258, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(5, 10161035, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(6, 10255193, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '30% OFF', 30, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(7, 10390294, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '40% OFF', 40, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(8, 1, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(9, 10434056, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '50% OFF', 50, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(10, 10443914, 'store', 'cashback', 100, 1000, 0, 0, 0, 0, 'N', 'Y', 500, '2015-10-15 21:20:13', '2016-03-14 00:00:00', 500, '40% OFF', 40, '', 'active', '2015-08-14 00:00:00', '2016-08-14 00:00:00', '2015-10-15 15:50:53', 1, '2015-10-15 15:50:53', 1, NULL, NULL),
(189, 3, 'person', 'cashback', 0, 0, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash back', 0, '', 'pending', '2016-07-23 00:00:00', '2016-07-23 00:00:00', '0000-00-00 00:00:00', 4, '0000-00-00 00:00:00', NULL, 00000000000000000000, 48),
(190, 4, 'person', 'cashback', 0, 2000000, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash Back', 50, 'test descr', 'pending', '2016-12-02 00:00:00', '2017-08-24 00:00:00', '0000-00-00 00:00:00', 4, '0000-00-00 00:00:00', NULL, 00000000000000000000, 67),
(225, 2344, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, 'asdasdas', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2342, '0000-00-00 00:00:00', NULL, 00000000000000000003, 0),
(226, 23844, 'person', 'perk', 500, 0, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, 'asdasdas', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 28342, '0000-00-00 00:00:00', NULL, 00000000000000000003, 0),
(227, 238844, 'person', 'perk', 500, 0, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, 'asdasdas', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 283842, '0000-00-00 00:00:00', NULL, 00000000000000000003, 0),
(242, 3454, 'person', 'cashback', 100, 2000000, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash Back', 50, 'asdasdas', 'pending', '2016-07-25 00:00:00', '2016-07-25 00:00:00', '0000-00-00 00:00:00', 3452, '0000-00-00 00:00:00', NULL, 00000000000000000003, 35),
(270, 1, 'person', 'cashback', 0, 2000000, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash Back', 70, 'test descr', 'pending', '2019-10-03 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 4, '0000-00-00 00:00:00', NULL, 00000000000000000000, 44),
(272, 4, 'person', 'cashback', 0, 2000000, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash Back', 0, 'test descr', 'pending', '2019-10-03 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', 4, '0000-00-00 00:00:00', NULL, 00000000000000000000, 32),
(273, 4, 'person', 'cashback', 0, 2000000, 0, 0, 0, 0, 'N', 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'Cash Back', 0, 'test descr', 'pending', '2019-10-03 00:00:00', '2018-10-02 00:00:00', '0000-00-00 00:00:00', 4, '0000-00-00 00:00:00', NULL, 00000000000000000000, 32);

-- --------------------------------------------------------

--
-- Структура таблицы `promotion_notices`
--

CREATE TABLE IF NOT EXISTS `promotion_notices` (
  `id` bigint(20) NOT NULL,
  `_promotion_id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `attend_status` enum('pending','not_going','cancelled','confirmed','attended','not_attended') NOT NULL DEFAULT 'pending',
  `status` enum('received','read','archived') NOT NULL DEFAULT 'received',
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `promotion_notices`
--

INSERT INTO `promotion_notices` (`id`, `_promotion_id`, `_user_id`, `_store_id`, `attend_status`, `status`, `date_entered`, `last_updated`, `_last_updated_by`) VALUES
(1, 535, 1, 10990520, 'attended', 'archived', '2016-06-02 17:31:26', '2016-06-08 18:25:03', 1),
(2, 535, 13, 10990520, 'confirmed', 'read', '2016-05-11 17:00:00', '2016-05-26 00:00:00', 13),
(13, 795, 1, 10990520, 'confirmed', 'read', '2016-06-01 00:00:00', '2016-07-08 15:04:03', 1),
(15, 545, 1, 114318, 'confirmed', 'read', '2016-06-06 10:27:00', '2016-06-06 10:27:00', 1),
(16, 524, 1, 10523993, 'pending', 'read', '2016-06-06 10:27:02', '2016-06-08 16:15:09', 1),
(49, 538, 1, 1111189, 'cancelled', 'read', '2016-06-08 16:24:35', '2016-06-15 10:16:55', 1),
(50, 575, 1, 1311111, 'cancelled', 'read', '2016-06-08 16:42:37', '2016-06-09 15:59:39', 1),
(72, 581, 1, 13478164, 'cancelled', 'read', '2016-06-09 18:37:53', '2016-06-10 14:53:42', 1),
(74, 540, 13, 11262755, 'confirmed', 'read', '2016-06-09 18:54:31', '2016-06-09 18:54:31', 13),
(75, 559, 1, 12137372, 'cancelled', 'read', '2016-06-09 18:58:17', '2016-06-10 11:04:51', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `promotion_rules`
--

CREATE TABLE IF NOT EXISTS `promotion_rules` (
  `id` bigint(20) NOT NULL,
  `rule_type` varchar(100) NOT NULL,
  `rule_details` text NOT NULL,
  `_promotion_id` bigint(20) DEFAULT NULL,
  `rule_amount` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `promotion_rules`
--

INSERT INTO `promotion_rules` (`id`, `rule_type`, `rule_details`, `_promotion_id`, `rule_amount`) VALUES
(1, 'requires_scheduling', 'Requires scheduling to take advantage of this perk.', 834, 'Y'),
(2, 'how_many_uses', 'Maximum of 5 uses', 572, '5'),
(3, 'requires_scheduling', 'A reservation with 7080 Hollywood is required to take advantage of this perk.', 538, 'Y'),
(4, 'requires_scheduling', 'A reservation with Beso is required to take advantage of this perk.', 524, 'Y'),
(5, 'requires_scheduling', 'A reservation with Exxonmobil is required to take advantage of this perk.', 575, 'Y'),
(6, 'requires_scheduling', 'A reservation with Gjelina is required to take advantage of this perk.', 1026, 'Y'),
(7, 'requires_scheduling', 'A reservation with Kitchen is required to take advantage of this perk.', 1027, 'Y'),
(8, 'requires_scheduling', 'A reservation with Palisades Levity Live Llc is required to take advantage of this perk.', 535, 'Y'),
(9, 'requires_scheduling', 'A reservation with Alaska Airlines is required to take advantage of this perk.', 538, 'Y'),
(10, 'requires_scheduling', 'A reservation with Flemings is required to take advantage of this perk.', 1030, 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `queries`
--

CREATE TABLE IF NOT EXISTS `queries` (
  `id` bigint(20) NOT NULL,
  `code` varchar(300) NOT NULL,
  `details` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=487 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `queries`
--

INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(1, 'get_user_by_id', 'SELECT * FROM clout_v1_3.users U WHERE id =''_USER_ID_'' '),
(24, 'get_cron_schedules', 'SELECT * FROM cron_schedule WHERE is_done=''_IS_DONE_'' _EXTRA_CONDITIONS_ _LIMIT_TEXT_'),
(110, 'get_cron_job_list', 'SELECT S.id, S.job_type, S.activity_code, cap_first_letter_in_words(REPLACE(S.activity_code, ''_'', '' '')) AS cron_display, S.cron_value AS cron_details, UNIX_TIMESTAMP(L.event_time) AS start_time, UNIX_TIMESTAMP(S.run_time) AS end_time, S.last_result AS result, L.record_count AS total_records, S.repeat_code, S.is_done\nFROM cron_schedule S \nLEFT JOIN cron_log L ON (S.id=L._cron_job_id)\nWHERE 1=1 _PHRASE_CONDITION_ \nGROUP BY S.id \nORDER BY L.event_time DESC \n_LIMIT_TEXT_'),
(111, 'update_cron_job_status', 'UPDATE cron_schedule SET is_done=''_IS_DONE_'' WHERE id=''_JOB_ID_'''),
(138, 'add_access_token', 'INSERT IGNORE INTO plaid_access_token (_user_id, _bank_id, bank_code, user_email, access_token, is_active, date_entered) \n\nVALUES (''_USER_ID_'', ''_BANK_ID_'', ''_BANK_CODE_'', ''_USER_EMAIL_'', ''_ACCESS_TOKEN_'', ''Y'', NOW())'),
(139, 'get_access_token', 'SELECT access_token FROM plaid_access_token WHERE user_email=''_USER_EMAIL_'' AND bank_code=''_BANK_CODE_'' AND is_active=''Y'' LIMIT 1'),
(140, 'add_to_cron_schedule', 'INSERT IGNORE INTO cron_schedule (job_type, activity_code, cron_value, is_done, last_result, repeat_code) \n\nVALUES (''_JOB_TYPE_'', ''_ACTIVITY_CODE_'', ''_CRON_VALUE_'', ''N'', ''none'', ''_REPEAT_CODE_'')'),
(142, 'update_cron_schedule_field', 'UPDATE cron_schedule SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_ID_'''),
(143, 'add_cron_log', 'INSERT INTO cron_log (_cron_job_id, user_id, job_type, activity_code, result, uri, log_details, record_count, ip_address, event_time) VALUES \n(''_JOB_ID_'', ''_USER_ID_'', ''_JOB_TYPE_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_RECORD_COUNT_'', ''_IP_ADDRESS_'', NOW())'),
(144, 'get_user_by_email', 'SELECT id AS user_id, first_name, last_name FROM clout_v1_3.users \nWHERE email_address=''_EMAIL_ADDRESS_'''),
(145, 'remove_clout_transactions_by_api_ids', 'DELETE FROM transactions WHERE _raw_id IN (SELECT id FROM transactions_raw WHERE transaction_id IN (_API_IDS_))'),
(146, 'remove_raw_transactions_by_api_ids', 'DELETE FROM transactions_raw WHERE transaction_id IN (_API_IDS_)'),
(147, 'disable_plaid_access_token', 'UPDATE plaid_access_token SET is_active=''N'' WHERE access_token=''_ACCESS_TOKEN_'''),
(149, 'get_last_transaction_date', 'SELECT MAX(posted_date) AS last_transaction_date, MIN(posted_date) AS earliest_transaction_date FROM transactions_raw WHERE _user_id=''_USER_ID_'' AND _bank_id=''_BANK_ID_'''),
(150, 'get_raw_account', 'SELECT * FROM _RAW_TABLE_NAME_ WHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(151, 'update_raw_bank_account', 'UPDATE bank_accounts_other_raw \n\nSET status=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', balance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', aggr_success_date=''_AGGR_SUCCESS_DATE_'', aggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', institution_login_id=''_INSTITUTION_LOGIN_ID_'', banking_account_type=''_BANKING_ACCOUNT_TYPE_'', posted_date=''_POSTED_DATE_'', available_balance_amount=''_AVAILABLE_BALANCE_AMOUNT_'', interest_type=''_INTEREST_TYPE_'', origination_date=''_ORIGINATION_DATE_'', open_date=''_OPEN_DATE_'', period_interest_rate=''_PERIOD_INTEREST_RATE_'', period_deposit_amount=''_PERIOD_DEPOSIT_AMOUNT_'', period_interest_amount=''_PERIOD_INTEREST_AMOUNT_'', interest_amount_ytd=''_INTEREST_AMOUNT_YTD_'', interest_prior_amount_ytd=''_INTEREST_PRIOR_AMOUNT_YTD_'', maturity_date=''_MATURITY_DATE_'', maturity_amount=''_MATURITY_AMOUNT_'', last_updated=NOW()\n\nWHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(152, 'save_raw_bank_account', 'INSERT IGNORE INTO bank_accounts_other_raw (\naccount_id, _user_id, status, account_number, account_number_real, account_nickname, display_position, _institution_id, description, registered_user_name, balance_amount, \nbalance_date, balance_previous_amount, last_transaction_date, aggr_success_date, aggr_attempt_date, aggr_status_code, currency_code, bank_id, institution_login_id, \nbanking_account_type, posted_date, available_balance_amount, interest_type, origination_date, open_date, period_interest_rate, period_deposit_amount, period_interest_amount, \ninterest_amount_ytd, interest_prior_amount_ytd, maturity_date, maturity_amount, last_updated\n) VALUES \n(\n''_ACCOUNT_ID_'', ''_USER_ID_'', ''_STATUS_'', ''_ACCOUNT_NUMBER_'', ''_ACCOUNT_NUMBER_REAL_'', ''_ACCOUNT_NICKNAME_'', ''_DISPLAY_POSITION_'', ''_INSTITUTION_ID_'', ''_DESCRIPTION_'', \n''_REGISTERED_USER_NAME_'', ''_BALANCE_AMOUNT_'', ''_BALANCE_DATE_'', ''_BALANCE_PREVIOUS_AMOUNT_'', ''_LAST_TRANSACTION_DATE_'', ''_AGGR_SUCCESS_DATE_'', ''_AGGR_ATTEMPT_DATE_'', \n''_AGGR_STATUS_CODE_'', ''_CURRENCY_CODE_'', ''_BANK_ID_'', ''_INSTITUTION_LOGIN_ID_'', ''_BANKING_ACCOUNT_TYPE_'', ''_POSTED_DATE_'', ''_AVAILABLE_BALANCE_AMOUNT_'', ''_INTEREST_TYPE_'', \n''_ORIGINATION_DATE_'', ''_OPEN_DATE_'', ''_PERIOD_INTEREST_RATE_'', ''_PERIOD_DEPOSIT_AMOUNT_'', ''_PERIOD_INTEREST_AMOUNT_'', ''_INTEREST_AMOUNT_YTD_'', ''_INTEREST_PRIOR_AMOUNT_YTD_'', \n''_MATURITY_DATE_'', ''_MATURITY_AMOUNT_'', NOW()\n)\n\nON DUPLICATE KEY UPDATE `status`=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', \nbalance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', \naggr_success_date=''_AGGR_SUCCESS_DATE_'', aggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', \ninstitution_login_id=''_INSTITUTION_LOGIN_ID_'', banking_account_type=''_BANKING_ACCOUNT_TYPE_'', posted_date=''_POSTED_DATE_'', available_balance_amount=''_AVAILABLE_BALANCE_AMOUNT_'', \ninterest_type=''_INTEREST_TYPE_'', origination_date=''_ORIGINATION_DATE_'', open_date=''_OPEN_DATE_'', period_interest_rate=''_PERIOD_INTEREST_RATE_'', period_deposit_amount=''_PERIOD_DEPOSIT_AMOUNT_'', \nperiod_interest_amount=''_PERIOD_INTEREST_AMOUNT_'', interest_amount_ytd=''_INTEREST_AMOUNT_YTD_'', interest_prior_amount_ytd=''_INTEREST_PRIOR_AMOUNT_YTD_'', maturity_date=''_MATURITY_DATE_'',\nmaturity_amount=''_MATURITY_AMOUNT_'', last_updated=NOW()'),
(153, 'update_raw_credit_account', 'UPDATE bank_accounts_credit_raw \r\n\r\nSET status=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', balance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', aggr_success_date=''_AGGR_SUCCESS_DATE_'', aggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', institution_login_id=''_INSTITUTION_LOGIN_ID_'', credit_account_type=''_CREDIT_ACCOUNT_TYPE_'', detailed_description=''_DETAILED_DESCRIPTION_'', interest_rate=''_INTEREST_RATE_'', credit_available_amount=''_CREDIT_AVAILABLE_AMOUNT_'', credit_max_amount=''_CREDIT_MAX_AMOUNT_'', cash_advance_available_amount=''_CASH_ADVANCE_AVAILABLE_AMOUNT_'', cash_advance_max_amount=''_CASH_ADVANCE_MAX_AMOUNT_'', cash_advance_balance=''_CASH_ADVANCE_BALANCE_'', cash_advance_interest_rate=''_CASH_ADVANCE_INTEREST_RATE_'', current_balance=''_CURRENT_BALANCE_'', payment_min_amount=''_PAYMENT_MIN_AMOUNT_'', payment_due_date=''_PAYMENT_DUE_DATE_'', previous_balance=''_PREVIOUS_BALANCE_'', statement_end_date=''_STATEMENT_END_DATE_'', statement_purchase_amount=''_STATEMENT_PURCHASE_AMOUNT_'', statement_finance_amount=''_STATEMENT_FINANCE_AMOUNT_'', past_due_amount=''_PAST_DUE_AMOUNT_'', last_payment_amount=''_LAST_PAYMENT_AMOUNT_'', last_payment_date=''_LAST_PAYMENT_DATE_'', statement_close_balance=''_STATEMENT_CLOSE_BALANCE_'', statement_late_fee_amount=''_STATEMENT_LATE_FEE_AMOUNT_'', last_updated=NOW()\r\n\r\nWHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(154, 'save_raw_credit_account', 'INSERT IGNORE INTO bank_accounts_credit_raw (\naccount_id, _user_id, status, account_number, account_number_real,  account_nickname, display_position, _institution_id, description, registered_user_name, balance_amount, balance_date, \nbalance_previous_amount, last_transaction_date, aggr_success_date, aggr_attempt_date, aggr_status_code, currency_code, bank_id, institution_login_id, credit_account_type, \ndetailed_description, interest_rate, credit_available_amount, credit_max_amount, cash_advance_available_amount, cash_advance_max_amount, cash_advance_balance, cash_advance_interest_rate, \ncurrent_balance, payment_min_amount, payment_due_date, previous_balance, statement_end_date, statement_purchase_amount, statement_finance_amount, past_due_amount, last_payment_amount, \nlast_payment_date, statement_close_balance, statement_late_fee_amount, last_updated\n) VALUES (\n''_ACCOUNT_ID_'', ''_USER_ID_'', ''_STATUS_'', ''_ACCOUNT_NUMBER_'', ''_ACCOUNT_NUMBER_REAL_'', ''_ACCOUNT_NICKNAME_'', ''_DISPLAY_POSITION_'', ''_INSTITUTION_ID_'', ''_DESCRIPTION_'', ''_REGISTERED_USER_NAME_'', \n''_BALANCE_AMOUNT_'', ''_BALANCE_DATE_'', ''_BALANCE_PREVIOUS_AMOUNT_'', ''_LAST_TRANSACTION_DATE_'', ''_AGGR_SUCCESS_DATE_'', ''_AGGR_ATTEMPT_DATE_'', ''_AGGR_STATUS_CODE_'', ''_CURRENCY_CODE_'', ''_BANK_ID_'', \n''_INSTITUTION_LOGIN_ID_'', ''_CREDIT_ACCOUNT_TYPE_'', ''_DETAILED_DESCRIPTION_'', ''_INTEREST_RATE_'', ''_CREDIT_AVAILABLE_AMOUNT_'', ''_CREDIT_MAX_AMOUNT_'', ''_CASH_ADVANCE_AVAILABLE_AMOUNT_'', \n''_CASH_ADVANCE_MAX_AMOUNT_'', ''_CASH_ADVANCE_BALANCE_'', ''_CASH_ADVANCE_INTEREST_RATE_'', ''_CURRENT_BALANCE_'', ''_PAYMENT_MIN_AMOUNT_'', ''_PAYMENT_DUE_DATE_'', ''_PREVIOUS_BALANCE_'', ''_STATEMENT_END_DATE_'', \n''_STATEMENT_PURCHASE_AMOUNT_'', ''_STATEMENT_FINANCE_AMOUNT_'', ''_PAST_DUE_AMOUNT_'', ''_LAST_PAYMENT_AMOUNT_'', ''_LAST_PAYMENT_DATE_'', ''_STATEMENT_CLOSE_BALANCE_'', ''_STATEMENT_LATE_FEE_AMOUNT_'', NOW()\n)\n\nON DUPLICATE KEY UPDATE `status`=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', \nbalance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', aggr_success_date=''_AGGR_SUCCESS_DATE_'', \naggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', institution_login_id=''_INSTITUTION_LOGIN_ID_'', \ncredit_account_type=''_CREDIT_ACCOUNT_TYPE_'', detailed_description=''_DETAILED_DESCRIPTION_'', interest_rate=''_INTEREST_RATE_'', credit_available_amount=''_CREDIT_AVAILABLE_AMOUNT_'', \ncredit_max_amount=''_CREDIT_MAX_AMOUNT_'', cash_advance_available_amount=''_CASH_ADVANCE_AVAILABLE_AMOUNT_'', cash_advance_max_amount=''_CASH_ADVANCE_MAX_AMOUNT_'', cash_advance_balance=''_CASH_ADVANCE_BALANCE_'', \ncash_advance_interest_rate=''_CASH_ADVANCE_INTEREST_RATE_'', current_balance=''_CURRENT_BALANCE_'', payment_min_amount=''_PAYMENT_MIN_AMOUNT_'', payment_due_date=''_PAYMENT_DUE_DATE_'', previous_balance=''_PREVIOUS_BALANCE_'', \nstatement_end_date=''_STATEMENT_END_DATE_'', statement_purchase_amount=''_STATEMENT_PURCHASE_AMOUNT_'', statement_finance_amount=''_STATEMENT_FINANCE_AMOUNT_'', past_due_amount=''_PAST_DUE_AMOUNT_'', \nlast_payment_amount=''_LAST_PAYMENT_AMOUNT_'', last_payment_date=''_LAST_PAYMENT_DATE_'', statement_close_balance=''_STATEMENT_CLOSE_BALANCE_'', statement_late_fee_amount=''_STATEMENT_LATE_FEE_AMOUNT_'', last_updated=NOW()'),
(155, 'get_raw_transaction_by_field', 'SELECT * FROM transactions_raw WHERE _FIELD_NAME_=''_FIELD_VALUE_'' _LIMIT_TEXT_'),
(156, 'update_raw_transaction', 'UPDATE transactions_raw SET transaction_type=''_TRANSACTION_TYPE_'', currency_type=''_CURRENCY_TYPE_'', institution_transaction_id=''_INSTITUTION_TRANSACTION_ID_'', correct_institution_transaction_id=''_CORRECT_INSTITUTION_TRANSACTION_ID_'', correct_action=''_CORRECT_ACTION_'', server_transaction_id=''_SERVER_TRANSACTION_ID_'', check_number=''_CHECK_NUMBER_'', reference_number=''_REF_NUMBER_'', confirmation_number=''_CONFIRMATION_NUMBER_'', payee_id=''_PAYEE_ID_'', payee_name=''_PAYEE_NAME_'', extended_payee_name=''_EXTENDED_PAYEE_NAME_'', memo=''_MEMO_'', type=''_TYPE_'', value_type=''_VALUE_TYPE_'', currency_rate=''_CURRENCY_RATE_'', original_currency=''_ORIGINAL_CURRENCY_'', posted_date=''_POSTED_DATE_'', user_date=''_USER_DATE_'', available_date=''_AVAILABLE_DATE_'', amount=''_AMOUNT_'', running_balance_amount=''_RUNNING_BALANCE_AMOUNT_'', pending=''_PENDING_'', normalized_payee_name=''_NORMALIZED_PAYEE_NAME_'', merchant=''_MERCHANT_'', sic=''_SIC_'', source=''_SOURCE_'', category_name=''_CATEGORY_NAME_'', context_type=''_CONTEXT_TYPE_'', schedule_c=''_SCHEDULE_C_'', banking_transaction_type=''_BANKING_TRANSACTION_TYPE_'', subaccount_fund_type=''_SUBACCOUNT_FUND_TYPE_'', banking_401k_source_type=''_BANKING_401K_SOURCE_TYPE_'', principal_amount=''_PRINCIPAL_AMOUNT_'', interest_amount=''_INTEREST_AMOUNT_'', escrow_total_amount=''_ESCROW_TOTAL_AMOUNT_'', escrow_tax_amount=''_ESCROW_TAX_AMOUNT_'', escrow_insurance_amount=''_ESCROW_INSURANCE_AMOUNT_'', escrow_pmi_amount=''_ESCROW_PMI_AMOUNT_'', escrow_fees_amount=''_ESCROW_FEES_AMOUNT_'', escrow_other_amount=''_ESCROW_OTHER_AMOUNT_'', last_update_date=NOW(), latitude=''_LATITUDE_'', longitude=''_LONGITUDE_'', zipcode=''_ZIPCODE_'', state=''_STATE_'', city=''_CITY_'', address=''_ADDRESS_'', sub_category_id=''_SUB_CATEGORY_ID_'', contact_telephone=''_CONTACT_TELEPHONE_'', website=''_WEBSITE_'', confidence_level=''_CONFIDENCE_LEVEL_'', place_type=''_PLACE_TYPE_'', _user_id=''_USER_ID_'', _bank_id=''_BANK_ID_'', api_account=''_API_ACCOUNT_'' WHERE transaction_id=''_TRANSACTION_ID_'''),
(157, 'save_raw_transaction', 'INSERT INTO transactions_raw (transaction_id, transaction_type, currency_type,  institution_transaction_id, correct_institution_transaction_id, correct_action, server_transaction_id, check_number, reference_number, confirmation_number, payee_id, payee_name, extended_payee_name, memo, type, value_type, currency_rate, original_currency, posted_date, user_date, available_date, amount, running_balance_amount, pending, normalized_payee_name, merchant, sic, source, category_name, context_type, schedule_c, banking_transaction_type, subaccount_fund_type, banking_401k_source_type, principal_amount, interest_amount, escrow_total_amount, escrow_tax_amount, escrow_insurance_amount, escrow_pmi_amount, escrow_fees_amount, escrow_other_amount, last_update_date, latitude, longitude, zipcode, state, city, address, sub_category_id, contact_telephone, website, confidence_level, place_type, _user_id, _bank_id, api_account, new_user) \nVALUES \n(''_TRANSACTION_ID_'', ''_TRANSACTION_TYPE_'', ''_CURRENCY_TYPE_'', ''_INSTITUTION_TRANSACTION_ID_'', ''_CORRECT_INSTITUTION_TRANSACTION_ID_'', ''_CORRECT_ACTION_'', ''_SERVER_TRANSACTION_ID_'', ''_CHECK_NUMBER_'', ''_REF_NUMBER_'', ''_CONFIRMATION_NUMBER_'', ''_PAYEE_ID_'', ''_PAYEE_NAME_'', ''_EXTENDED_PAYEE_NAME_'', ''_MEMO_'', ''_TYPE_'', ''_VALUE_TYPE_'', ''_CURRENCY_RATE_'', ''_ORIGINAL_CURRENCY_'', ''_POSTED_DATE_'', ''_USER_DATE_'', ''_AVAILABLE_DATE_'', ''_AMOUNT_'', ''_RUNNING_BALANCE_AMOUNT_'', ''_PENDING_'', ''_NORMALIZED_PAYEE_NAME_'', ''_MERCHANT_'', ''_SIC_'', ''_SOURCE_'', ''_CATEGORY_NAME_'', ''_CONTEXT_TYPE_'', ''_SCHEDULE_C_'', ''_BANKING_TRANSACTION_TYPE_'', ''_SUBACCOUNT_FUND_TYPE_'', ''_BANKING_401K_SOURCE_TYPE_'', ''_PRINCIPAL_AMOUNT_'', ''_INTEREST_AMOUNT_'', ''_ESCROW_TOTAL_AMOUNT_'', ''_ESCROW_TAX_AMOUNT_'', ''_ESCROW_INSURANCE_AMOUNT_'', ''_ESCROW_PMI_AMOUNT_'', ''_ESCROW_FEES_AMOUNT_'', ''_ESCROW_OTHER_AMOUNT_'', NOW(), ''_LATITUDE_'', ''_LONGITUDE_'', ''_ZIPCODE_'', ''_STATE_'', ''_CITY_'', ''_ADDRESS_'', ''_SUB_CATEGORY_ID_'', ''_CONTACT_TELEPHONE_'', ''_WEBSITE_'', ''_CONFIDENCE_LEVEL_'', ''_PLACE_TYPE_'', ''_USER_ID_'', ''_BANK_ID_'', ''_API_ACCOUNT_'', ''_NEW_USER_'')'),
(158, 'get_un_saved_raw_transaction_ids', 'SELECT id FROM transactions_raw WHERE is_saved=''N'' AND _user_id=''_USER_ID_'' AND _bank_id=''_BANK_ID_'' '),
(161, 'get_unprocessed_accounts', '(SELECT id, ''credit'' AS account_type, account_id, account_number_real, _institution_id AS bank_id, \nIFNULL((SELECT institution_name FROM banks WHERE id=B._institution_id LIMIT 1),'''') AS bank_name, \nregistered_user_name AS card_holder_full_name, account_nickname, currency_code, credit_available_amount AS balance\nFROM bank_accounts_credit_raw B WHERE _user_id=''_USER_ID_'' AND is_saved=''N'')\n\nUNION \n\n(SELECT id, ''other'' AS account_type, account_id, account_number_real, _institution_id AS bank_id, \nIFNULL((SELECT institution_name FROM banks WHERE id=B._institution_id LIMIT 1),'''') AS bank_name, \nregistered_user_name AS card_holder_full_name, account_nickname, currency_code, available_balance_amount AS balance \nFROM bank_accounts_other_raw B WHERE _user_id=''_USER_ID_'' AND is_saved=''N'')'),
(162, 'add_bank_account', 'INSERT IGNORE INTO bank_accounts (_user_id, account_type, account_id, account_number, _bank_id, issue_bank_name, card_holder_full_name, account_nickname, currency_code, is_verified, status) \n\n(SELECT ''_USER_ID_'' AS _user_id, ''_ACCOUNT_TYPE_'' AS account_type, ''_ACCOUNT_ID_'' AS account_id, ''_ACCOUNT_NUMBER_'' AS account_number, ''_BANK_ID_'' AS _bank_id, institution_name AS issue_bank_name, ''_CARD_HOLDER_FULL_NAME_'' AS card_holder_full_name, ''_ACCOUNT_NICKNAME_'' AS account_nickname, ''_CURRENCY_CODE_'' AS currency_code, ''_IS_VERIFIED_'' AS is_verified, ''active'' AS status \nFROM banks \nWHERE id=''_BANK_ID_'')'),
(163, 'update_account_as_saved', 'UPDATE _ACCOUNT_TABLE_NAME_ SET is_saved=''_IS_SAVED_'' WHERE id=''_ID_'''),
(165, 'mark_previous_tracking_as_not_active', 'UPDATE _TABLE_NAME_ SET is_latest=''N'' WHERE _bank_account_id=''_BANK_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'''),
(166, 'add_user_account_tracking', 'INSERT IGNORE INTO _TABLE_NAME_ ( _bank_account_id, _user_id, _BALANCE_FIELD_, read_date, is_latest) VALUES (''_BANK_ACCOUNT_ID_'', ''_USER_ID_'', ''_BALANCE_VALUE_'', NOW(), ''Y'')'),
(167, 'update_user_balance', 'UPDATE clout_v1_3.users \nSET _TYPE__balance=(SELECT SUM(B._TYPE__amount) FROM clout_v1_3cron.user__TYPE__tracking B WHERE B.is_latest=''Y'' AND _user_id=''_USER_ID_'') \n\nWHERE id=''_USER_ID_'''),
(168, 'get_bank_account', 'SELECT * FROM bank_accounts WHERE _user_id=''_USER_ID_'' AND account_id=''_ACCOUNT_ID_'' AND _bank_id=''_BANK_ID_'''),
(169, 'update_user_default_score', 'UPDATE users \nSET default_store_score=(SELECT IF((SELECT total_score \n	FROM cacheview__store_score_by_default \n	WHERE user_id=''_USER_ID_'' LIMIT 1) IS NOT NULL, total_score, 0) \nFROM cacheview__store_score_by_default WHERE user_id=''_USER_ID_'' LIMIT 1) \nWHERE id=''_USER_ID_'''),
(170, 'get_new_store_scores', 'SELECT * FROM (\nSELECT DISTINCT (SELECT cap_first_letter_in_words(name) FROM clout_v1_3.stores WHERE id=S.store_id LIMIT 1) AS store_name, \ntotal_score AS store_score \n\nFROM cacheview__store_score_by_store S\nWHERE user_id=''_USER_ID_'' AND is_reported=''N'' \nHAVING store_name IS NOT NULL \nORDER BY total_score DESC\n_LIMIT_TEXT_\n) A\nGROUP BY store_name '),
(256, 'get_transaction_payees_for_search', 'SELECT DISTINCT zipcode, LOWER(state) AS state, LOWER(city) AS city, LOWER(SUBSTRING_INDEX(address, '' '', 3)) AS address, \nLOWER(IF(LENGTH(SUBSTRING_INDEX(payee_name, '' '', 1)) > 5, SUBSTRING_INDEX(payee_name, '' '', 1), \n   IF(LENGTH(SUBSTRING_INDEX(payee_name, '' '', 2)) > 8, \n   SUBSTRING_INDEX(payee_name, '' '', 2),\n   SUBSTRING_INDEX(payee_name, '' '', 3)\n))) AS name\n\nFROM transactions_raw R \nWHERE R._user_id=''_USER_ID_'' AND R.is_processed=''N''\n'),
(258, 'remove_temp_table', 'DROP TABLE IF EXISTS temp___TABLE_STUB_'),
(259, 'add_temp_table', 'CREATE TABLE temp___TABLE_STUB_ (_DEFINITION_)'),
(260, 'add_top_searches_for_user_stores', 'INSERT INTO temp___TABLE_STUB_ (store_id, real_name, search_name, real_address, search_address, zipcode, confidence) \n(SELECT ''_STORE_ID_'' AS store_id, ''_REAL_NAME_'' AS real_name, ''_SEARCH_NAME_'' AS search_name, ''_REAL_ADDRESS_'' AS real_address, ''_SEARCH_ADDRESS_'' AS search_address, ''_ZIPCODE_'' AS zipcode, IF(''_REAL_NAME_'' = ''_SEARCH_NAME_'', 90, 70) AS confidence)'),
(261, 'get_user_in_cron_schedule', 'SELECT * FROM cron_schedule WHERE activity_code = ''pull_all_user_transactions'' AND cron_value LIKE CONCAT(''user=_USER_ID_,%'')'),
(262, 'mongodb__search_stores_without_zipcode', 'SELECT store_id, name, address FROM bname WHERE name LIKE ''_NAME_%'' AND address LIKE ''_ADDRESS_%'' _LIMIT_TEXT_'),
(284, 'get_raw_bank_account_record', 'SELECT A.* FROM \n((SELECT account_id, _user_id AS user_id, status, account_number, account_number_real, account_nickname, _institution_id AS bank_id FROM bank_accounts_credit_raw WHERE _user_id=''_USER_ID_'')\nUNION \n(SELECT account_id, _user_id AS user_id, status, account_number, account_number_real, account_nickname, _institution_id AS bank_id FROM bank_accounts_other_raw WHERE _user_id=''_USER_ID_'')\n) A'),
(285, 'delete_activity_log', 'DELETE FROM activity_log WHERE user_id=''_USER_ID_'''),
(286, 'delete_advert_and_promo_tracking', 'DELETE FROM advert_and_promo_tracking WHERE _user_id=''_USER_ID_'''),
(287, 'delete_bank_accounts', 'DELETE FROM bank_accounts WHERE _user_id=''_USER_ID_'''),
(288, 'delete_bank_accounts_credit_raw', 'DELETE FROM bank_accounts_credit_raw WHERE _user_id=''_USER_ID_'''),
(289, 'delete_bank_accounts_other_raw', 'DELETE FROM bank_accounts_other_raw WHERE _user_id=''_USER_ID_'''),
(290, 'delete_cacheview__clout_score_data', 'DELETE FROM cacheview__clout_score_data WHERE user_id=''_USER_ID_'''),
(291, 'delete_cacheview__default_search_suggestions', 'DELETE FROM cacheview__default_search_suggestions WHERE user_id=''_USER_ID_'''),
(292, 'delete_cacheview__where_user_shopped', 'DELETE FROM cacheview__where_user_shopped WHERE user_id=''_USER_ID_'''),
(293, 'delete_cacheview__store_score_data_by_default', 'DELETE FROM cacheview__store_score_data_by_default WHERE user_id=''_USER_ID_'''),
(294, 'delete_cacheview__store_score_data_by_category', 'DELETE FROM cacheview__store_score_data_by_category WHERE user_id=''_USER_ID_'''),
(295, 'delete_cacheview__store_score_data_by_store', 'DELETE FROM cacheview__store_score_data_by_store WHERE user_id=''_USER_ID_'''),
(296, 'delete_commissions_network', 'DELETE FROM commissions_network WHERE _user_id=''_USER_ID_'' OR _source_user_id=''_SOURCE_USER_ID_'''),
(297, 'delete_commissions_transactions', 'DELETE FROM commissions_transactions WHERE _user_id=''_USER_ID_'''),
(298, 'delete_cron_schedule', 'DELETE FROM cron_schedule WHERE cron_value LIKE CONCAT(''user='',''_USER_ID_'','',%'')'),
(299, 'delete_plaid_access_token', 'DELETE FROM plaid_access_token WHERE _user_id=''_USER_ID_'''),
(300, 'delete_promotion_notices', 'DELETE FROM promotion_notices WHERE _user_id=''_USER_ID_'''),
(301, 'delete_score_tracking_clout', 'DELETE FROM score_tracking_clout WHERE _user_id=''_USER_ID_'''),
(302, 'delete_score_tracking_stores', 'DELETE FROM score_tracking_stores WHERE _user_id=''_USER_ID_'''),
(303, 'delete_transactions', 'DELETE FROM transactions WHERE _user_id=''_USER_ID_'''),
(304, 'delete_transactions_raw', 'DELETE FROM transactions_raw WHERE _user_id=''_USER_ID_'''),
(305, 'delete_user_cash_tracking', 'DELETE FROM user_cash_tracking WHERE _user_id=''_USER_ID_'''),
(306, 'delete_user_credit_tracking', 'DELETE FROM user_credit_tracking WHERE _user_id=''_USER_ID_'''),
(307, 'delete_user_payment_tracking', 'DELETE FROM user_payment_tracking WHERE _user_id=''_USER_ID_'''),
(308, 'get_bank_list', 'SELECT id AS bank_id, institution_name AS bank_name, logo_url, institution_code AS bank_code, \n\nIF(institution_name = ''_PHRASE_'', 1,\nIF(institution_name LIKE CONCAT(''_PHRASE_'',''%''), 2, \nIF(institution_name LIKE CONCAT(''%'',''_PHRASE_'',''%''), 3, \nIF(institution_name LIKE CONCAT(''%'',''_PHRASE_''), 4, \n5)))) AS priority\n\nFROM banks \nWHERE is_featured IN (_FEATURED_STATUS_) \n\n_CODE_CONDITION_\n\nORDER BY priority, LENGTH(institution_name) \n_LIMIT_TEXT_'),
(309, 'get_bank_details', 'SELECT _FIELD_LIST_ FROM banks WHERE id=''_BANK_ID_'''),
(310, 'get_user_banks', 'SELECT DISTINCT B.institution_name AS bank_name, B.id AS bank_id, SUBSTRING_INDEX(B.home_url, ''/'', 3) AS website, B.logo_url, B.phone_number AS telephone \nFROM bank_accounts UB \nLEFT JOIN banks B ON (UB._bank_id=B.id) \nWHERE UB._user_id=''_USER_ID_'''),
(311, 'get_user_access_tokens', 'SELECT DISTINCT access_token FROM plaid_access_token WHERE _user_id IN (''_USER_IDS_'')'),
(313, 'add_event_log', 'INSERT INTO activity_log (user_id, activity_code, result, uri, log_details, ip_address, event_time)\r\nVALUES (''_USER_ID_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_IP_ADDRESS_'', NOW())'),
(314, 'get_user_event_count', 'SELECT COUNT(DISTINCT _promotion_id) AS events FROM promotion_notices WHERE status=''received'' AND _user_id=''_USER_ID_'''),
(315, 'get_users_without_bank_account', 'SELECT U.id AS user_id \nFROM clout_v1_3.users U \nWHERE U.user_status=''active'' \nAND (SELECT id FROM clout_v1_3cron.bank_accounts WHERE _user_id=U.id LIMIT 1) IS NULL \n'),
(316, 'get_users_without_network', 'SELECT U.id AS user_id \nFROM clout_v1_3.users U \nWHERE U.user_status=''active'' \nAND (SELECT id FROM clout_v1_3.referrals WHERE _referred_by=U.id AND referrer_type=''user'' LIMIT 1) IS NULL \n'),
(317, 'get_promotion_by_id', 'SELECT P.*, S.id AS store_id, S.name, S.logo_url, S.small_cover_image, S.large_cover_image FROM promotions P LEFT JOIN clout_v1_3.stores S ON (P.owner_id=S.id) WHERE P.id=''_PROMOTION_ID_'''),
(318, 'get_promotion_rules', 'SELECT * FROM promotion_rules WHERE _promotion_id=''_PROMOTION_ID_'''),
(319, 'get_edit_store_details_by_id', 'SELECT id AS store_id, address_line_1 AS address, zipcode,  name, logo_url, small_cover_image, large_cover_image FROM clout_v1_3.stores WHERE id=''_STORE_ID_'''),
(320, 'get_store_locations_by_id', 'SELECT S.*, \nIF((SELECT id FROM clout_v1_3.store_favorites WHERE _store_id=S.id AND _user_id=''_USER_ID_'' LIMIT 1) IS NULL, ''N'', ''Y'') AS is_favorite, \nCONCAT(address_line_1, '', '', city, '' '', state, '', '', zipcode, '' '', _country_code) AS full_address\n\nFROM  clout_v1_3.stores S \nWHERE S.id IN (SELECT S2.id FROM  clout_v1_3.stores S1 LEFT JOIN  clout_v1_3.stores S2 ON (S1._store_owner_id=S2._store_owner_id) \n	WHERE S1.id=''_STORE_ID_'' AND S1._store_owner_id <> ''3'')'),
(321, 'add_new_store_descriptor_record', 'INSERT INTO `transaction_descriptors_suggested_stores` (_transaction_descriptor_id, suggested_store_id, store_id, _chain_id, _category_id, status, date_entered, _entered_by) VALUES \n\n(''_DESCRIPTOR_ID_'', ''_SUGGESTED_STORE_ID_'', ''_STORE_ID_'', ''_CHAIN_ID_'', ''_CATEGORY_ID_'', ''_STATUS_'', NOW(), ''_USER_ID_'')\n\nON DUPLICATE KEY UPDATE _chain_id=''_CHAIN_ID_'', _category_id=''_CATEGORY_ID_'', status=''_STATUS_'''),
(322, 'mark_store_as_selected', 'UPDATE transaction_descriptors_suggested_stores \nSET is_selected=(SELECT IF(store_id=''_STORE_ID_'', ''Y'', ''N'')) \nWHERE _chain_id=''_CHAIN_ID_'''),
(323, 'get_store_transaction_statistics', 'SELECT \r\n(SELECT COUNT(transaction_id) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'') AS lifeTimeSpendingTransactions, \r\n(SELECT SUM(amount) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'') AS lifeTimeSpendingAmount, \r\n(SELECT DATEDIFF(NOW(), start_date) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'' ORDER BY start_date DESC LIMIT 1) AS daysSinceLastTransaction, \r\n(SELECT amount FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'' ORDER BY start_date DESC LIMIT 1) AS lastTransactionAmount, \r\n(SELECT COUNT(id) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''approved'') AS availableRewards, \r\n(SELECT SUM(pay_out) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''approved'') AS availableRewardAmount, \r\n(SELECT COUNT(id) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''pending'') AS pendingRewards, \r\n(SELECT SUM(pay_out) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''pending'') AS pendingRewardAmount\r\n'),
(324, 'get_rule_for_promotion', 'SELECT * FROM promotion_rules WHERE _promotion_id=''_PROMOTION_ID_'' AND rule_type=''_RULE_TYPE_'''),
(325, 'get_transaction_status_summary', '(SELECT ''all_transactions'' AS status_code, ''All Transactions'' AS status_string) \nUNION \n(SELECT ''admin_matched'' AS status_code, ''Admin Matched'' AS status_string) \nUNION \n(SELECT ''auto_matched'' AS status_code, ''Auto-Matched'' AS status_string) \nUNION \n(SELECT ''edits_pending'' AS status_code, ''Edits Pending'' AS status_string) \nUNION \n(SELECT ''has_problem_flag'' AS status_code, ''Has Problem Flag'' AS status_string) \nUNION \n(SELECT ''not_found'' AS status_code, ''Not Found'' AS status_string) \nUNION \n(SELECT ''unqualified'' AS status_code, ''Unqualified'' AS status_string) '),
(326, 'get_transaction_scope_list', 'SELECT id AS scope_id, scope_name, IF(''_DESCRIPTOR_ID_'' <> '''' AND (SELECT _scope_id FROM transaction_descriptors WHERE id=''_DESCRIPTOR_ID_'' LIMIT 1) = id, ''Y'', ''N'') AS is_selected FROM transaction_descriptor_scopes'),
(327, 'get_transaction_problem_flags', 'SELECT F.id, F.name\n FROM clout_v1_3.flags F WHERE F.`type`=''problem'' ORDER BY F.`name` '),
(328, 'get_category_level_1_list', 'SELECT C1.id, C1.name,''N'' AS is_selected\n\nFROM clout_v1_3.`categories_level_1` C1 WHERE C1.is_active=''Y'' ORDER BY C1.name ASC'),
(329, 'get_category_level_2_suggestion_list', 'SELECT CONCAT(C2.id,''__'',C2._categories_level_1_id) AS id, C2.suggestion AS name, C2._categories_level_1_id AS level_1_id,\nIF((SELECT CS.id FROM transaction_descriptor_sub_categories_suggestions CS WHERE CS._sub_category_id=C2.id AND CS._descriptor_id=''_DESCRIPTOR_ID_'' ) IS NOT NULL, ''Y'',''N'') AS is_selected\n\n FROM clout_v1_3.`categories_level_2_suggestions` C2 WHERE C2.status = ''pending'' ORDER BY C2.suggestion'),
(330, 'get_chain_match_attempts_by_descriptor', 'SELECT A.* FROM \n((SELECT _chain_id AS id, C.name, \n(SELECT CAT.name FROM clout_v1_3.categories_level_1 CAT LEFT JOIN clout_v1_3.chain_categories CC ON (CC._category_id=CAT.id) WHERE CC._chain_id=DC._chain_id LIMIT 1) AS category, \nC.website, is_selected\nFROM `transaction_descriptor_chains` DC \nLEFT JOIN clout_v1_3.chains C ON (DC._chain_id=C.id) \nWHERE DC._transaction_descriptor_id = ''_DESCRIPTOR_ID_'')\n\nUNION \n\n(SELECT MC._matched_chain_id AS id, C.name, \n(SELECT CAT.name FROM clout_v1_3.categories_level_1 CAT LEFT JOIN clout_v1_3.chain_categories CC ON (CC._category_id=CAT.id) WHERE CC._chain_id=MC._matched_chain_id LIMIT 1) AS category, \nC.website, ''N'' AS is_selected \nFROM match_history_chains MC\nLEFT JOIN clout_v1_3.chains C ON (MC._matched_chain_id=C.id) \nWHERE MC._raw_transaction_id IN (SELECT _transactions_raw_id FROM `transaction_descriptor_transactions` WHERE _descriptor_id=''_DESCRIPTOR_ID_''))\n) A \n_LIMIT_TEXT_'),
(331, 'get_store_match_attempts_by_descriptor', 'SELECT A.* FROM (\n(SELECT DS.store_id AS id, \n(SELECT cap_first_letter_in_words(CONCAT(address_line_1, '' '', address_line_2)) FROM clout_v1_3.stores WHERE id=DS.store_id LIMIT 1) AS address, \n(SELECT zipcode FROM clout_v1_3.stores WHERE id=DS.store_id LIMIT 1) AS zipcode, DS.is_selected \nFROM transaction_descriptors_suggested_stores DS \nWHERE DS.store_id != ''0'' AND DS._transaction_descriptor_id=''_DESCRIPTOR_ID_'' AND DS._chain_id = ''_CHAIN_ID_'')\n\nUNION\n\n(SELECT MC._matched_store_id AS id, \n(SELECT cap_first_letter_in_words(CONCAT(address_line_1, '' '', address_line_2)) FROM clout_v1_3.stores WHERE id=MC._matched_store_id LIMIT 1) AS address, \n(SELECT zipcode FROM clout_v1_3.stores WHERE id=MC._matched_store_id LIMIT 1) AS zipcode,\n ''N'' AS is_selected \nFROM match_history_stores MC\nWHERE MC._raw_transaction_id IN (SELECT _transactions_raw_id FROM `transaction_descriptor_transactions` WHERE _descriptor_id=''_DESCRIPTOR_ID_'') \nAND MC._matched_store_id IN (SELECT _store_id FROM clout_v1_3.store_chains WHERE _chain_id=''_CHAIN_ID_''))\n) A\n\n _LIMIT_TEXT_'),
(332, 'get_descriptor_list', 'SELECT D.id AS descriptor_id, \nD.description, \n(SELECT scope_name FROM `transaction_descriptor_scopes` WHERE id=D._scope_id) AS scope, \nD.possible_location_matches AS possible_locations, \nD.affected_transaction_amount AS affected_amount, \nD.affected_transaction_number AS affected_number, \nD.status, \n(SELECT C1.`name` FROM `transaction_descriptor_sub_categories` SC2 \n	LEFT JOIN clout_v1_3.categories_level_2 C2 ON (C2.id=SC2._sub_category_id) \n	LEFT JOIN clout_v1_3.categories_level_1 C1 ON (C2._category_id=C1.id) WHERE SC2._descriptor_id=D.id AND C1.`name` IS NOT NULL LIMIT 1) AS category, \n(SELECT C.`name` FROM transactions_raw R LEFT JOIN transactions T ON (T._raw_id=R.id) \n	LEFT JOIN clout_v1_3.store_chains SC ON (SC._store_id=T._store_id) LEFT JOIN clout_v1_3.chains C ON (C.id=SC._chain_id)\n	WHERE R.payee_name = D.description AND C.`name` IS NOT NULL LIMIT 1) AS sample_chain, \n\nIF((SELECT _chain_id FROM transaction_descriptor_chains WHERE _transaction_descriptor_id=D.id ORDER BY is_selected DESC LIMIT 1) IS NOT NULL, \n	IF((SELECT id FROM transaction_descriptors_suggested_stores WHERE _transaction_descriptor_id=D.id LIMIT 1) IS NOT NULL, \n		(SELECT COUNT(DS.id) FROM transaction_descriptors_suggested_stores DS \n		LEFT JOIN transaction_descriptor_chains DC ON (DS._chain_id=DC._chain_id AND DS._transaction_descriptor_id=DC._transaction_descriptor_id AND DC.is_selected=''Y'')\n		WHERE DC._transaction_descriptor_id=D.id), 1)\n, 0) AS store_match_count, \n\n(SELECT COUNT(DISTINCT H._matched_store_id) FROM match_history_stores H \n	LEFT JOIN transactions_raw R ON (H._raw_transaction_id=R.id) WHERE R.payee_name = D.description AND H._matched_store_id IS NOT NULL) AS possible_matches, \n\nIF(''_PHRASE_'' <> '''', \nIF(D.description = ''_PHRASE_'', 1, \nIF(D.description LIKE CONCAT(''%'',''_PHRASE_'',''%''), 2,\nIF(D.description LIKE CONCAT(''_PHRASE_'',''%''), 3,\nIF(D.description LIKE CONCAT(''%'',''_PHRASE_''), 4,\nIF(D.description LIKE CONCAT(LEFT(''_PHRASE_'',LOCATE('' '',''_PHRASE_'') - 1),''%''), 5, 6\n))))), 7) AS list_order\n\n\nFROM `transaction_descriptors` D  \nLEFT JOIN clout_v1_3.changes CH ON (CH._transaction_descriptor_id = D.id AND CH._entered_by <> ''0'' AND CH._entered_by IS NOT NULL)\nWHERE \n(''_PHRASE_'' = '''' || (''_PHRASE_'' <> '''' AND MATCH D.description AGAINST (''_PHRASE_'')))\n _BANK_FILTER_\n _STATUS_FILTER_BEFORE_\n _ADMIN_FILTER_\nGROUP BY D.description \n _STATUS_FILTER_AFTER_\nORDER BY list_order ASC, D.affected_transaction_amount DESC \n  _LIMIT_TEXT_'),
(333, 'get_previous_and_new_descriptor_scope', 'SELECT S1.scope_name AS previous_scope, S2.scope_name AS new_scope, D._scope_id AS previous_id, S2.id AS new_id \r\nFROM transaction_descriptors D \r\nLEFT JOIN `transaction_descriptor_scopes` S1 ON (D._scope_id=S1.id) \r\nLEFT JOIN `transaction_descriptor_scopes` S2 ON (''_NEW_SCOPE_ID_''=S2.id) \r\nWHERE D.id = ''_DESCRIPTOR_ID_'''),
(334, 'update_descriptor_scope', 'UPDATE transaction_descriptors SET _scope_id=''_SCOPE_ID_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'',  \r\nstatus=IF((SELECT status_match FROM `transaction_descriptor_scopes` WHERE id=''_SCOPE_ID_'') <> '''', \r\n	(SELECT status_match FROM `transaction_descriptor_scopes` WHERE id=''_SCOPE_ID_''), \r\n	status) \r\nWHERE id=''_DESCRIPTOR_ID_'''),
(335, 'add_matching_rule_due_to_scope', 'INSERT INTO store_match_rules (rule_type, confidence, match_store_id, details, is_active, descriptor_id) \r\n(SELECT ''reject'' AS rule_type, ''100'' AS confidence, '''' AS match_store_id, \r\nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \r\n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\r\nFROM transaction_descriptors D \r\nWHERE D.id = ''_DESCRIPTOR_ID_'' AND status=''unqualified'')\r\n\r\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(336, 'get_store_chain_details', 'SELECT (SELECT name FROM clout_v1_3.stores WHERE id=''_STORE_ID_'') AS store_name, (SELECT name FROM clout_v1_3.chains WHERE id=''_CHAIN_ID_'') AS chain_name, (SELECT COUNT(DISTINCT _store_id) FROM clout_v1_3.store_chains WHERE _chain_id=''_CHAIN_ID_'') AS location_count'),
(337, 'remove_matching_rules_due_to_location', 'DELETE FROM store_match_rules WHERE rule_type=''match'' AND descriptor_id=''_DESCRIPTOR_ID_'' AND match_store_id <> '''''),
(338, 'add_matching_rule_due_to_location', 'INSERT INTO store_match_rules (rule_type, confidence, match_store_id, details, is_active, descriptor_id) \r\n(SELECT ''match'' AS rule_type, ''100'' AS confidence, ''_STORE_ID_'' AS match_store_id, \r\nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \r\n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\r\nFROM transaction_descriptors D \r\nWHERE D.id = ''_DESCRIPTOR_ID_'')\r\n\r\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(339, 'mark_chain_as_selected', 'UPDATE `transaction_descriptor_chains` \r\nSET is_selected=(SELECT IF(_chain_id=''_CHAIN_ID_'', ''Y'', ''N'')) \r\nWHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'''),
(340, 'get_category_details', 'SELECT * FROM clout_v1_3.`categories_level_1` WHERE id=''_CATEGORY_ID_'''),
(342, 'add_descriptor_sub_category', 'INSERT IGNORE INTO `transaction_descriptor_sub_categories` (_descriptor_id, _sub_category_id) VALUES \r\n(''_DESCRIPTOR_ID_'', ''_SUB_CATEGORY_ID_'')'),
(343, 'get_sub_category_name_list', 'SELECT GROUP_CONCAT(cap_first_letter_in_words(name) SEPARATOR '', '') AS list FROM clout_v1_3.`categories_level_2` WHERE id IN (''_ID_LIST_'')'),
(344, 'get_suggested_sub_category_name_list', 'SELECT GROUP_CONCAT(cap_first_letter_in_words(suggestion) SEPARATOR '', '') AS list FROM clout_v1_3.`categories_level_2_suggestions` WHERE id IN (''_ID_LIST_'')'),
(345, 'remove_descriptor_categories', 'DELETE FROM transaction_descriptor_sub_categories WHERE _descriptor_id=''_DESCRIPTOR_ID_'''),
(346, 'add_descriptor_categories', 'INSERT IGNORE INTO transaction_descriptor_sub_categories (_descriptor_id, _sub_category_id )\n\n(SELECT ''_DESCRIPTOR_ID_'' AS _descriptor_id, C.id AS _sub_category_id FROM clout_v1_3.categories_level_2 C WHERE id IN (''_ID_LIST_''))'),
(347, 'add_suggested_descriptor_categories', 'INSERT INTO `transaction_descriptor_sub_categories_suggestions` (_descriptor_id, _sub_category_id, suggestion_count) \r\n\r\n(SELECT DISTINCT ''_DESCRIPTOR_ID_'' AS _descriptor_id, C.id AS _sub_category_id, ''1'' AS suggestion_count FROM clout_v1_3.categories_level_2 C \r\nWHERE C.id IN (''_ID_LIST_'')) \r\n\r\nON DUPLICATE KEY UPDATE suggestion_count=(suggestion_count+1)'),
(348, 'get_sample_descriptor_category', 'SELECT C1.name AS sample_category FROM transaction_descriptor_sub_categories DC \r\nLEFT JOIN clout_v1_3.categories_level_2 C2 ON (C2.id=DC._sub_category_id) \r\nLEFT JOIN clout_v1_3.categories_level_1 C1 ON (C1.id=C2._category_id) \r\nWHERE DC._descriptor_id=''_DESCRIPTOR_ID_'' LIMIT 1'),
(349, 'get_matching_rules', 'SELECT * FROM (\n(SELECT A.*, \nIF(LEFT(A.search_string, 1) = ''%'' AND RIGHT(A.search_string, 1) = ''%'', ''contains'', \nIF(LEFT(A.search_string, 1) = ''%'', ''ending_with'', \nIF(RIGHT(A.search_string, 1) = ''%'', ''starting_with'', ''equal_to''))) AS search_criteria,\nTRIM(BOTH ''%'' FROM A.search_string) AS search_string_clean, \nIF(A.match_id IS NOT NULL AND A.match_id <> ''0'', `cap_first_letter_in_words`((SELECT CONCAT(S.`name`, '' | '', S.address_line_1, '' '', S.zipcode) FROM clout_v1_3.stores S WHERE id=A.match_id LIMIT 1)), '''') AS target_name\n \nFROM \n(SELECT id, rule_type AS rule_action, match_store_id AS match_id, descriptor_id, \nSUBSTRING_INDEX(SUBSTRING_INDEX(details, "''_PAYEE_NAME_'' LIKE ''", -1), "'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''", 1) AS search_string,\nis_active, ''store'' AS rule_category\nFROM store_match_rules) A\n\nWHERE descriptor_id=''_DESCRIPTOR_ID_'' AND ''store'' IN (''_TYPES_'')\nORDER BY rule_action \n _LIMIT_TEXT_\n)\n\nUNION \n\n(SELECT A.*, \nIF(LEFT(A.search_string, 1) = ''%'' AND RIGHT(A.search_string, 1) = ''%'', ''contains'', \nIF(LEFT(A.search_string, 1) = ''%'', ''ending_with'', \nIF(RIGHT(A.search_string, 1) = ''%'', ''starting_with'', ''equal_to''))) AS search_criteria,\nTRIM(BOTH ''%'' FROM A.search_string) AS search_string_clean, \n(SELECT C.`name` FROM clout_v1_3.chains C WHERE C.id=A.match_id LIMIT 1) AS target_name\n\nFROM \n(SELECT id, rule_type AS rule_action, match_chain_id AS match_id, descriptor_id, \nSUBSTRING_INDEX(SUBSTRING_INDEX(details, "''_PAYEE_NAME_'' LIKE ''", -1), "'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''", 1) AS search_string,\nis_active, ''chain'' AS rule_category\nFROM chain_match_rules) A\n\nWHERE descriptor_id=''_DESCRIPTOR_ID_'' AND ''chain'' IN (''_TYPES_'') \nORDER BY rule_action \n _LIMIT_TEXT_\n)) B WHERE B.search_string_clean LIKE ''_PHRASE_''\n_LIMIT_TEXT_'),
(350, 'add_matching_rule', 'INSERT IGNORE INTO _CATEGORY__match_rules (rule_type, confidence, match__CATEGORY__id, descriptor_id, details, is_active) VALUES \n(''_RULE_TYPE_'', ''_CONFIDENCE_'', ''_MATCH_ID_'', ''_DESCRIPTOR_ID_'', ''_DETAILS_'', ''_IS_ACTIVE_'')'),
(351, 'get_generic_table_data', 'SELECT _FIELD_LIST_ FROM _TABLE_NAME_ WHERE _CONDITION_ _LIMIT_TEXT_'),
(352, 'create_store_data_cache', 'CREATE TABLE IF NOT EXISTS datatable__store__STORE_ID__data LIKE datatable__store_CACHE_data'),
(353, 'get_matched_unprocessed_stores', 'SELECT _store_id AS store_id FROM transactions T WHERE _user_id=''_USER_ID_'' AND _store_id IS NOT NULL AND (SELECT is_processed FROM transactions_raw WHERE id=T._raw_id LIMIT 1) = ''N'''),
(354, 'mongodb__get_store_chains', 'SELECT store_id, chain_id FROM bname WHERE store_id IN (''_STORE_IDS_'')'),
(355, 'cache_store_chain', 'INSERT IGNORE INTO datatable__store_chain_CACHE_data (chain_id, other_store_id, match_store_id)\r\nVALUES (''_CHAIN_ID_'', ''_OTHER_STORE_ID_'', ''_MATCH_STORE_ID_'')'),
(356, 'mongodb__get_all_stores_in_chain', 'SELECT store_id FROM bname WHERE chain_id=''_CHAIN_ID_'''),
(357, 'get_transactions_by_user', 'SELECT \nT.id AS transaction_id, \n\nIFNULL(D.description, R.payee_name) AS transaction_descriptor,\n\nIFNULL((SELECT C1.name FROM clout_v1_3.categories_level_2 C2 \n		LEFT JOIN clout_v1_3.categories_level_1 C1 ON (C2._category_id = C1.id)\n		LEFT JOIN transaction_sub_categories TC ON (TC._sub_category_id = C2.id)\n		WHERE TC._transaction_id=T.id LIMIT 1), \n'''') AS category,\n \nIF(_store_id > 0, _store_id, '''') AS store_id,\n\nIF(_store_id > 0, (SELECT _chain_id FROM clout_v1_3.store_chains WHERE _store_id=T._store_id LIMIT 1), '''') AS chain_id,\n\nIF(_store_id > 0, (SELECT (SELECT cap_first_letter_in_words(name) FROM clout_v1_3.chains WHERE id=SC._chain_id) FROM clout_v1_3.store_chains SC WHERE _store_id=T._store_id LIMIT 1), '''') AS chain_name,\n\nUNIX_TIMESTAMP(start_date) AS `date`,\n\nIFNULL((SELECT _matched_store_id FROM match_history_stores WHERE _transaction_id=T.id LIMIT 1), 0) AS possible_matches, \n\nT.amount,\nT._user_id AS user_id, \n''1'' AS number_of_transactions, \nT.match_status AS status,\n\nIF(''_PHRASE_'' <> '''', \nIF(R.payee_name = '''', 7, \nIF(R.payee_name LIKE CONCAT(''%'',''_PHRASE_'',''%''), 6,\nIF(R.payee_name LIKE CONCAT(''_PHRASE_'',''%''), 5,\nIF(R.payee_name LIKE CONCAT(''%'',''_PHRASE_''), 4,\nIF(R.payee_name LIKE CONCAT(LEFT(''_PHRASE_'',LOCATE('' '',''_PHRASE_'') - 1),''%''), 3, 2\n))))), 1) AS list_order\n\n\nFROM transactions T\nLEFT JOIN transactions_raw R ON (T._raw_id=R.id) \nLEFT JOIN transaction_descriptors D ON (R.payee_name = D.description)\nLEFT JOIN clout_v1_3.changes CH ON (CH._transaction_descriptor_id = D.id AND CH._entered_by > ''0'')\nWHERE \nIF(''_USER_ID_'' <> '''', T._user_id = ''_USER_ID_'', 1) \nAND (''_PHRASE_'' = '''' || (''_PHRASE_'' <> '''' AND MATCH R.payee_name AGAINST (''_PHRASE_'')))\n _BANK_FILTER_\n _STATUS_FILTER_BEFORE_\n _ADMIN_FILTER_\n _STATUS_FILTER_AFTER_\nORDER BY CASE WHEN ''_PHRASE_'' <> '''' THEN list_order ELSE start_date END  DESC\n _LIMIT_TEXT_ '),
(358, 'get_access_details_by_token', 'SELECT * FROM plaid_access_token WHERE access_token=''_ACCESS_TOKEN_'' AND is_active=''Y'' LIMIT 1'),
(359, 'get_system_stats', 'SELECT statistic_code, code_value FROM datatable__system_stats WHERE statistic_code IN (''_STATISTIC_LIST_'')'),
(360, 'get_scoring_criteria', 'SELECT * FROM clout_v1_3cron.score_criteria WHERE categories LIKE ''_CATEGORY_'' OR categories LIKE ''_CATEGORY_,%'' OR categories LIKE ''%,_CATEGORY_,%'' OR categories LIKE ''%,_CATEGORY_''');
INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(361, 'compute_clout_score', 'INSERT INTO clout_v1_3cron.cacheview__clout_score (user_id, facebook_connected_score, email_verified_score, mobile_verified_score, profile_photo_added_score, \nbank_verified_and_active_score, credit_verified_and_active_score, location_services_activated_score, push_notifications_activated_score, \nfirst_payment_success_score, member_processed_payment_last7days_score, first_adrelated_payment_success_score, member_processed_promo_payment_last7days_score, \nhas_first_public_checkin_success_score, has_public_checkin_last7days_score, has_answered_survey_in_last90days_score, number_of_surveys_answered_in_last90days_score, \nnumber_of_direct_referrals_last180days_score, number_of_direct_referrals_last360days_score, total_direct_referrals_score, \nnumber_of_network_referrals_last180days_score, number_of_network_referrals_last360days_score, total_network_referrals_score, spending_of_direct_referrals_last180days_score, \nspending_of_direct_referrals_last360days_score, total_spending_of_direct_referrals_score, spending_of_network_referrals_last180days_score, \nspending_of_network_referrals_last360days_score, total_spending_of_network_referrals_score, spending_last180days_score, spending_last360days_score, \nspending_total_score, ad_spending_last180days_score, ad_spending_last360days_score, ad_spending_total_score, cash_balance_today_score, \naverage_cash_balance_last24months_score, credit_balance_today_score, average_credit_balance_last24months_score, total_score)\n\n(SELECT ''_USER_ID_'' AS user_id, A.*, \n\n(facebook_connected_score + email_verified_score + mobile_verified_score + profile_photo_added_score + \nbank_verified_and_active_score + credit_verified_and_active_score + location_services_activated_score + push_notifications_activated_score + \nfirst_payment_success_score + member_processed_payment_last7days_score + first_adrelated_payment_success_score + member_processed_promo_payment_last7days_score + \nhas_first_public_checkin_success_score + has_public_checkin_last7days_score + has_answered_survey_in_last90days_score + number_of_surveys_answered_in_last90days_score + \nnumber_of_direct_referrals_last180days_score + number_of_direct_referrals_last360days_score + total_direct_referrals_score + \nnumber_of_network_referrals_last180days_score + number_of_network_referrals_last360days_score + total_network_referrals_score + spending_of_direct_referrals_last180days_score + \nspending_of_direct_referrals_last360days_score + total_spending_of_direct_referrals_score + spending_of_network_referrals_last180days_score +\n spending_of_network_referrals_last360days_score + total_spending_of_network_referrals_score + spending_last180days_score + spending_last360days_score + \nspending_total_score + ad_spending_last180days_score + ad_spending_last360days_score + ad_spending_total_score + cash_balance_today_score + \naverage_cash_balance_last24months_score + credit_balance_today_score + average_credit_balance_last24months_score) AS total_score\n\nFROM (\nSELECT \nIF(U.facebook_connected = ''Y'', ''_FACEBOOK_CONNECTED_HIGH_'', ''_FACEBOOK_CONNECTED_LOW_'') AS facebook_connected_score,  \nIF(U.email_connected = ''Y'', ''_EMAIL_VERIFIED_HIGH_'', ''_EMAIL_VERIFIED_LOW_'') AS email_verified_score,  \nIF(U.mobile_connected = ''Y'', ''_MOBILE_VERIFIED_HIGH_'', ''_MOBILE_VERIFIED_LOW_'') AS mobile_verified_score,  \nIF(U.profile_photo_added = ''Y'', ''_PROFILE_PHOTO_ADDED_HIGH_'', ''_PROFILE_PHOTO_ADDED_LOW_'') AS profile_photo_added_score,  \nIF(U.bank_verified_and_active = ''Y'', ''_BANK_VERIFIED_AND_ACTIVE_HIGH_'', ''_BANK_VERIFIED_AND_ACTIVE_LOW_'') AS bank_verified_and_active_score,  \nIF(U.credit_verified_and_active = ''Y'', ''_CREDIT_VERIFIED_AND_ACTIVE_HIGH_'', ''_CREDIT_VERIFIED_AND_ACTIVE_LOW_'') AS credit_verified_and_active_score,  \nIF(U.location_services_activated = ''Y'', ''_LOCATION_SERVICES_ACTIVATED_HIGH_'', ''_LOCATION_SERVICES_ACTIVATED_LOW_'') AS location_services_activated_score,  \nIF(U.push_notifications_activated = ''Y'', ''_PUSH_NOTIFICATIONS_ACTIVATED_HIGH_'', ''_PUSH_NOTIFICATIONS_ACTIVATED_LOW_'') AS push_notifications_activated_score,  \nIF(U.first_payment_success = ''Y'', ''_FIRST_PAYMENT_SUCCESS_HIGH_'', ''_FIRST_PAYMENT_SUCCESS_LOW_'') AS first_payment_success_score,  \nIF(U.member_processed_payment_last7days = ''Y'', ''_MEMBER_PROCESSED_PAYMENT_LAST7DAYS_HIGH_'', ''_MEMBER_PROCESSED_PAYMENT_LAST7DAYS_LOW_'') AS member_processed_payment_last7days_score,  \nIF(U.first_adrelated_payment_success = ''Y'', ''_FIRST_ADRELATED_PAYMENT_SUCCESS_HIGH_'', ''_FIRST_ADRELATED_PAYMENT_SUCCESS_LOW_'') AS first_adrelated_payment_success_score,  \nIF(U.member_processed_promo_payment_last7days = ''Y'', ''_MEMBER_PROCESSED_PROMO_PAYMENT_LAST7DAYS_HIGH_'', ''_MEMBER_PROCESSED_PROMO_PAYMENT_LAST7DAYS_LOW_'') AS member_processed_promo_payment_last7days_score,  \nIF(U.has_first_public_checkin_success = ''Y'', ''_HAS_FIRST_PUBLIC_CHECKIN_SUCCESS_HIGH_'', ''_HAS_FIRST_PUBLIC_CHECKIN_SUCCESS_LOW_'') AS has_first_public_checkin_success_score,  \nIF(U.has_public_checkin_last7days = ''Y'', ''_HAS_PUBLIC_CHECKIN_LAST7DAYS_HIGH_'', ''_HAS_PUBLIC_CHECKIN_LAST7DAYS_LOW_'') AS has_public_checkin_last7days_score,  \nIF(U.has_answered_survey_in_last90days = ''Y'', ''_HAS_ANSWERED_SURVEY_IN_LAST90DAYS_HIGH_'', ''_HAS_ANSWERED_SURVEY_IN_LAST90DAYS_LOW_'') AS has_answered_survey_in_last90days_score,  \n\nIF((U.number_of_surveys_answered_in_last90days * ''_NUMBER_OF_SURVEYS_ANSWERED_IN_LAST90DAYS_PER_'') > (''_NUMBER_OF_SURVEYS_ANSWERED_IN_LAST90DAYS_HIGH_'' + 0), \n''_NUMBER_OF_SURVEYS_ANSWERED_IN_LAST90DAYS_HIGH_'', (U.number_of_surveys_answered_in_last90days * ''_NUMBER_OF_SURVEYS_ANSWERED_IN_LAST90DAYS_PER_'')) AS number_of_surveys_answered_in_last90days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_number_of_direct_referrals_last180days WHERE data_value <= U.number_of_direct_referrals_last180days) * \n''_NUMBER_OF_DIRECT_REFERRALS_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_number_of_direct_referrals_last180days), 0) AS number_of_direct_referrals_last180days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_number_of_direct_referrals_last360days WHERE data_value <= U.number_of_direct_referrals_last360days) * \n''_NUMBER_OF_DIRECT_REFERRALS_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_number_of_direct_referrals_last360days), 0) AS number_of_direct_referrals_last360days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_total_direct_referrals WHERE data_value <= U.total_direct_referrals) * \n''_TOTAL_DIRECT_REFERRALS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_total_direct_referrals), 0) AS total_direct_referrals_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_number_of_network_referrals_last180days WHERE data_value <= U.number_of_network_referrals_last180days) * \n''_NUMBER_OF_NETWORK_REFERRALS_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_number_of_network_referrals_last180days), 0) AS number_of_network_referrals_last180days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_number_of_network_referrals_last360days WHERE data_value <= U.number_of_network_referrals_last360days) * \n''_NUMBER_OF_NETWORK_REFERRALS_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_number_of_network_referrals_last360days), 0) AS number_of_network_referrals_last360days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_total_network_referrals WHERE data_value <= U.total_network_referrals) * \n''_TOTAL_NETWORK_REFERRALS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_total_network_referrals), 0) AS total_network_referrals_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_of_direct_referrals_last180days WHERE data_value <= U.spending_of_direct_referrals_last180days) * \n''_SPENDING_OF_DIRECT_REFERRALS_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_of_direct_referrals_last180days), 0) AS spending_of_direct_referrals_last180days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_of_direct_referrals_last360days WHERE data_value <= U.spending_of_direct_referrals_last360days) * \n''_SPENDING_OF_DIRECT_REFERRALS_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_of_direct_referrals_last360days), 0) AS spending_of_direct_referrals_last360days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_total_spending_of_direct_referrals WHERE data_value <= U.total_spending_of_direct_referrals) * \n''_TOTAL_SPENDING_OF_DIRECT_REFERRALS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_total_spending_of_direct_referrals), 0) AS total_spending_of_direct_referrals_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_of_network_referrals_last180days WHERE data_value <= U.spending_of_network_referrals_last180days) * \n''_SPENDING_OF_NETWORK_REFERRALS_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_of_network_referrals_last180days), 0) AS spending_of_network_referrals_last180days_score,  \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_of_network_referrals_last360days WHERE data_value <= U.spending_of_network_referrals_last360days) * \n''_SPENDING_OF_NETWORK_REFERRALS_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_of_network_referrals_last360days), 0) AS spending_of_network_referrals_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_total_spending_of_network_referrals WHERE data_value <= U.total_spending_of_network_referrals) * \n''_TOTAL_SPENDING_OF_NETWORK_REFERRALS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_total_spending_of_network_referrals), 0) AS total_spending_of_network_referrals_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last180days WHERE data_value <= U.spending_last180days) * \n''_SPENDING_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last180days), 0) AS spending_last180days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last360days WHERE data_value <= U.spending_last360days) * \n''_SPENDING_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last360days), 0) AS spending_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_total WHERE data_value <= U.spending_total) * \n''_SPENDING_TOTAL_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_total), 0) AS spending_total_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_ad_spending_last180days WHERE data_value <= U.ad_spending_last180days) * \n''_AD_SPENDING_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_ad_spending_last180days), 0) AS ad_spending_last180days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_ad_spending_last360days WHERE data_value <= U.ad_spending_last360days) * \n''_AD_SPENDING_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_ad_spending_last360days), 0) AS ad_spending_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_ad_spending_total WHERE data_value <= U.ad_spending_total) * \n''_AD_SPENDING_TOTAL_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_ad_spending_total), 0) AS ad_spending_total_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today WHERE data_value <= U.cash_balance_today) * \n''_CASH_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today), 0) AS cash_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months WHERE data_value <= U.average_cash_balance_last24months) * \n''_AVERAGE_CASH_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months), 0) AS average_cash_balance_last24months_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today WHERE data_value <= U.credit_balance_today) * \n''_CREDIT_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today), 0) AS credit_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months WHERE data_value <= U.average_credit_balance_last24months) * \n''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months), 0) AS average_credit_balance_last24months_score\n\nFROM datatable__user_data U\nWHERE U.user_id = ''_USER_ID_''\n) AS A\n)\n\n\nON DUPLICATE KEY UPDATE facebook_connected_score=VALUES(facebook_connected_score), email_verified_score=VALUES(email_verified_score), \nmobile_verified_score=VALUES(mobile_verified_score), profile_photo_added_score=VALUES(profile_photo_added_score), \nbank_verified_and_active_score=VALUES(bank_verified_and_active_score), credit_verified_and_active_score=VALUES(credit_verified_and_active_score), \nlocation_services_activated_score=VALUES(location_services_activated_score), push_notifications_activated_score=VALUES(push_notifications_activated_score), \nfirst_payment_success_score=VALUES(first_payment_success_score), member_processed_payment_last7days_score=VALUES(member_processed_payment_last7days_score), \nfirst_adrelated_payment_success_score=VALUES(first_adrelated_payment_success_score), \nmember_processed_promo_payment_last7days_score=VALUES(member_processed_promo_payment_last7days_score), \nhas_first_public_checkin_success_score=VALUES(has_first_public_checkin_success_score), has_public_checkin_last7days_score=VALUES(has_public_checkin_last7days_score), \nhas_answered_survey_in_last90days_score=VALUES(has_answered_survey_in_last90days_score), \nnumber_of_surveys_answered_in_last90days_score=VALUES(number_of_surveys_answered_in_last90days_score), \nnumber_of_direct_referrals_last180days_score=VALUES(number_of_direct_referrals_last180days_score), \nnumber_of_direct_referrals_last360days_score=VALUES(number_of_direct_referrals_last360days_score), total_direct_referrals_score=VALUES(total_direct_referrals_score), \nnumber_of_network_referrals_last180days_score=VALUES(number_of_network_referrals_last180days_score), \nnumber_of_network_referrals_last360days_score=VALUES(number_of_network_referrals_last360days_score), total_network_referrals_score=VALUES(total_network_referrals_score), \nspending_of_direct_referrals_last180days_score=VALUES(spending_of_direct_referrals_last180days_score), \nspending_of_direct_referrals_last360days_score=VALUES(spending_of_direct_referrals_last360days_score), \ntotal_spending_of_direct_referrals_score=VALUES(total_spending_of_direct_referrals_score), \nspending_of_network_referrals_last180days_score=VALUES(spending_of_network_referrals_last180days_score), \nspending_of_network_referrals_last360days_score=VALUES(spending_of_network_referrals_last360days_score), \ntotal_spending_of_network_referrals_score=VALUES(total_spending_of_network_referrals_score), \nspending_last180days_score=VALUES(spending_last180days_score), spending_last360days_score=VALUES(spending_last360days_score), \nspending_total_score=VALUES(spending_total_score), ad_spending_last180days_score=VALUES(ad_spending_last180days_score), \nad_spending_last360days_score=VALUES(ad_spending_last360days_score), ad_spending_total_score=VALUES(ad_spending_total_score), \ncash_balance_today_score=VALUES(cash_balance_today_score), average_cash_balance_last24months_score=VALUES(average_cash_balance_last24months_score), \ncredit_balance_today_score=VALUES(credit_balance_today_score), average_credit_balance_last24months_score=VALUES(average_credit_balance_last24months_score), \ntotal_score=VALUES(total_score)\n'),
(362, 'get_cached_user_clout_score', 'SELECT * FROM cacheview__clout_score WHERE user_id=''_USER_ID_'''),
(363, 'get_category_level_2_list', 'SELECT C2.id, C2.name, C2._category_id AS level_1_id,\nIF((SELECT CS.id FROM transaction_descriptor_sub_categories CS WHERE CS._sub_category_id=C2.id AND CS._descriptor_id=''_DESCRIPTOR_ID_'' ) IS NOT NULL, ''Y'',''N'') AS is_selected\n\n FROM clout_v1_3.categories_level_2 C2 WHERE C2.is_active = ''Y'' ORDER BY name'),
(364, 'get_unprocessed_matched_stores', 'SELECT DISTINCT _store_id AS store_id FROM transactions WHERE _user_id=''_USER_ID_'' AND _store_id > 0 AND is_processed = ''N'''),
(366, 'check_if_table_exists', 'SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_schema = ''_DATABASE_'' AND table_name = ''_TABLE_NAME_'' LIMIT 1'),
(367, 'get_user_cache_table_record', 'SELECT * FROM _CACHE_TABLE_ WHERE user_id=''_USER_ID_'''),
(368, 'get_user_data_record', 'SELECT * FROM datatable__user_data WHERE user_id=''_USER_ID_'''),
(369, 'compute_store_score', 'INSERT INTO clout_v1_3cron.cacheview__store_score_by_store (user_id, store_id, my_store_spending_last90days_score,  my_store_spending_last12months_score,  my_store_spending_lifetime_score,  \nmy_chain_spending_last90days_score,  my_chain_spending_last12months_score,  my_chain_spending_lifetime_score,  did_store_survey_last90days_score,  my_direct_competitors_spending_last90days_score,  \nmy_direct_competitors_spending_last12months_score,  my_direct_competitors_spending_lifetime_score,  did_competitor_store_survey_last90days_score,  my_category_spending_last90days_score,  \nmy_category_spending_last12months_score,  my_category_spending_lifetime_score,  did_my_category_survey_last90days_score,  related_categories_spending_last90days_score,  related_categories_spending_last12months_score,  \nrelated_categories_spending_lifetime_score,  did_related_categories_survey_last90days_score,  spending_last180days_score,  spending_last360days_score,  spending_total_score,  bank_verified_and_active_score,  \ncredit_verified_and_active_score,  cash_balance_today_score,  average_cash_balance_last24months_score,  credit_balance_today_score,  average_credit_balance_last24months_score, total_score)\n\n(SELECT ''_USER_ID_'' AS user_id, ''_STORE_ID_'' AS store_id, B.*, \n\n(my_store_spending_last90days_score + my_store_spending_last12months_score + my_store_spending_lifetime_score + \nmy_chain_spending_last90days_score + my_chain_spending_last12months_score + my_chain_spending_lifetime_score + did_store_survey_last90days_score + my_direct_competitors_spending_last90days_score + \nmy_direct_competitors_spending_last12months_score + my_direct_competitors_spending_lifetime_score + did_competitor_store_survey_last90days_score + my_category_spending_last90days_score + \nmy_category_spending_last12months_score + my_category_spending_lifetime_score + did_my_category_survey_last90days_score + related_categories_spending_last90days_score + related_categories_spending_last12months_score + \nrelated_categories_spending_lifetime_score + did_related_categories_survey_last90days_score + spending_last180days_score + spending_last360days_score + spending_total_score + bank_verified_and_active_score + \ncredit_verified_and_active_score + cash_balance_today_score + average_cash_balance_last24months_score + credit_balance_today_score + average_credit_balance_last24months_score) AS total_score\n\nFROM (\nSELECT \nIFNULL((SELECT (COUNT(user_id) * ''_MY_STORE_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_store_spending_last90days <= (''_MY_STORE_SPENDING_LAST90DAYS_''+0)\n), 0) AS my_store_spending_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_STORE_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_store_spending_last12months <= (''_MY_STORE_SPENDING_LAST12MONTHS_''+0)\n), 0) AS my_store_spending_last12months_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_STORE_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_store_spending_lifetime <= (''_MY_STORE_SPENDING_LIFETIME_''+0)\n), 0) AS my_store_spending_lifetime_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CHAIN_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_chain_spending_last90days <= (''_MY_CHAIN_SPENDING_LAST90DAYS_''+0)\n), 0) AS my_chain_spending_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CHAIN_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_chain_spending_last12months <= (''_MY_CHAIN_SPENDING_LAST12MONTHS_''+0)\n), 0) AS my_chain_spending_last12months_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CHAIN_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_chain_spending_lifetime <= (''_MY_CHAIN_SPENDING_LIFETIME_''+0)\n), 0) AS my_chain_spending_lifetime_score, \n\nIF(''_DID_STORE_SURVEY_LAST90DAYS_''=''Y'', ''_DID_STORE_SURVEY_LAST90DAYS_HIGH_'', ''_DID_STORE_SURVEY_LAST90DAYS_LOW_'') AS did_store_survey_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_DIRECT_COMPETITORS_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_direct_competitors_spending_last90days <= (''_MY_DIRECT_COMPETITORS_SPENDING_LAST90DAYS_''+0)\n), 0) AS my_direct_competitors_spending_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_DIRECT_COMPETITORS_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_direct_competitors_spending_last12months <= (''_MY_DIRECT_COMPETITORS_SPENDING_LAST12MONTHS_''+0)\n), 0) AS my_direct_competitors_spending_last12months_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_DIRECT_COMPETITORS_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_direct_competitors_spending_lifetime <= (''_MY_DIRECT_COMPETITORS_SPENDING_LIFETIME_''+0)\n), 0) AS my_direct_competitors_spending_lifetime_score,\n\nIF(''_DID_COMPETITOR_STORE_SURVEY_LAST90DAYS_''=''Y'', ''_DID_COMPETITOR_STORE_SURVEY_LAST90DAYS_HIGH_'', ''_DID_COMPETITOR_STORE_SURVEY_LAST90DAYS_LOW_'') AS did_competitor_store_survey_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_category_spending_last90days <= (''_MY_CATEGORY_SPENDING_LAST90DAYS_''+0)\n), 0) AS my_category_spending_last90days_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_category_spending_last12months <= (''_MY_CATEGORY_SPENDING_LAST12MONTHS_''+0)\n), 0) AS my_category_spending_last12months_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE my_category_spending_lifetime <= (''_MY_CATEGORY_SPENDING_LIFETIME_''+0)\n), 0) AS my_category_spending_lifetime_score,\n\nIF(''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_''=''Y'', ''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_HIGH_'', ''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_LOW_'') AS did_my_category_survey_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE related_categories_spending_last90days <= (''_RELATED_CATEGORIES_SPENDING_LAST90DAYS_''+0)\n), 0) AS related_categories_spending_last90days_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE related_categories_spending_last12months <= (''_RELATED_CATEGORIES_SPENDING_LAST12MONTHS_''+0)\n), 0) AS related_categories_spending_last12months_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__store__STORE_ID__data WHERE related_categories_spending_lifetime <= (''_RELATED_CATEGORIES_SPENDING_LIFETIME_''+0)\n), 0) AS related_categories_spending_lifetime_score,\n\nIF(''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_''=''Y'', ''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_HIGH_'', ''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_LOW_'') AS did_related_categories_survey_last90days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last180days WHERE data_value <= (''_SPENDING_LAST180DAYS_''+0)) * \n''_SPENDING_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last180days), 0) AS spending_last180days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last360days WHERE data_value <= (''_SPENDING_LAST360DAYS_''+0)) * \n''_SPENDING_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last360days), 0) AS spending_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_total WHERE data_value <= (''_SPENDING_TOTAL_''+0)) * \n''_SPENDING_TOTAL_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_total), 0) AS spending_total_score, \n\nIF(''_BANK_VERIFIED_AND_ACTIVE_''=''Y'', ''_BANK_VERIFIED_AND_ACTIVE_HIGH_'', ''_BANK_VERIFIED_AND_ACTIVE_LOW_'') AS bank_verified_and_active_score, \n\nIF(''_CREDIT_VERIFIED_AND_ACTIVE_''=''Y'', ''_CREDIT_VERIFIED_AND_ACTIVE_HIGH_'', ''_CREDIT_VERIFIED_AND_ACTIVE_LOW_'') AS credit_verified_and_active_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today WHERE data_value <= (''_CASH_BALANCE_TODAY_''+0)) * \n''_CASH_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today), 0) AS cash_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months WHERE data_value <= (''_AVERAGE_CASH_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CASH_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months), 0) AS average_cash_balance_last24months_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today WHERE data_value <= (''_CREDIT_BALANCE_TODAY_''+0)) * \n''_CREDIT_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today), 0) AS credit_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months WHERE data_value <= (''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months), 0) AS average_credit_balance_last24months_score\n\nFROM \n(SELECT COUNT(user_id) AS total_customers FROM datatable__store__STORE_ID__data) A\n) B \n)\n\nON DUPLICATE KEY UPDATE my_store_spending_last90days_score=VALUES(my_store_spending_last90days_score),  my_store_spending_last12months_score=VALUES(my_store_spending_last12months_score),  \nmy_store_spending_lifetime_score=VALUES(my_store_spending_lifetime_score), my_chain_spending_last90days_score=VALUES(my_chain_spending_last90days_score),  \nmy_chain_spending_last12months_score=VALUES(my_chain_spending_last12months_score), my_chain_spending_lifetime_score=VALUES(my_chain_spending_lifetime_score),  \ndid_store_survey_last90days_score=VALUES(did_store_survey_last90days_score),  my_direct_competitors_spending_last90days_score=VALUES(my_direct_competitors_spending_last90days_score),  \nmy_direct_competitors_spending_last12months_score=VALUES(my_direct_competitors_spending_last12months_score),  my_direct_competitors_spending_lifetime_score=VALUES(my_direct_competitors_spending_lifetime_score),  \ndid_competitor_store_survey_last90days_score=VALUES(did_competitor_store_survey_last90days_score),  my_category_spending_last90days_score=VALUES(my_category_spending_last90days_score),  \nmy_category_spending_last12months_score=VALUES(my_category_spending_last12months_score),  my_category_spending_lifetime_score=VALUES(my_category_spending_lifetime_score),  \ndid_my_category_survey_last90days_score=VALUES(did_my_category_survey_last90days_score),  related_categories_spending_last90days_score=VALUES(related_categories_spending_last90days_score),  \nrelated_categories_spending_last12months_score=VALUES(related_categories_spending_last12months_score),  related_categories_spending_lifetime_score=VALUES(related_categories_spending_lifetime_score),  \ndid_related_categories_survey_last90days_score=VALUES(did_related_categories_survey_last90days_score),  spending_last180days_score=VALUES(spending_last180days_score),  \nspending_last360days_score=VALUES(spending_last360days_score),  spending_total_score=VALUES(spending_total_score),  bank_verified_and_active_score=VALUES(bank_verified_and_active_score),  \ncredit_verified_and_active_score=VALUES(credit_verified_and_active_score),  cash_balance_today_score=VALUES(cash_balance_today_score),  \naverage_cash_balance_last24months_score=VALUES(average_cash_balance_last24months_score),  credit_balance_today_score=VALUES(credit_balance_today_score),  \naverage_credit_balance_last24months_score=VALUES(average_credit_balance_last24months_score), total_score=VALUES(total_score) \n'),
(370, 'get_cached_store_scores', 'SELECT * FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_'' AND store_id IN (''_MATCHED_STORES_'')'),
(371, 'compute_category_score', 'INSERT INTO clout_v1_3cron.cacheview__store_score_by_category (user_id, sub_category_id, my_category_spending_last90days_score,  \nmy_category_spending_last12months_score,  my_category_spending_lifetime_score,  did_my_category_survey_last90days_score,  related_categories_spending_last90days_score,  related_categories_spending_last12months_score,  \nrelated_categories_spending_lifetime_score,  did_related_categories_survey_last90days_score,  spending_last180days_score,  spending_last360days_score,  spending_total_score,  bank_verified_and_active_score,  \ncredit_verified_and_active_score,  cash_balance_today_score,  average_cash_balance_last24months_score,  credit_balance_today_score,  average_credit_balance_last24months_score, total_score)\n\n(SELECT ''_USER_ID_'' AS user_id, ''_SUB_CATEGORY_ID_'' AS sub_category_id, B.*, \n\n(my_category_spending_last90days_score + my_category_spending_last12months_score + my_category_spending_lifetime_score + did_my_category_survey_last90days_score + related_categories_spending_last90days_score + related_categories_spending_last12months_score + \nrelated_categories_spending_lifetime_score + did_related_categories_survey_last90days_score + spending_last180days_score + spending_last360days_score + spending_total_score + bank_verified_and_active_score + \ncredit_verified_and_active_score + cash_balance_today_score + average_cash_balance_last24months_score + credit_balance_today_score + average_credit_balance_last24months_score) AS total_score\n\nFROM (\nSELECT \nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE my_category_spending_last90days <= (''_MY_CATEGORY_SPENDING_LAST90DAYS_''+0)\n), 0) AS my_category_spending_last90days_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE my_category_spending_last12months <= (''_MY_CATEGORY_SPENDING_LAST12MONTHS_''+0)\n), 0) AS my_category_spending_last12months_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_MY_CATEGORY_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE my_category_spending_lifetime <= (''_MY_CATEGORY_SPENDING_LIFETIME_''+0)\n), 0) AS my_category_spending_lifetime_score,\n\nIF(''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_''=''Y'', ''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_HIGH_'', ''_DID_MY_CATEGORY_SURVEY_LAST90DAYS_LOW_'') AS did_my_category_survey_last90days_score, \n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LAST90DAYS_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE related_categories_spending_last90days <= (''_RELATED_CATEGORIES_SPENDING_LAST90DAYS_''+0)\n), 0) AS related_categories_spending_last90days_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LAST12MONTHS_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE related_categories_spending_last12months <= (''_RELATED_CATEGORIES_SPENDING_LAST12MONTHS_''+0)\n), 0) AS related_categories_spending_last12months_score,\n\nIFNULL((SELECT (COUNT(user_id) * ''_RELATED_CATEGORIES_SPENDING_LIFETIME_HIGH_'') / A.total_customers \nFROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE related_categories_spending_lifetime <= (''_RELATED_CATEGORIES_SPENDING_LIFETIME_''+0)\n), 0) AS related_categories_spending_lifetime_score,\n\nIF(''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_''=''Y'', ''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_HIGH_'', ''_DID_RELATED_CATEGORIES_SURVEY_LAST90DAYS_LOW_'') AS did_related_categories_survey_last90days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last180days WHERE data_value <= (''_SPENDING_LAST180DAYS_''+0)) * \n''_SPENDING_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last180days), 0) AS spending_last180days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last360days WHERE data_value <= (''_SPENDING_LAST360DAYS_''+0)) * \n''_SPENDING_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last360days), 0) AS spending_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_total WHERE data_value <= (''_SPENDING_TOTAL_''+0)) * \n''_SPENDING_TOTAL_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_total), 0) AS spending_total_score, \n\nIF(''_BANK_VERIFIED_AND_ACTIVE_''=''Y'', ''_BANK_VERIFIED_AND_ACTIVE_HIGH_'', ''_BANK_VERIFIED_AND_ACTIVE_LOW_'') AS bank_verified_and_active_score, \n\nIF(''_CREDIT_VERIFIED_AND_ACTIVE_''=''Y'', ''_CREDIT_VERIFIED_AND_ACTIVE_HIGH_'', ''_CREDIT_VERIFIED_AND_ACTIVE_LOW_'') AS credit_verified_and_active_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today WHERE data_value <= (''_CASH_BALANCE_TODAY_''+0)) * \n''_CASH_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today), 0) AS cash_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months WHERE data_value <= (''_AVERAGE_CASH_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CASH_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months), 0) AS average_cash_balance_last24months_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today WHERE data_value <= (''_CREDIT_BALANCE_TODAY_''+0)) * \n''_CREDIT_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today), 0) AS credit_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months WHERE data_value <= (''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months), 0) AS average_credit_balance_last24months_score\n\nFROM \n(SELECT COUNT(user_id) AS total_customers FROM datatable__subcategory__SUB_CATEGORY_ID__data) A\n) B \n)\n\nON DUPLICATE KEY UPDATE my_category_spending_last90days_score=VALUES(my_category_spending_last90days_score),  \nmy_category_spending_last12months_score=VALUES(my_category_spending_last12months_score),  my_category_spending_lifetime_score=VALUES(my_category_spending_lifetime_score),  \ndid_my_category_survey_last90days_score=VALUES(did_my_category_survey_last90days_score),  related_categories_spending_last90days_score=VALUES(related_categories_spending_last90days_score),  \nrelated_categories_spending_last12months_score=VALUES(related_categories_spending_last12months_score),  related_categories_spending_lifetime_score=VALUES(related_categories_spending_lifetime_score),  \ndid_related_categories_survey_last90days_score=VALUES(did_related_categories_survey_last90days_score),  spending_last180days_score=VALUES(spending_last180days_score),  \nspending_last360days_score=VALUES(spending_last360days_score),  spending_total_score=VALUES(spending_total_score),  bank_verified_and_active_score=VALUES(bank_verified_and_active_score),  \ncredit_verified_and_active_score=VALUES(credit_verified_and_active_score),  cash_balance_today_score=VALUES(cash_balance_today_score),  \naverage_cash_balance_last24months_score=VALUES(average_cash_balance_last24months_score),  credit_balance_today_score=VALUES(credit_balance_today_score),  \naverage_credit_balance_last24months_score=VALUES(average_credit_balance_last24months_score), total_score=VALUES(total_score)'),
(372, 'compute_default_store_score', 'INSERT INTO clout_v1_3cron.cacheview__store_score_by_default (user_id, spending_last180days_score,  spending_last360days_score,  spending_total_score,  bank_verified_and_active_score,  \ncredit_verified_and_active_score,  cash_balance_today_score,  average_cash_balance_last24months_score,  credit_balance_today_score,  average_credit_balance_last24months_score, total_score)\n\n(SELECT ''_USER_ID_'' AS user_id, B.*, \n\n(spending_last180days_score + spending_last360days_score + spending_total_score + bank_verified_and_active_score + \ncredit_verified_and_active_score + cash_balance_today_score + average_cash_balance_last24months_score + credit_balance_today_score + average_credit_balance_last24months_score) AS total_score\n\nFROM (\nSELECT \nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last180days WHERE data_value <= (''_SPENDING_LAST180DAYS_''+0)) * \n''_SPENDING_LAST180DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last180days), 0) AS spending_last180days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_last360days WHERE data_value <= (''_SPENDING_LAST360DAYS_''+0)) * \n''_SPENDING_LAST360DAYS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_last360days), 0) AS spending_last360days_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_spending_total WHERE data_value <= (''_SPENDING_TOTAL_''+0)) * \n''_SPENDING_TOTAL_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_spending_total), 0) AS spending_total_score, \n\nIF(''_BANK_VERIFIED_AND_ACTIVE_''=''Y'', ''_BANK_VERIFIED_AND_ACTIVE_HIGH_'', ''_BANK_VERIFIED_AND_ACTIVE_LOW_'') AS bank_verified_and_active_score, \n\nIF(''_CREDIT_VERIFIED_AND_ACTIVE_''=''Y'', ''_CREDIT_VERIFIED_AND_ACTIVE_HIGH_'', ''_CREDIT_VERIFIED_AND_ACTIVE_LOW_'') AS credit_verified_and_active_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today WHERE data_value <= (''_CASH_BALANCE_TODAY_''+0)) * \n''_CASH_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_cash_balance_today), 0) AS cash_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months WHERE data_value <= (''_AVERAGE_CASH_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CASH_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_cash_balance_last24months), 0) AS average_cash_balance_last24months_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today WHERE data_value <= (''_CREDIT_BALANCE_TODAY_''+0)) * \n''_CREDIT_BALANCE_TODAY_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_credit_balance_today), 0) AS credit_balance_today_score, \n\nIFNULL(((SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months WHERE data_value <= (''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_''+0)) * \n''_AVERAGE_CREDIT_BALANCE_LAST24MONTHS_HIGH_'') / (SELECT SUM(frequency) FROM datatable__frequency_average_credit_balance_last24months), 0) AS average_credit_balance_last24months_score\n) B \n)\n\nON DUPLICATE KEY UPDATE spending_last180days_score=VALUES(spending_last180days_score),  spending_last360days_score=VALUES(spending_last360days_score),  \nspending_total_score=VALUES(spending_total_score),  bank_verified_and_active_score=VALUES(bank_verified_and_active_score),  \ncredit_verified_and_active_score=VALUES(credit_verified_and_active_score),  cash_balance_today_score=VALUES(cash_balance_today_score),  \naverage_cash_balance_last24months_score=VALUES(average_cash_balance_last24months_score),  credit_balance_today_score=VALUES(credit_balance_today_score),  \naverage_credit_balance_last24months_score=VALUES(average_credit_balance_last24months_score), total_score=VALUES(total_score) '),
(373, 'get_cached_category_scores', 'SELECT * FROM cacheview__store_score_by_category WHERE user_id=''_USER_ID_'''),
(374, 'get_cached_default_store_score', 'SELECT * FROM cacheview__store_score_by_default WHERE user_id=''_USER_ID_'''),
(377, 'add_change_record', 'INSERT INTO clout_v1_3.changes (_transaction_descriptor_id, description, change_code, change_value, date_entered, _entered_by) VALUES \r\n\r\n(''_DESCRIPTOR_ID_'', ''_DESCRIPTION_'', ''_CHANGE_CODE_'', ''_CHANGE_VALUE_'', NOW(), ''_USER_ID_'')'),
(378, 'add_change_flags', 'INSERT IGNORE INTO clout_v1_3.change_flags (_change_id, _flag_id, notes, date_entered, _entered_by) \r\n\r\n(SELECT DISTINCT ''_CHANGE_ID_'' AS _change_id, F.id AS _flag_id, ''_NOTES_'' AS notes, NOW(), ''_USER_ID_'' AS _entered_by FROM clout_v1_3.flags F WHERE F.id IN (_FLAG_IDS_)) '),
(379, 'add_change_log', 'INSERT INTO clout_v1_3.change_log (_change_id, old_status, new_status, date_entered, _entered_by) VALUES \r\n\r\n(''_CHANGE_ID_'', ''_OLD_STATUS_'', ''_NEW_STATUS_'', NOW(), ''_USER_ID_'')'),
(382, 'get_descriptor_change_list', 'SELECT A.*, \r\nIF(A.last_admin_id=''_USER_ID_'' \r\n	OR (SELECT id FROM clout_v1_3.`user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL AND A.latest_status <> ''verified'', \r\n''Y'', ''N'') AS can_rollback FROM\r\n\r\n(SELECT C.id, \r\n(SELECT UNIX_TIMESTAMP(date_entered) FROM clout_v1_3.change_log WHERE _change_id=C.id ORDER BY date_entered DESC LIMIT 1) AS last_update, \r\nC.`contributors`, \r\nC.description, \r\n(SELECT COUNT(id) FROM clout_v1_3.change_flags WHERE _change_id=C.id) AS flag_count, \r\nIF((SELECT id FROM clout_v1_3.`user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS can_approve, \r\nIF((SELECT id FROM clout_v1_3.`user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS can_reject, \r\n(SELECT CONCAT(U.first_name, '' '', U.last_name) \r\n	FROM clout_v1_3.users U  \r\n	LEFT JOIN clout_v1_3.change_log CL ON (U.id=CL._entered_by) \r\n	LEFT JOIN clout_v1_3.`user_security_settings` S ON (U.id=S._user_id AND S.user_type IN (''clout_owner'',''clout_admin_user''))\r\n	WHERE CL._change_id=C.id\r\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_name, \r\n\r\n(SELECT S.user_type_level \r\n	FROM clout_v1_3.change_log CL\r\n	LEFT JOIN clout_v1_3.`user_security_settings` S ON (CL._entered_by=S._user_id AND S.user_type IN (''clout_owner'',''clout_admin_user''))\r\n	WHERE CL._change_id=C.id\r\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_level, \r\n\r\n\r\n(SELECT CL._entered_by \r\n	FROM clout_v1_3.change_log CL \r\n	WHERE CL._change_id=C.id\r\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_id, \r\n\r\n(SELECT new_status FROM clout_v1_3.change_log WHERE _change_id=C.id ORDER BY date_entered DESC LIMIT 1) AS latest_status\r\n\r\nFROM clout_v1_3.changes C \r\nWHERE C._transaction_descriptor_id = ''_DESCRIPTOR_ID_'' AND C.description LIKE ''_PHRASE_'' \r\nORDER BY C.date_entered DESC \r\n _LIMIT_TEXT_\r\n) A'),
(383, 'add_cached_direct_network_data', 'INSERT IGNORE INTO datatable__network_data (user_id, level_1) \n(SELECT ''_REFERRER_ID_'' AS user_id, ''_USER_ID_'' AS level_1)\nON DUPLICATE KEY \nUPDATE level_1=IF(level_1 IS NOT NULL AND level_1 <> '''', \n	IF((level_1 =''_USER_ID_'' OR level_1 LIKE ''_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_''), level_1, CONCAT(level_1,'','',VALUES(level_1))), \nVALUES(level_1));'),
(384, 'add_cached_other_network_data', 'UPDATE datatable__network_data \nSET _THIS_NETWORK_LEVEL_ = IF(_THIS_NETWORK_LEVEL_ = '''' OR _THIS_NETWORK_LEVEL_ IS NULL, ''_USER_ID_'', \n	IF((_THIS_NETWORK_LEVEL_ =''_USER_ID_'' OR _THIS_NETWORK_LEVEL_ LIKE ''_USER_ID_,%'' OR _THIS_NETWORK_LEVEL_ LIKE ''%,_USER_ID_,%'' OR _THIS_NETWORK_LEVEL_ LIKE ''%,_USER_ID_''), _THIS_NETWORK_LEVEL_, CONCAT(_THIS_NETWORK_LEVEL_,'','',''_USER_ID_''))\n) \nWHERE _HIGHER_NETWORK_LEVEL_ = ''_REFERRER_ID_'' OR _HIGHER_NETWORK_LEVEL_ LIKE CONCAT(''_REFERRER_ID_'','',%'') OR _HIGHER_NETWORK_LEVEL_ LIKE CONCAT(''%,'',''_REFERRER_ID_'','',%'') OR _HIGHER_NETWORK_LEVEL_ LIKE CONCAT(''%,'',''_REFERRER_ID_'');\n'),
(385, 'call_update_user_cache_and_frequency', 'CALL update_user_cache_and_frequency(''_USER_ID_'', ''_DATA_POINT_'',''_DATA_VALUE_'',''_NEW_CHECKBY_DATE_'',''_IS_RANKED_'');'),
(386, 'get_account_balances', 'SELECT * FROM user__ACCOUNT_TYPE__tracking  WHERE _user_id=''_USER_ID_'' AND DATE(read_date) >= (NOW() - INTERVAL _MONTHS_BACK_ MONTH) ORDER BY read_date ASC'),
(387, 'add_table_instance_if_missing', 'CREATE TABLE IF NOT EXISTS _NEW_TABLE_NAME_ LIKE _COPY_TABLE_NAME_'),
(388, 'mongodb__get_store_by_id', 'SELECT name, address_line_1, city, state, zipcode, categories, subcategories FROM bname WHERE store_id=''_STORE_ID_'''),
(389, 'set_datatable_value', 'UPDATE _TABLE_NAME_ SET _DATA_POINT_=''_DATA_VALUE_'' WHERE user_id=''_USER_ID_'''),
(390, 'get_cached_stores_shopped', 'SELECT store_id FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_'''),
(391, 'mongodb__get_stores_with_categories', 'SELECT store_id FROM bname WHERE store_id IN (''_STORE_IDS_'') AND categories IN (''_CATEGORY_IDS_'')'),
(392, 'call_update_store_cache_and_frequency', 'CALL update_store_cache_and_frequency(''_USER_ID_'', ''_STORE_ID_'', ''_DATA_POINT_'',''_DATA_VALUE_'',''_NEW_CHECKBY_DATE_'',''_IS_RANKED_'');'),
(393, 'get_unprocessed_user_transactions', 'SELECT id AS transaction_id, _store_id AS store_id, amount, start_date AS date_entered, match_status \nFROM transactions \nWHERE _user_id=''_USER_ID_'' AND is_processed=''N'' AND transaction_type=''buy'''),
(394, 'get_stores_and_their_competitors', 'SELECT _store_id AS store_id, competitor_id FROM clout_v1_3.store_competitors WHERE _store_id IN (''_STORE_IDS_'') AND competitor_type = ''store'''),
(395, 'get_user_transaction_categories', 'SELECT _transaction_id AS transaction_id,  _category_id AS category, _sub_category_id AS sub_category\nFROM transaction_sub_categories \nWHERE _transaction_id IN (''_TRANSACTION_IDS_'')'),
(396, 'get_user_network', 'SELECT *, \r\n\r\nIF((level_1 = ''_USER_ID_'' OR level_1 LIKE ''_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_''), ''level_1'', \r\nIF((level_2 = ''_USER_ID_'' OR level_2 LIKE ''_USER_ID_,%'' OR level_2 LIKE ''%,_USER_ID_,%'' OR level_2 LIKE ''%,_USER_ID_''), ''level_2'', \r\nIF((level_3 = ''_USER_ID_'' OR level_3 LIKE ''_USER_ID_,%'' OR level_3 LIKE ''%,_USER_ID_,%'' OR level_3 LIKE ''%,_USER_ID_''), ''level_3'',\r\nIF((level_4 = ''_USER_ID_'' OR level_4 LIKE ''_USER_ID_,%'' OR level_4 LIKE ''%,_USER_ID_,%'' OR level_4 LIKE ''%,_USER_ID_''), ''level_4'', \r\n''my_network''\r\n)))) AS select_level\r\n\r\nFROM datatable__network_data \r\n\r\nWHERE user_id=''_USER_ID_''\r\nOR (level_1 = ''_USER_ID_'' OR level_1 LIKE ''_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_,%'' OR level_1 LIKE ''%,_USER_ID_'') \r\nOR (level_2 = ''_USER_ID_'' OR level_2 LIKE ''_USER_ID_,%'' OR level_2 LIKE ''%,_USER_ID_,%'' OR level_2 LIKE ''%,_USER_ID_'')  \r\nOR (level_3 = ''_USER_ID_'' OR level_3 LIKE ''_USER_ID_,%'' OR level_3 LIKE ''%,_USER_ID_,%'' OR level_3 LIKE ''%,_USER_ID_'')\r\nOR (level_4 = ''_USER_ID_'' OR level_4 LIKE ''_USER_ID_,%'' OR level_4 LIKE ''%,_USER_ID_,%'' OR level_4 LIKE ''%,_USER_ID_'')'),
(397, 'get_user_store_data_record', 'SELECT * FROM datatable__store__STORE_ID__data WHERE user_id=''_USER_ID_'''),
(398, 'get_user_sub_category_data_record', 'SELECT * FROM datatable__subcategory__SUB_CATEGORY_ID__data WHERE user_id=''_USER_ID_'''),
(400, 'get_descriptor_change_flags', 'SELECT C.id AS flag_id, C._change_id AS change_id, F.name AS flag_name \r\nFROM clout_v1_3.change_flags C \r\nLEFT JOIN clout_v1_3.flags F ON (C._flag_id=F.id) \r\nWHERE C._change_id=''_CHANGE_ID_'' AND F.name LIKE ''_PHRASE_'' _LIMIT_TEXT_'),
(401, 'get_all_change_flags', 'SELECT id AS flag_id, name AS flag_name FROM clout_v1_3.flags WHERE type=''user_defined'' AND name LIKE ''_PHRASE_'' _LIMIT_TEXT_'),
(402, 'call_update_subcategory_cache_and_frequency', 'CALL update_subcategory_cache_and_frequency(''_USER_ID_'', ''_SUB_CATEGORY_ID_'', ''_DATA_POINT_'',''_DATA_VALUE_'',''_NEW_CHECKBY_DATE_'',''_IS_RANKED_'');'),
(403, 'get_data_point_age_tables', 'SELECT TABLE_NAME AS table_name FROM INFORMATION_SCHEMA.tables WHERE table_schema = ''_DATABASE_'' AND TABLE_NAME LIKE ''datatable__%__age'' AND TABLE_NAME NOT LIKE ''%_CACHE_%''');
INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(404, 'datavalue__number_of_surveys_answered_in_last90days', 'SELECT COUNT(DISTINCT _survey_id) AS number_of_surveys_answered_in_last90days, \nget_checkby_date(IFNULL(MIN(response_date),NOW()), 90, ''day'') AS checkby_date \n\nFROM clout_v1_3.survey_responses \nWHERE _user_id = ''_USER_ID_'' AND DATE(response_date) >= (NOW() - INTERVAL 90 DAY)'),
(405, 'datavalue__number_of_direct_referrals_last180days', 'SELECT COUNT(_user_id) AS number_of_direct_referrals_last180days, \nget_checkby_date(IFNULL(MIN(activation_date),NOW()), 180, ''day'') AS checkby_date \n\nFROM clout_v1_3.referrals \nWHERE _referred_by = ''_USER_ID_'' AND DATE(activation_date) >= (NOW() - INTERVAL 180 DAY)'),
(406, 'datavalue__number_of_direct_referrals_last360days', 'SELECT COUNT(_user_id) AS number_of_direct_referrals_last360days, \nget_checkby_date(IFNULL(MIN(activation_date),NOW()), 360, ''day'') AS checkby_date \n\nFROM clout_v1_3.referrals \nWHERE _referred_by = ''_USER_ID_'' AND DATE(activation_date) >= (NOW() - INTERVAL 360 DAY)'),
(407, 'datavalue__number_of_network_referrals_last180days', 'SELECT (COUNT(R0._user_id) + COUNT(R1._user_id) + COUNT(R2._user_id) + COUNT(R3._user_id)) AS number_of_network_referrals_last180days, \nget_checkby_date(LEAST(IFNULL(MIN(R0.activation_date),NOW()), IFNULL(MIN(R1.activation_date),NOW()), IFNULL(MIN(R2.activation_date),NOW()), IFNULL(MIN(R3.activation_date),NOW())), 180, ''day'') AS checkby_date\n\nFROM clout_v1_3.referrals R0 LEFT JOIN clout_v1_3.referrals R1 ON (R1._referred_by = R0._user_id  AND DATE(R1.activation_date) >= (NOW() - INTERVAL 180 DAY)) \nLEFT JOIN clout_v1_3.referrals R2 ON (R2._referred_by = R1._user_id  AND DATE(R2.activation_date) >= (NOW() - INTERVAL 180 DAY)) \nLEFT JOIN clout_v1_3.referrals R3 ON (R3._referred_by = R2._user_id  AND DATE(R3.activation_date) >= (NOW() - INTERVAL 180 DAY))\nWHERE R0._referred_by = ''_USER_ID_'' AND DATE(R0.activation_date) >= (NOW() - INTERVAL 180 DAY)'),
(408, 'datavalue__number_of_network_referrals_last360days', 'SELECT (COUNT(R0._user_id) + COUNT(R1._user_id) + COUNT(R2._user_id) + COUNT(R3._user_id)) AS number_of_network_referrals_last360days, \nget_checkby_date(LEAST(IFNULL(MIN(R0.activation_date),NOW()), IFNULL(MIN(R1.activation_date),NOW()), IFNULL(MIN(R2.activation_date),NOW()), IFNULL(MIN(R3.activation_date),NOW())), 360, ''day'') AS checkby_date\n\nFROM clout_v1_3.referrals R0 LEFT JOIN clout_v1_3.referrals R1 ON (R1._referred_by = R0._user_id  AND DATE(R1.activation_date) >= (NOW() - INTERVAL 360 DAY)) \nLEFT JOIN clout_v1_3.referrals R2 ON (R2._referred_by = R1._user_id  AND DATE(R2.activation_date) >= (NOW() - INTERVAL 360 DAY)) \nLEFT JOIN clout_v1_3.referrals R3 ON (R3._referred_by = R2._user_id  AND DATE(R3.activation_date) >= (NOW() - INTERVAL 360 DAY))\nWHERE R0._referred_by = ''_USER_ID_'' AND DATE(R0.activation_date) >= (NOW() - INTERVAL 360 DAY)'),
(409, 'datavalue__spending_of_direct_referrals_last180days', 'SELECT SUM(amount) AS spending_of_direct_referrals_last180days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 180, ''day'') AS checkby_date \n\nFROM clout_v1_3cron.transactions\nWHERE _user_id IN (SELECT _user_id FROM clout_v1_3.referrals WHERE _referred_by = ''_USER_ID_'') AND DATE(start_date) >= (NOW() - INTERVAL 180 DAY) \nAND transaction_type = ''buy'''),
(410, 'datavalue__spending_of_direct_referrals_last360days', 'SELECT SUM(amount) AS spending_of_direct_referrals_last360days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 360, ''day'') AS checkby_date \n\nFROM clout_v1_3cron.transactions\nWHERE _user_id IN (SELECT _user_id FROM clout_v1_3.referrals WHERE _referred_by = ''_USER_ID_'') AND DATE(start_date) >= (NOW() - INTERVAL 360 DAY) \nAND transaction_type = ''buy'''),
(411, 'datavalue__spending_of_network_referrals_last180days', 'SELECT \nSUM(amount) AS spending_of_network_referrals_last180days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 180, ''day'') AS checkby_date \n\nFROM clout_v1_3cron.transactions T\nLEFT JOIN  \n(SELECT REPLACE(A.level_ids,'',,'','','') AS user_ids \nFROM \n(SELECT GROUP_CONCAT(IFNULL(R0._user_id,''''),'','', IFNULL(R1._user_id,''''),'','', IFNULL(R2._user_id,''''),'','', IFNULL(R3._user_id,'''')) AS level_ids\nFROM clout_v1_3.referrals R0 LEFT JOIN clout_v1_3.referrals R1 ON (R1._referred_by = R0._user_id) \nLEFT JOIN clout_v1_3.referrals R2 ON (R2._referred_by = R1._user_id) \nLEFT JOIN clout_v1_3.referrals R3 ON (R3._referred_by = R2._user_id)\nWHERE R0._referred_by = ''_USER_ID_''\n) A\n) U ON (U.user_ids = T._user_id OR U.user_ids LIKE CONCAT(T._user_id,'',%'') OR U.user_ids LIKE CONCAT(''%,'',T._user_id,'',%'') OR U.user_ids LIKE CONCAT(''%,'',T._user_id))\n\nWHERE U.user_ids IS NOT NULL AND DATE(start_date) >= (NOW() - INTERVAL 180 DAY) AND transaction_type = ''buy'''),
(412, 'datavalue__spending_last180days', 'SELECT \nSUM(amount) AS spending_last180days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 180, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 180 DAY)'),
(413, 'datavalue__spending_last360days', 'SELECT \r\nSUM(amount) AS spending_last360days, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 360, ''day'') AS checkby_date \r\nFROM clout_v1_3cron.transactions\r\nWHERE _user_id = ''_USER_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 360 DAY)'),
(414, 'datavalue__ad_spending_last180days', 'SELECT \nSUM(amount) AS spending_last180days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 180, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 180 DAY) AND _related_promotion_id > 0'),
(415, 'datavalue__ad_spending_last360days', 'SELECT \r\nSUM(amount) AS spending_last360days, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 360, ''day'') AS checkby_date \r\nFROM clout_v1_3cron.transactions\r\nWHERE _user_id = ''_USER_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 360 DAY) AND _related_promotion_id > 0'),
(416, 'datavalue__spending_of_network_referrals_last360days', 'SELECT \nSUM(amount) AS spending_of_network_referrals_last360days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 360, ''day'') AS checkby_date \n\nFROM clout_v1_3cron.transactions T\nLEFT JOIN  \n(SELECT REPLACE(A.level_ids,'',,'','','') AS user_ids \nFROM \n(SELECT GROUP_CONCAT(IFNULL(R0._user_id,''''),'','', IFNULL(R1._user_id,''''),'','', IFNULL(R2._user_id,''''),'','', IFNULL(R3._user_id,'''')) AS level_ids\nFROM clout_v1_3.referrals R0 LEFT JOIN clout_v1_3.referrals R1 ON (R1._referred_by = R0._user_id) \nLEFT JOIN clout_v1_3.referrals R2 ON (R2._referred_by = R1._user_id) \nLEFT JOIN clout_v1_3.referrals R3 ON (R3._referred_by = R2._user_id)\nWHERE R0._referred_by = ''_USER_ID_''\n) A\n) U ON (U.user_ids = T._user_id OR U.user_ids LIKE CONCAT(T._user_id,'',%'') OR U.user_ids LIKE CONCAT(''%,'',T._user_id,'',%'') OR U.user_ids LIKE CONCAT(''%,'',T._user_id))\n\nWHERE U.user_ids IS NOT NULL AND DATE(start_date) >= (NOW() - INTERVAL 360 DAY) AND transaction_type = ''buy'''),
(417, 'datavalue__average_cash_balance_last24months', 'SELECT SUM(cash_amount)/IFNULL(COUNT(id),1) AS average_cash_balance_last24months, \r\nget_checkby_date(IFNULL(MIN(read_date),NOW()), 24, ''month'') AS checkby_date \r\nFROM user_cash_tracking  WHERE _user_id=''_USER_ID_'' AND DATE(read_date) >= (NOW() - INTERVAL 24 MONTH)'),
(418, 'datavalue__average_credit_balance_last24months', 'SELECT SUM(credit_amount)/IFNULL(COUNT(id),1) AS average_credit_balance_last24months, \r\nget_checkby_date(IFNULL(MIN(read_date),NOW()), 24, ''month'') AS checkby_date \r\nFROM user_credit_tracking  WHERE _user_id=''_USER_ID_'' AND DATE(read_date) >= (NOW() - INTERVAL 24 MONTH)'),
(419, 'datavalue__has_public_checkin_last7days', 'SELECT IF(A.id IS NOT NULL, ''Y'', ''N'') AS has_public_checkin_last7days,\r\nget_checkby_date(IFNULL(A.tracking_time,NOW()), 7, ''day'') AS checkby_date\r\n\r\nFROM (SELECT id, tracking_time FROM clout_v1_3.user_geo_tracking WHERE _user_id=''_USER_ID_'' AND \r\nDATE(tracking_time) >= (NOW() - INTERVAL 7 DAY) ORDER BY tracking_time ASC LIMIT 1) A'),
(420, 'datavalue__has_answered_survey_in_last90days', 'SELECT IF(A.id IS NOT NULL, ''Y'', ''N'') AS has_answered_survey_in_last90days,\r\nget_checkby_date(IFNULL(A.response_date,NOW()), 90, ''day'') AS checkby_date\r\n\r\nFROM (SELECT id, response_date FROM clout_v1_3.survey_responses WHERE _user_id=''_USER_ID_'' AND \r\nDATE(response_date) >= (NOW() - INTERVAL 90 DAY) ORDER BY response_date ASC LIMIT 1) A'),
(421, 'datavalue__my_store_spending_last90days', 'SELECT \r\nSUM(amount) AS my_store_spending_last90days, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \r\nFROM clout_v1_3cron.transactions\r\nWHERE _user_id = ''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 90 DAY)'),
(422, 'datavalue__my_store_spending_last12months', 'SELECT \r\nSUM(amount) AS my_store_spending_last12months, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \r\nFROM clout_v1_3cron.transactions\r\nWHERE _user_id = ''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH)'),
(423, 'datavalue__my_chain_spending_last90days', 'SELECT \nSUM(amount) AS my_chain_spending_last90days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY) AND _store_id > 0 \nAND _chain_id = (SELECT _chain_id FROM clout_v1_3.stores WHERE id=''_STORE_ID_'' LIMIT 1)'),
(424, 'datavalue__my_chain_spending_last12months', 'SELECT \nSUM(amount) AS my_chain_spending_last12months, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) AND _store_id > 0 \nAND _chain_id = (SELECT _chain_id FROM clout_v1_3.stores WHERE id=''_STORE_ID_'' LIMIT 1)'),
(425, 'datavalue__my_direct_competitors_spending_last90days', 'SELECT \nSUM(amount) AS my_direct_competitors_spending_last90days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions T\nWHERE _user_id = ''_USER_ID_''\nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY) AND _store_id > 0 \nAND (SELECT competitor_id FROM clout_v1_3.store_competitors WHERE _store_id=''_STORE_ID_'' AND competitor_id = T._store_id LIMIT 1) IS NOT NULL'),
(426, 'datavalue__my_direct_competitors_spending_last12months', 'SELECT \nSUM(amount) AS my_direct_competitors_spending_last12months, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \nFROM clout_v1_3cron.transactions T \nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) AND _store_id > 0 \nAND (SELECT competitor_id FROM clout_v1_3.store_competitors WHERE _store_id=''_STORE_ID_'' AND competitor_id = T._store_id LIMIT 1) IS NOT NULL \n'),
(427, 'datavalue__my_category_spending_last90days', 'SELECT \nSUM(amount) AS my_category_spending_last90days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' AND _store_id > 0 \nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY)\nAND has_my_category(''_STORE_ID_'', _store_id, ''my_category'') = ''Y'''),
(428, 'datavalue__my_category_spending_last12months', 'SELECT \nSUM(amount) AS my_category_spending_last12months, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) AND _store_id > 0 \nAND has_my_category(''_STORE_ID_'', _store_id, ''my_category'') = ''Y'''),
(429, 'datavalue__did_my_category_survey_last90days', 'SELECT \r\nIF(A.id IS NOT NULL, ''Y'', ''N'') AS did_my_category_survey_last90days,\r\nget_checkby_date(IFNULL(A.response_date,NOW()), 90, ''day'') AS checkby_date\r\n\r\nFROM (SELECT id, response_date FROM clout_v1_3.survey_responses WHERE _user_id=''_USER_ID_'' \r\nAND _store_id > 0 \r\nAND DATE(response_date) >= (NOW() - INTERVAL 90 DAY) \r\nAND has_my_category(''_STORE_ID_'', _store_id, ''my_category'') = ''Y''\r\nORDER BY response_date ASC LIMIT 1) A'),
(430, 'datavalue__did_related_categories_survey_last90days', 'SELECT \nIF(A.id IS NOT NULL, ''Y'', ''N'') AS did_related_categories_survey_last90days,\nget_checkby_date(IFNULL(A.response_date,NOW()), 90, ''day'') AS checkby_date\n\nFROM (SELECT id, response_date FROM clout_v1_3.survey_responses WHERE _user_id=''_USER_ID_'' \nAND _store_id > 0 AND has_my_category(''_STORE_ID_'', _store_id, ''related_category'') = ''Y''\nAND DATE(response_date) >= (NOW() - INTERVAL 90 DAY) \nORDER BY response_date ASC LIMIT 1) A'),
(431, 'datavalue__related_categories_spending_last90days', 'SELECT \nSUM(amount) AS related_categories_spending_last90days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY) AND _store_id > 0 \nAND has_my_category(''_STORE_ID_'', _store_id, ''related_category'') = ''Y'''),
(432, 'datavalue__related_categories_spending_last12months', 'SELECT \nSUM(amount) AS related_categories_spending_last12months, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \nFROM clout_v1_3cron.transactions\nWHERE _user_id = ''_USER_ID_'' \nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) AND _store_id > 0 \nAND has_my_category(''_STORE_ID_'', _store_id, ''related_category'') = ''Y'''),
(433, 'datavalue__my_category_spending_last90days__subcategory', 'SELECT \r\nSUM(amount) AS my_category_spending_last90days, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \r\nFROM clout_v1_3cron.transactions T \r\nWHERE _user_id = ''_USER_ID_''  \r\nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY) \r\nAND (SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=T.id AND _sub_category_id=''_SUB_CATEGORY_ID_'' LIMIT 1) IS NOT NULL'),
(434, 'datavalue__my_category_spending_last12months__subcategory', 'SELECT \r\nSUM(amount) AS my_category_spending_last12months, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \r\nFROM clout_v1_3cron.transactions T \r\nWHERE _user_id = ''_USER_ID_''  \r\nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) \r\nAND (SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=T.id AND _sub_category_id=''_SUB_CATEGORY_ID_'' LIMIT 1) IS NOT NULL'),
(435, 'datavalue__related_categories_spending_last90days__subcategory', 'SELECT \nSUM(amount) AS related_categories_spending_last90days, \nget_checkby_date(IFNULL(MIN(start_date),NOW()), 90, ''day'') AS checkby_date \nFROM clout_v1_3cron.transactions T \nWHERE _user_id = ''_USER_ID_''  \nAND DATE(start_date) >= (NOW() - INTERVAL 90 DAY) \nAND (SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=T.id \n	AND _category_id=(SELECT _category_id FROM clout_v1_3.categories_level_2 WHERE id=''_SUB_CATEGORY_ID_'' LIMIT 1) LIMIT 1\n	) IS NOT NULL'),
(436, 'datavalue__related_categories_spending_last12months__subcategory', 'SELECT \r\nSUM(amount) AS related_categories_spending_last12months, \r\nget_checkby_date(IFNULL(MIN(start_date),NOW()), 12, ''month'') AS checkby_date \r\nFROM clout_v1_3cron.transactions T \r\nWHERE _user_id = ''_USER_ID_''  \r\nAND DATE(start_date) >= (NOW() - INTERVAL 12 MONTH) \r\nAND (SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=T.id \r\n	AND _category_id=(SELECT _category_id FROM clout_v1_3.categories_level_2 WHERE id=''_SUB_CATEGORY_ID_'' LIMIT 1) LIMIT 1\r\n	) IS NOT NULL'),
(437, 'datavalue__did_my_category_survey_last90days__subcategory', 'SELECT \r\nIF(A.id IS NOT NULL, ''Y'', ''N'') AS did_my_category_survey_last90days,\r\nget_checkby_date(IFNULL(A.response_date,NOW()), 90, ''day'') AS checkby_date\r\n\r\nFROM (SELECT id, response_date FROM clout_v1_3.survey_responses R WHERE _user_id=''_USER_ID_'' \r\nAND _store_id > 0 \r\nAND DATE(response_date) >= (NOW() - INTERVAL 90 DAY) \r\nAND (SELECT id FROM clout_v1_3.store_sub_categories WHERE _store_id=R._store_id AND _sub_category_id=''_SUB_CATEGORY_ID_'' LIMIT 1) IS NOT NULL\r\nORDER BY response_date ASC LIMIT 1) A'),
(438, 'datavalue__did_related_categories_survey_last90days__subcategory', 'SELECT \nIF(A.id IS NOT NULL, ''Y'', ''N'') AS did_related_categories_survey_last90days,\nget_checkby_date(IFNULL(A.response_date,NOW()), 90, ''day'') AS checkby_date\n\nFROM (SELECT id, response_date FROM clout_v1_3.survey_responses R WHERE _user_id=''_USER_ID_'' \nAND _store_id > 0 \nAND DATE(response_date) >= (NOW() - INTERVAL 90 DAY) \nAND (SELECT id FROM clout_v1_3.store_sub_categories WHERE _store_id=R._store_id \n	AND _category_id=(SELECT _category_id FROM clout_v1_3.categories_level_2 WHERE id=''_SUB_CATEGORY_ID_'' LIMIT 1) LIMIT 1\n	) IS NOT NULL\nORDER BY response_date ASC LIMIT 1) A'),
(439, 'add_new_flag', 'INSERT IGNORE INTO clout_v1_3.flags (`name`, `type`) VALUES \r\n(''_NAME_'', ''_TYPE_'')'),
(440, 'get_flag_by_descriptor_change', 'SELECT F.name AS flag_name, C._transaction_descriptor_id AS descriptor_id, CF._change_id AS change_id, C.description AS change_name \r\nFROM clout_v1_3.change_flags CF \r\nLEFT JOIN clout_v1_3.flags F ON (F.id=CF._flag_id) \r\nLEFT JOIN clout_v1_3.changes C ON (CF._change_id=C.id)\r\n\r\nWHERE CF.id=''_CHANGE_FLAG_ID_'''),
(441, 'delete_change_flag', 'DELETE FROM clout_v1_3.change_flags WHERE id=''_CHANGE_FLAG_ID_'''),
(442, 'add_matching_rule_due_to_chain', 'INSERT INTO chain_match_rules (rule_type, confidence, match_chain_id, details, is_active, descriptor_id) \r\n(SELECT ''match'' AS rule_type, ''100'' AS confidence, C.id AS match_chain_id, \r\nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \r\n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\r\nFROM transaction_descriptors D LEFT JOIN clout_v1_3.chains C ON (C.name=''_CHAIN_NAME_'')\r\nWHERE D.id = ''_DESCRIPTOR_ID_'')\r\n\r\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(443, 'remove_matching_rules_due_to_chain', 'DELETE FROM `chain_match_rules` WHERE descriptor_id=''_DESCRIPTOR_ID_'' AND rule_type=''match'''),
(444, 'add_external_cron_job', 'INSERT INTO cron_external_schedule (user_id, job_code, job_string, scheduler, processer, repeat_code, job_type, date_entered) VALUES (''_USER_ID_'', ''_JOB_CODE_'', ''_JOB_STRING_'', ''_SCHEDULER_'', ''_PROCESSOR_'', ''_REPEAT_CODE_'', ''_JOB_TYPE_'', NOW())'),
(445, 'add_promotion_notice', 'INSERT INTO promotion_notices (_promotion_id, _user_id, _store_id, attend_status, status, date_entered, last_updated, _last_updated_by) \nVALUES \n(''_PROMOTION_ID_'', ''_USER_ID_'', ''_STORE_ID_'', ''_ATTEND_STATUS_'', ''_EVENT_STATUS_'', NOW(), NOW(), ''_USER_ID_'')\nON DUPLICATE KEY UPDATE \nattend_status=VALUES(attend_status), status=VALUES(status), last_updated=VALUES(last_updated), _last_updated_by=VALUES(_last_updated_by)'),
(446, 'get_list_of_events', 'SELECT E.*,  \nIFNULL((SELECT GROUP_CONCAT(rule_details SEPARATOR '', '') FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id),''NONE'') AS promotion_rules,\nIF((SELECT id FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id AND rule_type=''requires_scheduling'' LIMIT 1) IS NOT NULL,''Y'',''N'') AS requires_reservation,\nIFNULL((SELECT rule_amount FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id AND rule_type=''how_many_uses'' LIMIT 1),''unlimited'') AS usage_limit,\nIFNULL((SELECT SUM(number_in_party) FROM clout_v1_3.store_schedule WHERE _promotion_id=E.promotion_id AND reservation_status IN (''active'', ''confirmed'')), 0) AS usage_count,\n\nIF(clout_v1_3.is_date_this_week(E.start_date, ''N'') = ''Y'' OR DATE(NOW()) BETWEEN DATE(E.start_date) AND DATE(E.end_date), ''this_week'',\nIF(clout_v1_3.is_date_next_week(E.start_date) = ''Y'', ''next_week'',\n(SELECT MONTHNAME(E.start_date))\n)) AS date_category\n\nFROM \n(SELECT id AS promotion_id, id AS event_id, P.store_id, store_name, start_date, end_date, UNIX_TIMESTAMP(start_date) AS _start_date, UNIX_TIMESTAMP(end_date) AS _end_date, \n	clout_v1_3.get_distance(''_USER_LATITUDE_'', ''_USER_LONGITUDE_'', P.latitude, P.longitude) AS distance_from_store, P.name AS promotion_title, P.description AS promotion_details,\n	IFNULL((SELECT IF(attend_status = ''confirmed'',''yes'',\n		IF(attend_status = ''pending'',''maybe'',IF(attend_status = ''not_going'',''no'',''other''))) \n		FROM promotion_notices WHERE _promotion_id=P.id AND _user_id=''_USER_ID_'' LIMIT 1), ''unknown''\n	) AS attend_status\n\n	FROM clout_v1_3cron.cacheview__promotions_summary P\n    LEFT JOIN clout_v1_3cron.cacheview__store_score_by_store S ON (P.store_id=S.store_id AND user_id=''_USER_ID_'')\n	WHERE \n	_SEARCH_STRING_ \n        (S.total_score BETWEEN start_score AND end_score OR (S.total_score >= 1000 AND end_score = 1000)) \n        AND owner_type=''_OWNER_TYPE_'' AND promotion_type IN (''_PROMOTION_TYPES_'')\n        AND P.status = ''_STATUS_'' \n        \n	HAVING \n		distance_from_store <= _MAX_SEARCH_DISTANCE_ \n		AND user_qualifies_for_promotion(''_USER_ID_'', P.id) = ''Y''\n		AND (\n		(''_LIST_TYPE_'' = ''current'' AND (UNIX_TIMESTAMP(NOW()) BETWEEN UNIX_TIMESTAMP(start_date) AND UNIX_TIMESTAMP(end_date)))\n		OR\n		(''_LIST_TYPE_'' = ''passed'' AND (UNIX_TIMESTAMP(end_date) < UNIX_TIMESTAMP(NOW()) AND attend_status IN (''yes'',''maybe'') ))\n		OR \n		(''_LIST_TYPE_'' = ''going'' AND (UNIX_TIMESTAMP(NOW()) BETWEEN UNIX_TIMESTAMP(start_date) AND UNIX_TIMESTAMP(end_date) AND attend_status = ''yes'' )))\nORDER BY _start_date, distance_from_store\n\n_LIMIT_TEXT_) E'),
(447, 'get_event_attend_status_count', 'SELECT _promotion_id AS promotion_id, COUNT(DISTINCT _user_id) AS user_count \nFROM promotion_notices WHERE _promotion_id IN (''_PROMOTION_IDS_'')  AND attend_status=''_ATTEND_STATUS_'' \nGROUP BY _promotion_id'),
(448, 'get_plaid_category_matches', 'SELECT \nplaid_sub_category_id, \n_clout_sub_category_id AS system_sub_category_id, \n_clout_category_id AS system_category_id\n\nFROM plaid_category_matches \nWHERE plaid_sub_category_id IN (''_SUB_CATEGORY_IDS_'')'),
(449, 'batch_insert_transaction_categories', 'INSERT IGNORE INTO transaction_sub_categories (_user_id, _transaction_id, _category_id, _sub_category_id, is_processed)\n(SELECT A.* FROM (_INSERT_STRING_) A)'),
(450, 'get_transactions_to_process', 'SELECT id AS raw_id, _user_id AS user_id, _bank_id AS bank_id, LOWER(payee_name) AS descriptor, sub_category_id, place_type, amount, posted_date AS transaction_date, pending, available_date AS end_date, \nLOWER(address) AS address, LOWER(city) AS city, LOWER(state) AS state, zipcode, LOWER(CONCAT(address, '', '', city, '', '', state)) AS address_string \nFROM transactions_raw \nWHERE is_saved=''N'' _FILTER_CONDITION_'),
(451, 'batch_insert_transactions', 'INSERT IGNORE INTO transactions (id, transaction_type, _user_id, raw_store_name, `status`, amount, _raw_id, item_category, start_date, end_date, _bank_id, zipcode, state, city, address, match_status, _store_id, _chain_id, place_type)\n(SELECT A.* FROM (_INSERT_STRING_) A)'),
(452, 'add_chain_record_from_transaction', 'INSERT IGNORE INTO clout_v1_3.chains (name, address_line_1, city, state, zipcode, country, is_live, date_entered, _entered_by) \nVALUES (''_NAME_'', ''_ADDRESS_LINE_1_'', ''_CITY_'', ''_STATE_'', ''_ZIPCODE_'', ''_COUNTRY_'', ''_IS_LIVE_'', NOW(), ''1'')'),
(453, 'add_store_record_from_transaction', 'INSERT IGNORE INTO clout_v1_3.stores (_chain_id, name, online_only, status, address_line_1, city, state, zipcode, _country_code, date_entered, _entered_by, last_updated, _last_updated_by)\nVALUES \n(''_CHAIN_ID_'', ''_NAME_'', ''_ONLINE_ONLY_'', ''_STATUS_'', ''_ADDRESS_LINE_1_'', ''_CITY_'', ''_STATE_'', ''_ZIPCODE_'', ''_COUNTRY_'', NOW(), ''1'', NOW(), ''1'')\n'),
(454, 'run_matching_rule', 'SELECT A.id AS rule_id, A.match_chain_id AS chain_id, A.match_store_id AS store_id \nFROM\n(SELECT * FROM store_match_rule_patterns \nWHERE command=''_COMMAND_'' \nAND (\n(''_ADDRESS_'' = '''' AND ''_PLACE_TYPE_'' = ''digital'') \nOR \n(''_ADDRESS_'' <> '''' AND city_pattern = ''_CITY_'' AND ''_ADDRESS_'' LIKE address_pattern )\nOR \n(command=''reject'' AND address_pattern = '''')\n)\n\nAND (\n(''_COMMAND_''=''match'' AND MATCH(name_pattern) AGAINST (''_DESCRIPTOR_''))\nOR \n(''_COMMAND_''=''reject'' AND ''_DESCRIPTOR_'' LIKE name_pattern)\n)) A\n\nWHERE ''_DESCRIPTOR_'' LIKE name_pattern'),
(455, 'get_excluded_promotion_ids', 'SELECT _promotion_id AS promotion_id FROM promotion_notices WHERE _user_id = ''_USER_ID_'' AND attend_status = ''_ATTEND_STATUS_'';\r\n'),
(456, 'get_last_inserted_transaction', 'SELECT id AS transaction_id FROM transactions ORDER BY id DESC LIMIT 1'),
(457, 'get_chain_by_name', 'SELECT *, id AS chain_id FROM clout_v1_3.chains WHERE name=''_CHAIN_NAME_'''),
(458, 'get_store_by_details', 'SELECT id AS store_id, _chain_id AS chain_id, name, online_only, status, address_line_1, city, state, zipcode, _country_code AS country \r\nFROM clout_v1_3.stores WHERE MATCH(name) AGAINST (''_STORE_NAME_'') AND LOWER(address_line_1) = LOWER(''_ADDRESS_'') AND LOWER(city)=LOWER(''_CITY_'')'),
(459, 'batch_update_raw_transaction_field', 'UPDATE transactions_raw SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id IN (''_RAW_IDS_'')'),
(460, 'get_previous_attend_status', 'SELECT attend_status FROM promotion_notices WHERE _user_id = ''_USER_ID_'' AND _promotion_id = ''_PROMOTION_ID_'''),
(461, 'delete_reminder_messages', 'DELETE FROM clout_v1_3msg.message_exchange \nWHERE send_date = ''0000-00-00 00:00:00''\nAND _recipient_id = ''_USER_ID_''\nAND template_id IN (''_TEMPLATE_ID_'')\nAND subject like ''%_STORE_NAME_%'';\n'),
(462, 'get_store_name_by_id', 'SELECT name FROM clout_v1_3.stores S WHERE S.id = ''_STORE_ID_'''),
(463, 'call_update_sub_category_cache_and_frequency', 'CALL update_subcategory_cache_and_frequency(''_USER_ID_'', ''_SUB_CATEGORY_ID_'', ''_DATA_POINT_'',''_DATA_VALUE_'',''_NEW_CHECKBY_DATE_'',''_IS_RANKED_'')'),
(464, 'get_unprocessed_matched_sub_categories', 'SELECT DISTINCT _sub_category_id AS sub_category_id \nFROM transaction_sub_categories \nWHERE _user_id=''_USER_ID_'' AND is_processed=''N'''),
(465, 'set_did_category_survey', 'UPDATE datatable__store__STORE_ID__data SET did_my_category_survey_last90days = ''Y'', did_related_categories_survey_last90days=''Y'' WHERE user_id=''_USER_ID_'''),
(466, 'get_user_age_point_dates', 'SELECT * FROM datatable__user_data__age WHERE user_id=''_USER_ID_'''),
(467, 'get_store_age_point_dates', 'SELECT * FROM datatable__store__STORE_ID__data__age WHERE user_id=''_USER_ID_'''),
(468, 'get_subcategory_age_point_dates', 'SELECT * FROM datatable__subcategory__SUB_CATEGORY_ID__data__age WHERE user_id=''_USER_ID_'''),
(469, 'get_last_inserted_account_id', 'SELECT MAX(id) AS max_account_id FROM bank_accounts'),
(470, 'mark_raw_accounts_as_saved', 'UPDATE bank_accounts__ACCOUNT_TYPE__raw SET is_saved=''Y'', last_updated=NOW() WHERE id IN (''_RAW_IDS_'')'),
(471, 'batch_insert_accounts', 'INSERT IGNORE INTO bank_accounts (id, _user_id, account_type, account_id, account_number, _bank_id, issue_bank_name,  card_holder_full_name, \n account_nickname, currency_code, is_verified, status, last_sync_date)\n(SELECT A.* FROM (_INSERT_STRING_) A)'),
(472, 'get_event_details', 'SELECT E.*,  \nIFNULL((SELECT GROUP_CONCAT(rule_details SEPARATOR '', '') FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id),''NONE'') AS promotion_rules,\nIF((SELECT id FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id AND rule_type=''requires_scheduling'' LIMIT 1) IS NOT NULL,''Y'',''N'') AS requires_reservation,\nIF((SELECT id FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id AND rule_type=''requires_checkin'' LIMIT 1) IS NOT NULL,''Y'', ''N'') AS requires_checkin,\nIFNULL((SELECT rule_amount FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=E.promotion_id AND rule_type=''how_many_uses'' LIMIT 1),''unlimited'') AS usage_limit,\nIFNULL((SELECT SUM(number_in_party) FROM clout_v1_3.store_schedule WHERE _promotion_id=E.promotion_id AND reservation_status IN (''active'', ''confirmed'')), 0) AS usage_count,\n\nIF(clout_v1_3.is_date_this_week(E.start_date, ''N'') = ''Y'' OR DATE(NOW()) BETWEEN DATE(E.start_date) AND DATE(E.end_date), ''this_week'',\nIF(clout_v1_3.is_date_next_week(E.start_date) = ''Y'', ''next_week'',\n(SELECT MONTHNAME(E.start_date))\n)) AS date_category\n\nFROM \n(SELECT id AS promotion_id, id AS event_id, P.store_id, store_name, start_date, end_date, UNIX_TIMESTAMP(start_date) AS _start_date, UNIX_TIMESTAMP(end_date) AS _end_date, \n P.name AS promotion_title, P.description AS promotion_details,\n	IFNULL((SELECT IF(attend_status = ''confirmed'',''yes'',\n		IF(attend_status = ''pending'',''maybe'',IF(attend_status = ''not_going'',''no'',''other''))) \n		FROM promotion_notices WHERE _promotion_id=P.id AND _user_id=''_USER_ID_'' LIMIT 1), ''unknown''\n	) AS attend_status\n\n	FROM clout_v1_3cron.cacheview__promotions_summary P\n    LEFT JOIN clout_v1_3cron.cacheview__store_score_by_store S ON (P.store_id=S.store_id AND user_id=''_USER_ID_'')\n	WHERE P.id = ''_EVENT_ID_''\n) E'),
(473, 'batch_insert_raw_transactions', 'INSERT IGNORE INTO transactions_raw (transaction_id, transaction_type, currency_type,  institution_transaction_id, correct_institution_transaction_id, correct_action, server_transaction_id, check_number, reference_number, confirmation_number, payee_id, payee_name, extended_payee_name, memo, type, value_type, currency_rate, original_currency, posted_date, user_date, available_date, amount, running_balance_amount, pending, normalized_payee_name, merchant, sic, source, category_name, context_type, schedule_c, banking_transaction_type, subaccount_fund_type, banking_401k_source_type, principal_amount, interest_amount, escrow_total_amount, escrow_tax_amount, escrow_insurance_amount, escrow_pmi_amount, escrow_fees_amount, escrow_other_amount, last_update_date, latitude, longitude, zipcode, state, city, address, sub_category_id, contact_telephone, website, confidence_level, place_type, _user_id, _bank_id, api_account, new_user)\r\n\r\n(SELECT A.* FROM (_INSERT_STRING_) A)'),
(474, 'get_processed_account_balances', 'SELECT id AS account_id, \nIF(account_type = ''credit'', ''credit'',''cash'') AS account_type, \nIFNULL(IF(account_type = ''credit'', \n	(SELECT credit_available_amount FROM bank_accounts_credit_raw WHERE _user_id=''_USER_ID_'' AND account_id=B.account_id LIMIT 1), \n	(SELECT available_balance_amount FROM bank_accounts_other_raw WHERE _user_id=''_USER_ID_'' AND account_id=B.account_id LIMIT 1)),\n0) AS balance \nFROM bank_accounts B WHERE _user_id=''_USER_ID_'''),
(475, 'get_plaid_access_token_by_user_id', 'SELECT * FROM plaid_access_token WHERE access_token=''_ACCESS_TOKEN_'' AND _user_id=''_USER_ID_'' ORDER BY is_active DESC LIMIT 1'),
(476, 'mark_stores_as_reported', 'UPDATE cacheview__store_score_by_store SET is_reported=''Y'' WHERE user_id=''_USER_ID_'''),
(477, 'mark_stores_as_un_reported', 'UPDATE cacheview__store_score_by_store SET is_reported=''N'' WHERE user_id=''_USER_ID_'' AND store_id IN (''_STORE_IDS_'')'),
(478, 'mark_stores_as_processed', 'UPDATE transactions SET is_processed=''Y'' WHERE _user_id=''_USER_ID_'' AND _store_id IN (''_STORE_IDS_'')'),
(479, 'mark_sub_categories_as_processed', 'UPDATE transaction_sub_categories SET is_processed=''Y'' WHERE _user_id=''_USER_ID_'' AND _sub_category_id IN (''_SUB_CATEGORY_IDS_'') '),
(480, 'delete_reservation_record', 'DELETE FROM clout_v1_3.store_schedule WHERE _promotion_id = ''_PROMOTION_ID_'' AND _user_id = ''_USER_ID_'''),
(481, 'update_user_data_fields', 'UPDATE datatable__user_data SET _UPDATE_STRING_ WHERE user_id=''_USER_ID_'''),
(482, 'get_user_by_id_or_email', 'SELECT id AS user_id, email_address, first_name, last_name FROM clout_v1_3.users WHERE id = ''_USER_ID_'' OR email_address=''_USER_ID_'''),
(483, 'get_transactions_list_by_date', 'SELECT A.*, S.name AS store_name, \nCONCAT(S.address_line_1, '' '', S.address_line_2) AS store_address, S.city AS store_city, S.state AS store_state, S.zipcode AS store_zipcode, \nLOWER(S.website) AS store_website, IF(S.phone_number > 0, S.phone_number, '''') AS store_telephone, R.match_store_id AS rule_store_id, \nIFNULL((SELECT name FROM clout_v1_3.stores WHERE R.match_store_id > 0 AND id=R.match_store_id LIMIT 1), '''') AS rule_store_name, \nR.name_pattern AS rule_name_pattern, R.address_pattern AS rule_address_pattern, R.city_pattern AS rule_city_pattern, R.place_type AS rule_place_type \nFROM \n(SELECT T.id AS transaction_id, T.place_type, T.place_type AS raw_place_type, T.transaction_type, UNIX_TIMESTAMP(T.start_date) AS transaction_date, T.amount, T._user_id AS user_id, \nT.match_status, T.admin_confirmed, T._store_id AS store_id, T.raw_store_name AS raw_descriptor, T.address AS raw_address, T._rule_id AS rule_id, \nCONCAT(T.raw_store_name, '' | '', T.address, IF(LENGTH(T.address) > 0, '', '',''''), T.city, '' '', T.state, IF(LENGTH(T.zipcode) > 0, '', '',''''), T.zipcode) AS description, \nIF(T._store_id > 0, (SELECT CONCAT(S.name, '' | '', S.address_line_1, IF(LENGTH(S.address_line_1) > 0, '', '',''''), S.city, '' '', S.state, IF(LENGTH(S.zipcode) > 0, '', '',''''), S.zipcode) \n	FROM clout_v1_3.stores S WHERE S.id=T._store_id),'''') AS store_match,\nIFNULL((SELECT (SELECT name FROM clout_v1_3.categories_level_1 WHERE id=C._category_id LIMIT 1) FROM clout_v1_3cron.transaction_sub_categories C WHERE C._transaction_id=T.id LIMIT 1), '''') AS category\n\nFROM clout_v1_3cron.transactions T _PHRASE_CONDITION_ _ADMIN_CONDITION_ _BANK_CONDITION_ _STATUS_CONDITION_   \nORDER BY T.admin_confirmed, T.start_date DESC, FIELD(T.match_status, ''auto-matched-insert'', ''auto-matched-rule'', ''unqualified'')\n_LIMIT_TEXT_ \n) A\nLEFT JOIN clout_v1_3.stores S ON (A.store_id > 0 AND A.store_id=S.id)\nLEFT JOIN clout_v1_3cron.store_match_rule_patterns R ON (A.rule_id > 0 AND A.rule_id=R.id)'),
(484, 'get_transaction_match_category_list', 'SELECT C2._category_id AS level_1_id, \n(SELECT name FROM clout_v1_3.categories_level_1 WHERE id=C2._category_id LIMIT 1) AS level_1_name, \nIF((SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=''_TRANSACTION_ID_'' AND _category_id=C2._category_id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS is_selected_level_1,\nC2.id AS level_2_id, \nC2.name AS level_2_name, \nIF((SELECT id FROM clout_v1_3cron.transaction_sub_categories WHERE _transaction_id=''_TRANSACTION_ID_'' AND _sub_category_id=C2.id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS is_selected_level_2\n\nFROM clout_v1_3.categories_level_2 C2 \nWHERE C2.is_active = ''Y'' \nORDER BY level_1_id, level_2_id'),
(485, 'remove_transaction_sub_categories', 'DELETE FROM transaction_sub_categories WHERE _transaction_id=''_TRANSACTION_ID_'''),
(486, 'add_transaction_sub_categories', 'INSERT IGNORE INTO transaction_sub_categories ( _user_id, _transaction_id, _category_id, _sub_category_id, is_processed)\r\n(SELECT (SELECT _user_id FROM clout_v1_3cron.transactions WHERE id=''_TRANSACTION_ID_'' LIMIT 1) AS _user_id, \r\n''_TRANSACTION_ID_'' AS _transaction_id, \r\nC._category_id AS _category_id, \r\nC.id AS _sub_category_id, \r\n''N'' AS is_processed\r\nFROM clout_v1_3.categories_level_2 C WHERE id IN (''_SUB_CATEGORY_IDS_''))');

-- --------------------------------------------------------

--
-- Структура таблицы `score_criteria`
--

CREATE TABLE IF NOT EXISTS `score_criteria` (
  `id` bigint(20) NOT NULL,
  `code` varchar(100) NOT NULL,
  `description` varchar(300) NOT NULL,
  `criteria` varchar(100) NOT NULL,
  `low_range` int(11) NOT NULL,
  `high_range` int(11) NOT NULL,
  `days_to_expire` int(11) NOT NULL,
  `parameter_type` varchar(100) NOT NULL,
  `categories` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `score_criteria`
--

INSERT INTO `score_criteria` (`id`, `code`, `description`, `criteria`, `low_range`, `high_range`, `days_to_expire`, `parameter_type`, `categories`) VALUES
(1, 'facebook_connected', 'Is Facebook Connected', 'on_or_off', 0, 20, 0, '', 'clout'),
(2, 'email_verified', 'Is Email Verified', 'on_or_off', 0, 20, 0, '', 'clout'),
(3, 'mobile_verified', 'Is Mobile Verified', 'on_or_off', 0, 30, 0, '', 'clout'),
(4, 'profile_photo_added', 'Is Profile Photo Added', 'on_or_off', 0, 20, 0, '', 'clout'),
(5, 'bank_verified_and_active', 'Is Bank Account Verified and Active', 'on_or_off', 0, 20, 0, '', 'clout,store'),
(6, 'credit_verified_and_active', 'Is Credit Verified and Active', 'on_or_off', 0, 20, 0, '', 'clout,store'),
(7, 'location_services_activated', 'Are Location Services Activated', 'on_or_off', 0, 20, 0, '', 'clout'),
(8, 'push_notifications_activated', 'Are Push Notifications Activated', 'on_or_off', 0, 20, 0, '', 'clout'),
(9, 'first_payment_success', 'Has Got First Payment Success', 'on_or_off', 0, 20, 360, '', 'clout'),
(10, 'member_processed_payment_last7days', 'Member Processed Payment in Last 7 Days', 'on_or_off', 0, 20, 7, '', 'clout');

-- --------------------------------------------------------

--
-- Структура таблицы `score_levels`
--

CREATE TABLE IF NOT EXISTS `score_levels` (
  `id` bigint(20) NOT NULL,
  `level` int(11) NOT NULL,
  `low_end_score` varchar(10) NOT NULL,
  `high_end_score` varchar(10) NOT NULL,
  `color` varchar(100) NOT NULL,
  `account_type` varchar(100) NOT NULL,
  `commission` float NOT NULL,
  `processing_fee` float NOT NULL,
  `advert_fee` float NOT NULL,
  `transaction_fee` float NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `score_levels`
--

INSERT INTO `score_levels` (`id`, `level`, `low_end_score`, `high_end_score`, `color`, `account_type`, `commission`, `processing_fee`, `advert_fee`, `transaction_fee`) VALUES
(1, 0, '0', '99', 'CCCCCC', 'Guest', 0, 0, 0, 0),
(2, 1, '100', '199', '56D42B', 'New Member', 0.25, 0, 0, 0),
(3, 2, '200', '299', '18C93E', 'Active Member', 0.5, 0, 0, 0),
(4, 3, '300', '399', '0AC298', 'Preferred Member', 0.75, 0, 0, 0),
(5, 4, '400', '499', '03BFCD', 'VIP - Iron', 1, 0, 0, 0),
(6, 5, '500', '599', '2DA0D1', 'VIP - Bronze', 1.25, 0, 0, 0),
(7, 6, '600', '699', '6D76B5', 'VIP - Silver', 1.5, 0, 0, 0),
(8, 7, '700', '799', '8566AB', 'VIP - Gold', 1.75, 0, 0, 0),
(9, 8, '800', '899', '999999', 'VIP - Platinum', 2, 0, 0, 0),
(10, 9, '900', '999', '666666', 'VIP - Titanium', 2.25, 0, 0, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `score_tracking_clout`
--

CREATE TABLE IF NOT EXISTS `score_tracking_clout` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `score` float NOT NULL,
  `read_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `score_tracking_stores`
--

CREATE TABLE IF NOT EXISTS `score_tracking_stores` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `score` float NOT NULL,
  `read_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `store_match_patterns`
--

CREATE TABLE IF NOT EXISTS `store_match_patterns` (
  `id` bigint(20) NOT NULL,
  `command` enum('match','reject') NOT NULL DEFAULT 'match',
  `match_store_id` varchar(100) DEFAULT NULL,
  `name_pattern` varchar(100) DEFAULT NULL,
  `address_pattern` varchar(100) DEFAULT NULL,
  `city_pattern` varchar(100) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8336 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_match_patterns`
--

INSERT INTO `store_match_patterns` (`id`, `command`, `match_store_id`, `name_pattern`, `address_pattern`, `city_pattern`) VALUES
(8326, 'reject', '', '.* atm .* withdraw.*', '', ''),
(8327, 'reject', '', '.* atm .* fee.*', '', ''),
(8328, 'reject', '', '.*atm.*deposit.*', '', ''),
(8329, 'reject', '', '.* atm .* withdr.*', '', ''),
(8330, 'reject', '', '.* credit applied .*', '', ''),
(8331, 'reject', '', '.* credit card .*', '', ''),
(8332, 'reject', '', '.* credit via: .*', '', ''),
(8333, 'reject', '', '.*atm withdraw.*', '', ''),
(8334, 'reject', '', '.*card reversal', '', ''),
(8335, 'reject', '', '.*cash deposit.*', '', '');

-- --------------------------------------------------------

--
-- Структура таблицы `store_match_patterns_bk`
--

CREATE TABLE IF NOT EXISTS `store_match_patterns_bk` (
  `id` bigint(20) NOT NULL,
  `command` enum('match','reject') NOT NULL DEFAULT 'match',
  `match_store_id` varchar(100) DEFAULT NULL,
  `name_pattern` varchar(100) DEFAULT NULL,
  `address_pattern` varchar(100) DEFAULT NULL,
  `city_pattern` varchar(100) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_match_patterns_bk`
--

INSERT INTO `store_match_patterns_bk` (`id`, `command`, `match_store_id`, `name_pattern`, `address_pattern`, `city_pattern`) VALUES
(1, 'reject', '', '% atm % withdraw%', '', ''),
(2, 'reject', '', '% atm % fee%', '', ''),
(3, 'reject', '', '% atm % deposit%', '', ''),
(4, 'reject', '', '% atm withdr%', '', ''),
(5, 'reject', '', '% credit applied %', '', ''),
(6, 'reject', '', '% credit card %', '', ''),
(7, 'reject', '', '% credit via: %', '', ''),
(9, 'reject', '', '%card reversal', '', ''),
(10, 'reject', '', '%cash deposit%', '', ''),
(11, 'reject', '', '%check #%', '', '');

-- --------------------------------------------------------

--
-- Структура таблицы `store_match_rules`
--

CREATE TABLE IF NOT EXISTS `store_match_rules` (
  `id` bigint(20) NOT NULL,
  `rule_type` enum('match','reject') NOT NULL DEFAULT 'match',
  `confidence` float NOT NULL,
  `match_store_id` varchar(100) NOT NULL,
  `descriptor_id` bigint(20) NOT NULL,
  `details` varchar(600) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_match_rules`
--

INSERT INTO `store_match_rules` (`id`, `rule_type`, `confidence`, `match_store_id`, `descriptor_id`, `details`, `is_active`) VALUES
(0, 'match', 50, '', 0, 'Default search-match reference rule', 'Y'),
(1, 'match', 100, '', 0, 'Default admin match rule', 'Y'),
(2, 'match', 90, '', 0, 'Default system match rule', 'Y'),
(3, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%Check Deposit%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Check Deposit%''', 'Y'),
(5, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%Atm Withdraw%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%ATM Withdraw%''', 'Y'),
(6, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%Credit Card Payment%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Credit Card Payment%''', 'Y'),
(7, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%Cash Deposit%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Cash Deposit%''', 'Y'),
(8, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%ONLINE TRANSFER%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%ONLINE TRANSFER%''', 'Y'),
(9, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''%Interest Charge%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%Interest Charge%''', 'Y'),
(10, 'reject', 100, '', 0, '''_PAYEE_NAME_'' LIKE ''Check'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''Check'' ', 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `store_match_rule_patterns`
--

CREATE TABLE IF NOT EXISTS `store_match_rule_patterns` (
  `id` bigint(20) NOT NULL,
  `command` enum('match','reject') NOT NULL DEFAULT 'match',
  `match_chain_id` varchar(100) NOT NULL,
  `match_store_id` varchar(100) DEFAULT NULL,
  `name_pattern` varchar(100) DEFAULT NULL,
  `address_pattern` varchar(100) DEFAULT NULL,
  `city_pattern` varchar(100) DEFAULT NULL,
  `place_type` varchar(10) NOT NULL,
  `confidence` int(11) NOT NULL DEFAULT '100'
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_match_rule_patterns`
--

INSERT INTO `store_match_rule_patterns` (`id`, `command`, `match_chain_id`, `match_store_id`, `name_pattern`, `address_pattern`, `city_pattern`, `place_type`, `confidence`) VALUES
(1, 'reject', '', '', '%atm %withdraw%', '', '', '', 100),
(2, 'reject', '', '', '% atm % fee%', '', '', '', 100),
(3, 'reject', '', '', '% atm % deposit%', '', '', '', 100),
(4, 'reject', '', '', '% atm withdr%', '', '', '', 100),
(5, 'reject', '', '', '% credit applied %', '', '', '', 100),
(6, 'reject', '', '', '% credit card %', '', '', '', 100),
(7, 'reject', '', '', '% credit via: %', '', '', '', 100),
(9, 'reject', '', '', '%card reversal', '', '', '', 100),
(10, 'reject', '', '', '%cash deposit%', '', '', '', 100),
(11, 'reject', '', '', '%check #%', '', '', '', 100);

-- --------------------------------------------------------

--
-- Структура таблицы `store_match_rule_patterns_TEMP_PH`
--

CREATE TABLE IF NOT EXISTS `store_match_rule_patterns_TEMP_PH` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `command` enum('match','reject') NOT NULL DEFAULT 'match',
  `match_chain_id` varchar(100) NOT NULL,
  `match_store_id` varchar(100) DEFAULT NULL,
  `name_pattern` varchar(100) DEFAULT NULL,
  `address_pattern` varchar(100) DEFAULT NULL,
  `city_pattern` varchar(100) DEFAULT NULL,
  `place_type` varchar(10) NOT NULL,
  `confidence` int(11) NOT NULL DEFAULT '100'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_match_rule_patterns_TEMP_PH`
--

INSERT INTO `store_match_rule_patterns_TEMP_PH` (`id`, `command`, `match_chain_id`, `match_store_id`, `name_pattern`, `address_pattern`, `city_pattern`, `place_type`, `confidence`) VALUES
(1, 'reject', '', '', '%atm %withdraw%', '', '', '', 100),
(0, 'reject', '', NULL, '% deposit%', NULL, NULL, '', 100),
(0, 'reject', '', NULL, '% deposit%', NULL, NULL, '', 100),
(0, 'reject', '', NULL, '% deposit%', NULL, NULL, '', 100),
(0, 'reject', '', NULL, '% deposit%', NULL, NULL, '', 100),
(0, 'reject', '', NULL, '% deposit%', NULL, NULL, '', 100);

-- --------------------------------------------------------

--
-- Структура таблицы `store_schedule`
--

CREATE TABLE IF NOT EXISTS `store_schedule` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_promotion_id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `scheduler_name` varchar(300) NOT NULL,
  `scheduler_email` varchar(300) NOT NULL,
  `scheduler_phone` int(11) NOT NULL,
  `telephone_provider_id` bigint(20) NOT NULL,
  `phone_type` enum('Mobile','Home','Office') NOT NULL DEFAULT 'Mobile',
  `schedule_date` datetime NOT NULL,
  `number_in_party` int(11) NOT NULL,
  `special_request` varchar(500) NOT NULL,
  `is_schedule_used` enum('Y','N') NOT NULL DEFAULT 'N',
  `store_notes` varchar(500) NOT NULL,
  `is_email_sent` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_sms_sent` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_voice_sent` enum('Y','N') NOT NULL DEFAULT 'N',
  `reservation_status` enum('active','confirmed','cancelled','rejected') NOT NULL DEFAULT 'active',
  `status` enum('deleted','active','archived') NOT NULL DEFAULT 'active',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_schedule`
--

INSERT INTO `store_schedule` (`id`, `_store_id`, `_promotion_id`, `_user_id`, `scheduler_name`, `scheduler_email`, `scheduler_phone`, `telephone_provider_id`, `phone_type`, `schedule_date`, `number_in_party`, `special_request`, `is_schedule_used`, `store_notes`, `is_email_sent`, `is_sms_sent`, `is_voice_sent`, `reservation_status`, `status`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 8, 1, 'some name', 'bog@ram.ru', 345345354, 4, 'Mobile', '2016-09-01 01:03:06', 1, '', 'N', '', 'N', 'N', 'N', 'active', 'active', '2016-09-02 01:02:02', NULL, '2016-09-02 01:02:05', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `transactions`
--

CREATE TABLE IF NOT EXISTS `transactions` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions`
--

INSERT INTO `transactions` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 1, 1, 16881867, 11279, 'pending', 13.49, 29859, 'quaker state liquor', '2015-11-17 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90038', 'ca', 'los angeles', '6901 melrose ave', '19025004', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-insert', 'N'),
(2, 'buy', 1, 16365959, 16365959, 11279, 'pending', 9.85, 29860, 'susina bakery', '2016-11-17 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90036', 'ca', 'los angeles', '7122 beverly blvd', '13005000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-rule', 'N'),
(3, 'buy', 3, 16960494, 211337, 11279, 'pending', 28.36, 29861, 'shell', '2015-11-17 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90035', 'ca', 'los angeles', '8500 w pico blvd', '22009000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-insert', 'N'),
(4, 'buy', 4, 16960496, 14451214, 11279, 'pending', 3, 29862, 'hollywood juice bar', '2015-11-17 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90028', 'ca', 'los angeles', '7021  hollywood blvd', '13005000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-insert', 'N'),
(5, 'buy', 5, 8250262, 8250262, 11279, 'pending', 26.95, 29863, 'palm thai restaurant', '2015-11-17 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90028', 'ca', 'los angeles', '5900 hollywood blvd', '13005000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-rule', 'N'),
(6, 'buy', 6, 13536808, 5418, 11279, 'pending', 7.7, 29864, 'subway', '2015-11-16 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90035', 'ca', 'los angeles', '1270 s la cienega blvd', '13005000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-rule', 'N'),
(7, 'buy', 7, 16960498, 16880666, 11279, 'pending', 33.5, 29865, 'the corner hollywood', '2015-11-16 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '', 'ca', '', '', '', '', '', 0, 'unresolved', '', 'N', NULL, 'auto-matched-insert', 'N'),
(8, 'buy', 8, 13267924, 9683726, 11279, 'pending', 1.5, 29866, 'city center parking inc', '2015-11-16 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90007', 'ca', 'los angeles', '220 w 21st st', '22013000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-rule', 'N'),
(9, 'buy', 9, 16960500, 865282, 11279, 'pending', 42.62, 29867, 'republique', '2015-11-16 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90036', 'ca', 'los angeles', '624 la brea ave', '13005000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-insert', 'N'),
(10, 'buy', 10, 13267924, 9683726, 11279, 'pending', 1.5, 29868, 'city center parking inc', '2015-11-16 00:00:00', '2015-11-18 00:00:00', 0, 0, '', '', '90007', 'ca', 'los angeles', '220 w 21st st', '22013000', '', '', 0, 'place', '', 'N', NULL, 'auto-matched-rule', 'N');

--
-- Триггеры `transactions`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__transactions` AFTER INSERT ON `transactions`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.match_status <> 'unqualified' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_matched_amount=(total_matched_amount + NEW.amount), 
			total_matched_transactions=(total_matched_transactions+1)
		WHERE user_id=NEW._user_id;
	END IF;


	IF NEW.match_status = 'unqualified' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_unmatched_amount=(total_unmatched_amount + NEW.amount), 
			total_unmatched_transactions=(total_unmatched_transactions+1)
		WHERE user_id=NEW._user_id;
	END IF;

END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerupdate__transactions` AFTER UPDATE ON `transactions`
 FOR EACH ROW BEGIN

	-- get the previous network referral counts
	SELECT ad_spending_last180days, ad_spending_last360days, ad_spending_total, total_matched_amount, total_matched_transactions, 
		total_unmatched_amount, total_unmatched_transactions, total_matched_amount, total_matched_transactions 
	FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW._user_id 
	INTO @OLD_ad_spending_last180days, @OLD_ad_spending_last360days, @OLD_ad_spending_total, @OLD_total_matched_amount, @OLD_total_matched_transactions, 
		@OLD_total_unmatched_amount, @OLD_total_unmatched_transactions, @OLD_total_matched_amount, @OLD_total_matched_transactions;


	-- update user cache data
	IF NEW._related_promotion_id > 0 THEN
		UPDATE clout_v1_3cron.datatable__user_data SET ad_spending_last180days=(ad_spending_last180days + NEW.amount), 
			ad_spending_last360days=(ad_spending_last360days + NEW.amount), ad_spending_total=(ad_spending_total + NEW.amount)
		WHERE user_id=NEW._user_id;
	END IF;


	IF NEW.match_status <> 'unqualified' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_matched_amount=(total_matched_amount + NEW.amount), 
			total_matched_transactions=(total_matched_transactions+1)
		WHERE user_id=NEW._user_id;

		IF OLD.match_status = 'unqualified' THEN
			UPDATE clout_v1_3cron.datatable__user_data SET total_unmatched_amount=IF(total_unmatched_amount > NEW.amount, (total_unmatched_amount - NEW.amount), total_unmatched_amount),
				total_unmatched_transactions=IF(total_unmatched_transactions > 0, (total_unmatched_transactions - 1), total_unmatched_transactions)
			WHERE user_id=NEW._user_id;
		END IF;
	END IF;


	IF NEW.match_status = 'unqualified' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_unmatched_amount=(total_unmatched_amount + NEW.amount), 
			total_unmatched_transactions=(total_unmatched_transactions+1)
		WHERE user_id=NEW._user_id;

		IF OLD.match_status <> 'unqualified' THEN
			UPDATE clout_v1_3cron.datatable__user_data SET total_matched_amount=IF(total_matched_amount > NEW.amount, (total_matched_amount - NEW.amount), total_matched_amount), 
				total_matched_transactions=IF(total_matched_transactions > 0, (total_matched_transactions - 1), total_matched_transactions)
			WHERE user_id=NEW._user_id;
		END IF;
	END IF;


	-- get the new network referral counts
	SELECT ad_spending_last180days, ad_spending_last360days, ad_spending_total, total_matched_amount, total_matched_transactions, 
		total_unmatched_amount, total_unmatched_transactions, total_matched_amount, total_matched_transactions 
	FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW._user_id 
	INTO @NEW_ad_spending_last180days, @NEW_ad_spending_last360days, @NEW_ad_spending_total, @NEW_total_matched_amount, @NEW_total_matched_transactions, 
		@NEW_total_unmatched_amount, @NEW_total_unmatched_transactions, @NEW_total_matched_amount, @NEW_total_matched_transactions;

	IF @NEW_ad_spending_last180days <> @OLD_ad_spending_last180days THEN 
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_last180days SET frequency=(frequency - 1) WHERE data_value = round_up(@OLD_ad_spending_last180days, 5);
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_last180days SET frequency=(frequency + 1) WHERE data_value = round_up(@NEW_ad_spending_last180days, 5);
	END IF;

	IF @NEW_ad_spending_last360days <> @OLD_ad_spending_last360days THEN 
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_last360days SET frequency=(frequency - 1) WHERE data_value = round_up(@OLD_ad_spending_last360days, 5);
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_last360days SET frequency=(frequency + 1) WHERE data_value = round_up(@NEW_ad_spending_last360days, 5);
	END IF;

	IF @NEW_ad_spending_total <> @OLD_ad_spending_total THEN 
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_total SET frequency=(frequency - 1) WHERE data_value = round_up(@OLD_ad_spending_total, 5);
		UPDATE clout_v1_3cron.datatable__frequency_ad_spending_total SET frequency=(frequency + 1) WHERE data_value = round_up(@NEW_ad_spending_total, 5);
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_bk`
--

CREATE TABLE IF NOT EXISTS `transactions_bk` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=8173 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_bk`
--

INSERT INTO `transactions_bk` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(8163, 'buy', 1, NULL, NULL, 8502, 'complete', 194.27, 21799, 'DIRECTV', '2015-10-30 00:00:00', '2015-10-30 19:27:04', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8164, 'buy', 1, NULL, NULL, 8502, 'complete', 25.88, 21800, 'Eat 24', '2015-10-29 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', 'San Francisco', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8165, 'buy', 1, NULL, NULL, 8502, 'pending', 7, 21801, 'GITHUB.COM 2FBYI', '2015-10-29 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8166, 'buy', 1, NULL, NULL, 8502, 'pending', 25, 21802, 'GITHUB.COM 4CBKC', '2015-10-29 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8167, 'buy', 1, NULL, NULL, 8502, 'pending', 49.99, 21803, 'ADOBE *CREATIVE CLOUD', '2015-10-28 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8168, 'buy', 1, NULL, NULL, 8502, 'pending', 45.36, 21804, 'AT&amp;T', '2015-10-27 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', '', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8169, 'buy', 1, NULL, NULL, 8502, 'pending', 39.95, 21805, 'ROCKET LAWYER', '2015-10-26 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8170, 'buy', 1, NULL, NULL, 8502, 'pending', 31.17, 21806, 'Eat 24', '2015-10-26 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8171, 'buy', 1, NULL, NULL, 8502, 'pending', 38.61, 21807, 'Nic&#039;s Restaurant', '2015-10-26 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '90210', 'CA', 'Beverly Hills', '453 N Canon Dr', '', '', '', 0, '', '', 'N', NULL, '', 'N'),
(8172, 'buy', 1, NULL, NULL, 8502, 'pending', 151.1, 21808, 'Wally&#039;s Vinoteca', '2015-10-26 00:00:00', '2015-10-30 19:26:12', 0, 0, '', '', '90210', 'CA', 'Beverly Hills', '447 N Canon Dr', '', '', '', 0, '', '', 'N', NULL, '', 'N');

--
-- Триггеры `transactions_bk`
--
DELIMITER $$
CREATE TRIGGER `triggerdelete__transactions` AFTER DELETE ON `transactions_bk`
 FOR EACH ROW BEGIN
	
	
	CALL triggerproc__transactions_remove_store(OLD._user_id, OLD.amount, OLD.start_date, OLD._store_id);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_match_jobs`
--

CREATE TABLE IF NOT EXISTS `transactions_match_jobs` (
  `id` bigint(20) NOT NULL,
  `last_processed_key` bigint(20) NOT NULL,
  `last_cached_store_key` bigint(20) NOT NULL,
  `success` bigint(20) NOT NULL,
  `failed` bigint(20) NOT NULL,
  `rejected` bigint(20) NOT NULL,
  `matched` bigint(20) NOT NULL,
  `new_store` bigint(20) NOT NULL,
  `from_cache` bigint(20) NOT NULL,
  `last_processed_date` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_match_jobs`
--

INSERT INTO `transactions_match_jobs` (`id`, `last_processed_key`, `last_cached_store_key`, `success`, `failed`, `rejected`, `matched`, `new_store`, `from_cache`, `last_processed_date`, `created`) VALUES
(1, 0, 16910929, 0, 0, 0, 0, 0, 0, '2016-06-08 18:18:53', '2016-06-09 01:18:53'),
(2, 22782, 16910946, 999, 0, 168, 71, 0, 760, '2016-06-08 00:00:00', '2016-06-09 01:19:33');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_match_jobs_run1`
--

CREATE TABLE IF NOT EXISTS `transactions_match_jobs_run1` (
  `id` bigint(20) NOT NULL,
  `last_processed_key` bigint(20) NOT NULL,
  `last_cached_store_key` bigint(20) NOT NULL,
  `success` bigint(20) NOT NULL,
  `failed` bigint(20) NOT NULL,
  `rejected` bigint(20) NOT NULL,
  `matched` bigint(20) NOT NULL,
  `new_store` bigint(20) NOT NULL,
  `from_cache` bigint(20) NOT NULL,
  `last_processed_date` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_match_jobs_run1`
--

INSERT INTO `transactions_match_jobs_run1` (`id`, `last_processed_key`, `last_cached_store_key`, `success`, `failed`, `rejected`, `matched`, `new_store`, `from_cache`, `last_processed_date`, `created`) VALUES
(1, 182565, 16883967, 182565, 0, 23040, 11891, 25551, 86244, '2016-06-07 19:57:21', '2016-06-07 03:49:39');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_match_jobs_run2`
--

CREATE TABLE IF NOT EXISTS `transactions_match_jobs_run2` (
  `id` bigint(20) NOT NULL,
  `last_processed_key` bigint(20) NOT NULL,
  `last_cached_store_key` bigint(20) NOT NULL,
  `success` bigint(20) NOT NULL,
  `failed` bigint(20) NOT NULL,
  `rejected` bigint(20) NOT NULL,
  `matched` bigint(20) NOT NULL,
  `new_store` bigint(20) NOT NULL,
  `from_cache` bigint(20) NOT NULL,
  `last_processed_date` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_match_jobs_run2`
--

INSERT INTO `transactions_match_jobs_run2` (`id`, `last_processed_key`, `last_cached_store_key`, `success`, `failed`, `rejected`, `matched`, `new_store`, `from_cache`, `last_processed_date`, `created`) VALUES
(1, 0, 16883967, 0, 0, 0, 0, 0, 0, '2016-06-07 20:59:38', '2016-06-08 03:59:38'),
(2, 225543, 16909518, 182565, 0, 23040, 11891, 1411, 143351, '2016-06-07 00:00:00', '2016-06-08 04:58:20');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_match_jobs_run3`
--

CREATE TABLE IF NOT EXISTS `transactions_match_jobs_run3` (
  `id` bigint(20) NOT NULL,
  `last_processed_key` bigint(20) NOT NULL,
  `last_cached_store_key` bigint(20) NOT NULL,
  `success` bigint(20) NOT NULL,
  `failed` bigint(20) NOT NULL,
  `rejected` bigint(20) NOT NULL,
  `matched` bigint(20) NOT NULL,
  `new_store` bigint(20) NOT NULL,
  `from_cache` bigint(20) NOT NULL,
  `last_processed_date` datetime NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_match_jobs_run3`
--

INSERT INTO `transactions_match_jobs_run3` (`id`, `last_processed_key`, `last_cached_store_key`, `success`, `failed`, `rejected`, `matched`, `new_store`, `from_cache`, `last_processed_date`, `created`) VALUES
(1, 0, 16909518, 0, 0, 0, 0, 0, 0, '2016-06-07 22:30:40', '2016-06-08 05:30:40'),
(2, 225543, 16910929, 182564, 0, 23040, 11891, 0, 147633, '2016-06-07 00:00:00', '2016-06-08 05:49:59');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_raw`
--

CREATE TABLE IF NOT EXISTS `transactions_raw` (
  `id` bigint(20) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `transaction_type` varchar(100) NOT NULL,
  `currency_type` varchar(100) NOT NULL,
  `institution_transaction_id` varchar(100) NOT NULL,
  `correct_institution_transaction_id` varchar(100) NOT NULL,
  `correct_action` varchar(100) NOT NULL,
  `server_transaction_id` varchar(100) NOT NULL,
  `check_number` varchar(100) NOT NULL,
  `reference_number` varchar(100) NOT NULL,
  `confirmation_number` varchar(100) NOT NULL,
  `payee_id` varchar(100) NOT NULL,
  `payee_name` varchar(100) NOT NULL,
  `extended_payee_name` varchar(100) NOT NULL,
  `memo` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `value_type` varchar(100) NOT NULL,
  `currency_rate` varchar(100) NOT NULL,
  `original_currency` varchar(100) NOT NULL,
  `posted_date` datetime NOT NULL,
  `user_date` datetime NOT NULL,
  `available_date` datetime NOT NULL,
  `amount` decimal(20,4) NOT NULL,
  `running_balance_amount` decimal(20,4) NOT NULL,
  `pending` varchar(100) NOT NULL,
  `normalized_payee_name` varchar(100) NOT NULL,
  `merchant` varchar(100) NOT NULL,
  `sic` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `context_type` varchar(100) NOT NULL,
  `schedule_c` varchar(100) NOT NULL,
  `clout_transaction_id` varchar(100) NOT NULL,
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL,
  `zipcode` varchar(100) NOT NULL,
  `state` varchar(250) NOT NULL,
  `city` varchar(250) NOT NULL,
  `address` varchar(250) NOT NULL,
  `sub_category_id` varchar(100) NOT NULL,
  `contact_telephone` varchar(100) NOT NULL,
  `website` varchar(250) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `related_ad_id` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `api_account` varchar(100) NOT NULL,
  `banking_transaction_type` varchar(100) NOT NULL,
  `subaccount_fund_type` varchar(100) NOT NULL,
  `banking_401k_source_type` varchar(100) NOT NULL,
  `principal_amount` decimal(20,4) NOT NULL,
  `interest_amount` decimal(20,4) NOT NULL,
  `escrow_total_amount` decimal(20,4) NOT NULL,
  `escrow_tax_amount` decimal(20,4) NOT NULL,
  `escrow_insurance_amount` decimal(20,4) NOT NULL,
  `escrow_pmi_amount` decimal(20,4) NOT NULL,
  `escrow_fees_amount` decimal(20,4) NOT NULL,
  `escrow_other_amount` decimal(20,4) NOT NULL,
  `last_update_date` datetime NOT NULL,
  `new_user` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=29869 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_raw`
--

INSERT INTO `transactions_raw` (`id`, `transaction_id`, `transaction_type`, `currency_type`, `institution_transaction_id`, `correct_institution_transaction_id`, `correct_action`, `server_transaction_id`, `check_number`, `reference_number`, `confirmation_number`, `payee_id`, `payee_name`, `extended_payee_name`, `memo`, `type`, `value_type`, `currency_rate`, `original_currency`, `posted_date`, `user_date`, `available_date`, `amount`, `running_balance_amount`, `pending`, `normalized_payee_name`, `merchant`, `sic`, `source`, `category_name`, `context_type`, `schedule_c`, `clout_transaction_id`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `sub_category_id`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `related_ad_id`, `_user_id`, `_bank_id`, `api_account`, `banking_transaction_type`, `subaccount_fund_type`, `banking_401k_source_type`, `principal_amount`, `interest_amount`, `escrow_total_amount`, `escrow_tax_amount`, `escrow_insurance_amount`, `escrow_pmi_amount`, `escrow_fees_amount`, `escrow_other_amount`, `last_update_date`, `new_user`, `is_saved`, `is_active`, `is_processed`) VALUES
(29859, 'VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn-29859', 'banking', 'USD', 'PLAID-VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Quaker State Liquor', 'Quaker State Liquor', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '13.4900', '0.0000', 'true', 'Quaker State Liquor', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Shops:Food and Beverage Store:Beer, Wine and Spirits', '', '', '', '34.083872158114', '', '90038', 'CA', 'Los Angeles', '6901 Melrose Ave', '19025004', '', '', 0.5, 'place', '', 1, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29860, 'O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg-29860', 'banking', 'USD', 'PLAID-O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Susina Bakery', 'Susina Bakery', '', 'place', '', '1', '', '2015-12-17 00:00:00', '0000-00-00 00:00:00', '2015-12-18 17:16:02', '9.8500', '0.0000', 'true', 'Susina Bakery', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.075737', '', '90036', 'CA', 'Los Angeles', '7122 Beverly Blvd', '13005000', '', '', 0.5, 'place', '', 1, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29861, 'MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175-29861', 'banking', 'USD', 'PLAID-MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Shell', 'Shell', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '28.3600', '0.0000', 'true', 'Shell', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Gas Stations', '', '', '', '34.053445', '', '90035', 'CA', 'Los Angeles', '8500 W Pico Blvd', '22009000', '', '', 1, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29862, 'EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ-29862', 'banking', 'USD', 'PLAID-EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Hollywood Juice Bar', 'Hollywood Juice Bar', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '3.0000', '0.0000', 'true', 'Hollywood Juice Bar', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.102108', '', '90028', 'CA', 'Los Angeles', '7021  Hollywood Blvd', '13005000', '', '', 1, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29863, 'RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd-29863', 'banking', 'USD', 'PLAID-RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Palm Thai Restaurant', 'Palm Thai Restaurant', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '26.9500', '0.0000', 'true', 'Palm Thai Restaurant', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.10128', '', '90028', 'CA', 'Los Angeles', '5900 Hollywood Blvd', '13005000', '', '', 1, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29864, 'QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J-29864', 'banking', 'USD', 'PLAID-QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Subway', 'Subway', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '7.7000', '0.0000', 'true', 'Subway', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.054538', '', '90035', 'CA', 'Los Angeles', '1270 S La Cienega Blvd', '13005000', '', '', 1, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29865, 'n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN-29865', 'banking', 'USD', 'PLAID-n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'THE CORNER HOLLYWOOD', 'THE CORNER HOLLYWOOD', '', 'unresolved', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '33.5000', '0.0000', 'true', 'THE CORNER HOLLYWOOD', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', '', '', '', '', '', '', '', 'CA', '', '', '', '', '', 0.2, 'unresolved', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29866, 'pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6-29866', 'banking', 'USD', 'PLAID-pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29867, 'XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK-29867', 'banking', 'USD', 'PLAID-XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Republique', 'Republique', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '42.6200', '0.0000', 'true', 'Republique', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.064152', '', '90036', 'CA', 'Los Angeles', '624 La Brea Ave', '13005000', '', '', 1, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29868, 'ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0-29868', 'banking', 'USD', 'PLAID-ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 12, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N');

--
-- Триггеры `transactions_raw`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__transactions_raw` AFTER INSERT ON `transactions_raw`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET last_transaction_import_date=NEW.last_update_date, last_transaction_date=NEW.posted_date WHERE user_id=NEW._user_id;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_raw_TEMP_AZ`
--

CREATE TABLE IF NOT EXISTS `transactions_raw_TEMP_AZ` (
  `id` bigint(20) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `transaction_type` varchar(100) NOT NULL,
  `currency_type` varchar(100) NOT NULL,
  `institution_transaction_id` varchar(100) NOT NULL,
  `correct_institution_transaction_id` varchar(100) NOT NULL,
  `correct_action` varchar(100) NOT NULL,
  `server_transaction_id` varchar(100) NOT NULL,
  `check_number` varchar(100) NOT NULL,
  `reference_number` varchar(100) NOT NULL,
  `confirmation_number` varchar(100) NOT NULL,
  `payee_id` varchar(100) NOT NULL,
  `payee_name` varchar(100) NOT NULL,
  `extended_payee_name` varchar(100) NOT NULL,
  `memo` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `value_type` varchar(100) NOT NULL,
  `currency_rate` varchar(100) NOT NULL,
  `original_currency` varchar(100) NOT NULL,
  `posted_date` datetime NOT NULL,
  `user_date` datetime NOT NULL,
  `available_date` datetime NOT NULL,
  `amount` decimal(20,4) NOT NULL,
  `running_balance_amount` decimal(20,4) NOT NULL,
  `pending` varchar(100) NOT NULL,
  `normalized_payee_name` varchar(100) NOT NULL,
  `merchant` varchar(100) NOT NULL,
  `sic` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `context_type` varchar(100) NOT NULL,
  `schedule_c` varchar(100) NOT NULL,
  `clout_transaction_id` varchar(100) NOT NULL,
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL,
  `zipcode` varchar(100) NOT NULL,
  `state` varchar(250) NOT NULL,
  `city` varchar(250) NOT NULL,
  `address` varchar(250) NOT NULL,
  `sub_category_id` varchar(100) NOT NULL,
  `contact_telephone` varchar(100) NOT NULL,
  `website` varchar(250) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `related_ad_id` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `api_account` varchar(100) NOT NULL,
  `banking_transaction_type` varchar(100) NOT NULL,
  `subaccount_fund_type` varchar(100) NOT NULL,
  `banking_401k_source_type` varchar(100) NOT NULL,
  `principal_amount` decimal(20,4) NOT NULL,
  `interest_amount` decimal(20,4) NOT NULL,
  `escrow_total_amount` decimal(20,4) NOT NULL,
  `escrow_tax_amount` decimal(20,4) NOT NULL,
  `escrow_insurance_amount` decimal(20,4) NOT NULL,
  `escrow_pmi_amount` decimal(20,4) NOT NULL,
  `escrow_fees_amount` decimal(20,4) NOT NULL,
  `escrow_other_amount` decimal(20,4) NOT NULL,
  `last_update_date` datetime NOT NULL,
  `new_user` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=29869 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_raw_TEMP_AZ`
--

INSERT INTO `transactions_raw_TEMP_AZ` (`id`, `transaction_id`, `transaction_type`, `currency_type`, `institution_transaction_id`, `correct_institution_transaction_id`, `correct_action`, `server_transaction_id`, `check_number`, `reference_number`, `confirmation_number`, `payee_id`, `payee_name`, `extended_payee_name`, `memo`, `type`, `value_type`, `currency_rate`, `original_currency`, `posted_date`, `user_date`, `available_date`, `amount`, `running_balance_amount`, `pending`, `normalized_payee_name`, `merchant`, `sic`, `source`, `category_name`, `context_type`, `schedule_c`, `clout_transaction_id`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `sub_category_id`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `related_ad_id`, `_user_id`, `_bank_id`, `api_account`, `banking_transaction_type`, `subaccount_fund_type`, `banking_401k_source_type`, `principal_amount`, `interest_amount`, `escrow_total_amount`, `escrow_tax_amount`, `escrow_insurance_amount`, `escrow_pmi_amount`, `escrow_fees_amount`, `escrow_other_amount`, `last_update_date`, `new_user`, `is_saved`, `is_active`, `is_processed`) VALUES
(29859, 'VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn-29859', 'banking', 'USD', 'PLAID-VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Quaker State Liquor', 'Quaker State Liquor', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '13.4900', '0.0000', 'true', 'Quaker State Liquor', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Shops:Food and Beverage Store:Beer, Wine and Spirits', '', '', '', '34.083872158114', '', '90038', 'CA', 'Los Angeles', '6901 Melrose Ave', '19025004', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29860, 'O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg-29860', 'banking', 'USD', 'PLAID-O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Susina Bakery', 'Susina Bakery', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '9.8500', '0.0000', 'true', 'Susina Bakery', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.075737', '', '90036', 'CA', 'Los Angeles', '7122 Beverly Blvd', '13005000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29861, 'MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175-29861', 'banking', 'USD', 'PLAID-MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Shell', 'Shell', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '28.3600', '0.0000', 'true', 'Shell', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Gas Stations', '', '', '', '34.053445', '', '90035', 'CA', 'Los Angeles', '8500 W Pico Blvd', '22009000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29862, 'EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ-29862', 'banking', 'USD', 'PLAID-EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Hollywood Juice Bar', 'Hollywood Juice Bar', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '3.0000', '0.0000', 'true', 'Hollywood Juice Bar', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.102108', '', '90028', 'CA', 'Los Angeles', '7021  Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29863, 'RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd-29863', 'banking', 'USD', 'PLAID-RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Palm Thai Restaurant', 'Palm Thai Restaurant', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '26.9500', '0.0000', 'true', 'Palm Thai Restaurant', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.10128', '', '90028', 'CA', 'Los Angeles', '5900 Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29864, 'QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J-29864', 'banking', 'USD', 'PLAID-QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Subway', 'Subway', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '7.7000', '0.0000', 'true', 'Subway', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.054538', '', '90035', 'CA', 'Los Angeles', '1270 S La Cienega Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29865, 'n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN-29865', 'banking', 'USD', 'PLAID-n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'THE CORNER HOLLYWOOD', 'THE CORNER HOLLYWOOD', '', 'unresolved', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '33.5000', '0.0000', 'true', 'THE CORNER HOLLYWOOD', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', '', '', '', '', '', '', '', 'CA', '', '', '', '', '', 0.2, 'unresolved', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29866, 'pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6-29866', 'banking', 'USD', 'PLAID-pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29867, 'XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK-29867', 'banking', 'USD', 'PLAID-XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Republique', 'Republique', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '42.6200', '0.0000', 'true', 'Republique', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.064152', '', '90036', 'CA', 'Los Angeles', '624 La Brea Ave', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29868, 'ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0-29868', 'banking', 'USD', 'PLAID-ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_raw_TEMP_KU`
--

CREATE TABLE IF NOT EXISTS `transactions_raw_TEMP_KU` (
  `id` bigint(20) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `transaction_type` varchar(100) NOT NULL,
  `currency_type` varchar(100) NOT NULL,
  `institution_transaction_id` varchar(100) NOT NULL,
  `correct_institution_transaction_id` varchar(100) NOT NULL,
  `correct_action` varchar(100) NOT NULL,
  `server_transaction_id` varchar(100) NOT NULL,
  `check_number` varchar(100) NOT NULL,
  `reference_number` varchar(100) NOT NULL,
  `confirmation_number` varchar(100) NOT NULL,
  `payee_id` varchar(100) NOT NULL,
  `payee_name` varchar(100) NOT NULL,
  `extended_payee_name` varchar(100) NOT NULL,
  `memo` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `value_type` varchar(100) NOT NULL,
  `currency_rate` varchar(100) NOT NULL,
  `original_currency` varchar(100) NOT NULL,
  `posted_date` datetime NOT NULL,
  `user_date` datetime NOT NULL,
  `available_date` datetime NOT NULL,
  `amount` decimal(20,4) NOT NULL,
  `running_balance_amount` decimal(20,4) NOT NULL,
  `pending` varchar(100) NOT NULL,
  `normalized_payee_name` varchar(100) NOT NULL,
  `merchant` varchar(100) NOT NULL,
  `sic` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `context_type` varchar(100) NOT NULL,
  `schedule_c` varchar(100) NOT NULL,
  `clout_transaction_id` varchar(100) NOT NULL,
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL,
  `zipcode` varchar(100) NOT NULL,
  `state` varchar(250) NOT NULL,
  `city` varchar(250) NOT NULL,
  `address` varchar(250) NOT NULL,
  `sub_category_id` varchar(100) NOT NULL,
  `contact_telephone` varchar(100) NOT NULL,
  `website` varchar(250) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `related_ad_id` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `api_account` varchar(100) NOT NULL,
  `banking_transaction_type` varchar(100) NOT NULL,
  `subaccount_fund_type` varchar(100) NOT NULL,
  `banking_401k_source_type` varchar(100) NOT NULL,
  `principal_amount` decimal(20,4) NOT NULL,
  `interest_amount` decimal(20,4) NOT NULL,
  `escrow_total_amount` decimal(20,4) NOT NULL,
  `escrow_tax_amount` decimal(20,4) NOT NULL,
  `escrow_insurance_amount` decimal(20,4) NOT NULL,
  `escrow_pmi_amount` decimal(20,4) NOT NULL,
  `escrow_fees_amount` decimal(20,4) NOT NULL,
  `escrow_other_amount` decimal(20,4) NOT NULL,
  `last_update_date` datetime NOT NULL,
  `new_user` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=29869 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_raw_TEMP_KU`
--

INSERT INTO `transactions_raw_TEMP_KU` (`id`, `transaction_id`, `transaction_type`, `currency_type`, `institution_transaction_id`, `correct_institution_transaction_id`, `correct_action`, `server_transaction_id`, `check_number`, `reference_number`, `confirmation_number`, `payee_id`, `payee_name`, `extended_payee_name`, `memo`, `type`, `value_type`, `currency_rate`, `original_currency`, `posted_date`, `user_date`, `available_date`, `amount`, `running_balance_amount`, `pending`, `normalized_payee_name`, `merchant`, `sic`, `source`, `category_name`, `context_type`, `schedule_c`, `clout_transaction_id`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `sub_category_id`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `related_ad_id`, `_user_id`, `_bank_id`, `api_account`, `banking_transaction_type`, `subaccount_fund_type`, `banking_401k_source_type`, `principal_amount`, `interest_amount`, `escrow_total_amount`, `escrow_tax_amount`, `escrow_insurance_amount`, `escrow_pmi_amount`, `escrow_fees_amount`, `escrow_other_amount`, `last_update_date`, `new_user`, `is_saved`, `is_active`, `is_processed`) VALUES
(29859, 'VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn-29859', 'banking', 'USD', 'PLAID-VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Quaker State Liquor', 'Quaker State Liquor', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '13.4900', '0.0000', 'true', 'Quaker State Liquor', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Shops:Food and Beverage Store:Beer, Wine and Spirits', '', '', '', '34.083872158114', '', '90038', 'CA', 'Los Angeles', '6901 Melrose Ave', '19025004', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29860, 'O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg-29860', 'banking', 'USD', 'PLAID-O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Susina Bakery', 'Susina Bakery', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '9.8500', '0.0000', 'true', 'Susina Bakery', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.075737', '', '90036', 'CA', 'Los Angeles', '7122 Beverly Blvd', '13005000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'Y', 'Y', 'N'),
(29861, 'MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175-29861', 'banking', 'USD', 'PLAID-MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Shell', 'Shell', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '28.3600', '0.0000', 'true', 'Shell', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Gas Stations', '', '', '', '34.053445', '', '90035', 'CA', 'Los Angeles', '8500 W Pico Blvd', '22009000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29862, 'EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ-29862', 'banking', 'USD', 'PLAID-EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Hollywood Juice Bar', 'Hollywood Juice Bar', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '3.0000', '0.0000', 'true', 'Hollywood Juice Bar', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.102108', '', '90028', 'CA', 'Los Angeles', '7021  Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29863, 'RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd-29863', 'banking', 'USD', 'PLAID-RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Palm Thai Restaurant', 'Palm Thai Restaurant', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '26.9500', '0.0000', 'true', 'Palm Thai Restaurant', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.10128', '', '90028', 'CA', 'Los Angeles', '5900 Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29864, 'QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J-29864', 'banking', 'USD', 'PLAID-QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Subway', 'Subway', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '7.7000', '0.0000', 'true', 'Subway', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.054538', '', '90035', 'CA', 'Los Angeles', '1270 S La Cienega Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29865, 'n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN-29865', 'banking', 'USD', 'PLAID-n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'THE CORNER HOLLYWOOD', 'THE CORNER HOLLYWOOD', '', 'unresolved', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '33.5000', '0.0000', 'true', 'THE CORNER HOLLYWOOD', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', '', '', '', '', '', '', '', 'CA', '', '', '', '', '', 0.2, 'unresolved', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29866, 'pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6-29866', 'banking', 'USD', 'PLAID-pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29867, 'XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK-29867', 'banking', 'USD', 'PLAID-XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Republique', 'Republique', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '42.6200', '0.0000', 'true', 'Republique', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.064152', '', '90036', 'CA', 'Los Angeles', '624 La Brea Ave', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N'),
(29868, 'ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0-29868', 'banking', 'USD', 'PLAID-ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'N', 'N', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_raw_TEMP_KU2`
--

CREATE TABLE IF NOT EXISTS `transactions_raw_TEMP_KU2` (
  `id` bigint(20) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `transaction_type` varchar(100) NOT NULL,
  `currency_type` varchar(100) NOT NULL,
  `institution_transaction_id` varchar(100) NOT NULL,
  `correct_institution_transaction_id` varchar(100) NOT NULL,
  `correct_action` varchar(100) NOT NULL,
  `server_transaction_id` varchar(100) NOT NULL,
  `check_number` varchar(100) NOT NULL,
  `reference_number` varchar(100) NOT NULL,
  `confirmation_number` varchar(100) NOT NULL,
  `payee_id` varchar(100) NOT NULL,
  `payee_name` varchar(100) NOT NULL,
  `extended_payee_name` varchar(100) NOT NULL,
  `memo` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL,
  `value_type` varchar(100) NOT NULL,
  `currency_rate` varchar(100) NOT NULL,
  `original_currency` varchar(100) NOT NULL,
  `posted_date` datetime NOT NULL,
  `user_date` datetime NOT NULL,
  `available_date` datetime NOT NULL,
  `amount` decimal(20,4) NOT NULL,
  `running_balance_amount` decimal(20,4) NOT NULL,
  `pending` varchar(100) NOT NULL,
  `normalized_payee_name` varchar(100) NOT NULL,
  `merchant` varchar(100) NOT NULL,
  `sic` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `category_name` varchar(100) NOT NULL,
  `context_type` varchar(100) NOT NULL,
  `schedule_c` varchar(100) NOT NULL,
  `clout_transaction_id` varchar(100) NOT NULL,
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL,
  `zipcode` varchar(100) NOT NULL,
  `state` varchar(250) NOT NULL,
  `city` varchar(250) NOT NULL,
  `address` varchar(250) NOT NULL,
  `sub_category_id` varchar(100) NOT NULL,
  `contact_telephone` varchar(100) NOT NULL,
  `website` varchar(250) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `related_ad_id` varchar(100) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `api_account` varchar(100) NOT NULL,
  `banking_transaction_type` varchar(100) NOT NULL,
  `subaccount_fund_type` varchar(100) NOT NULL,
  `banking_401k_source_type` varchar(100) NOT NULL,
  `principal_amount` decimal(20,4) NOT NULL,
  `interest_amount` decimal(20,4) NOT NULL,
  `escrow_total_amount` decimal(20,4) NOT NULL,
  `escrow_tax_amount` decimal(20,4) NOT NULL,
  `escrow_insurance_amount` decimal(20,4) NOT NULL,
  `escrow_pmi_amount` decimal(20,4) NOT NULL,
  `escrow_fees_amount` decimal(20,4) NOT NULL,
  `escrow_other_amount` decimal(20,4) NOT NULL,
  `last_update_date` datetime NOT NULL,
  `new_user` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=21793 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_raw_TEMP_KU2`
--

INSERT INTO `transactions_raw_TEMP_KU2` (`id`, `transaction_id`, `transaction_type`, `currency_type`, `institution_transaction_id`, `correct_institution_transaction_id`, `correct_action`, `server_transaction_id`, `check_number`, `reference_number`, `confirmation_number`, `payee_id`, `payee_name`, `extended_payee_name`, `memo`, `type`, `value_type`, `currency_rate`, `original_currency`, `posted_date`, `user_date`, `available_date`, `amount`, `running_balance_amount`, `pending`, `normalized_payee_name`, `merchant`, `sic`, `source`, `category_name`, `context_type`, `schedule_c`, `clout_transaction_id`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `sub_category_id`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `related_ad_id`, `_user_id`, `_bank_id`, `api_account`, `banking_transaction_type`, `subaccount_fund_type`, `banking_401k_source_type`, `principal_amount`, `interest_amount`, `escrow_total_amount`, `escrow_tax_amount`, `escrow_insurance_amount`, `escrow_pmi_amount`, `escrow_fees_amount`, `escrow_other_amount`, `last_update_date`, `new_user`, `is_saved`, `is_active`, `is_processed`) VALUES
(21783, '0AZ0De04KqsreDgVwM1RSRYjyd8yXxSDQ8Zxn', 'banking', 'USD', 'PLAID-0AZ0De04KqsreDgVwM1RSRYjyd8yXxSDQ8Zxn', '', '', '', '', '', '', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', 'ATM Withdrawal', 'ATM Withdrawal', '', 'special', '', '1', '', '2014-07-21 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '200.0000', '0.0000', 'true', 'ATM Withdrawal', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '', 'plaid', 'Transfer:Withdrawal:ATM', '', '', '', '', '', '', 'CA', 'San Francisco', '', '21012002', '', '', 1, 'special', '', 61, 8502, 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21784, '3mg4qV4JZycjewvKEzrLTYMzdr1MmvcO4Z3zX', 'banking', 'USD', 'PLAID-3mg4qV4JZycjewvKEzrLTYMzdr1MmvcO4Z3zX', '', '', '', '', '', '', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', 'Online Transfer from External Sav ...3092', 'Online Transfer from External Sav ...3092', '', 'special', '', '1', '', '2014-07-24 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '240.0000', '0.0000', 'true', 'Online Transfer from External Sav ...3092', 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '', 'plaid', 'Transfer:Account Transfer', '', '', '', '', '', '', '', '', '', '21001000', '', '', 1, 'special', '', 61, 8502, 'XARE85EJqKsjxLp6XR8ocg8VakrkXpTXmRdOo', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21785, 'KdDjmojBERUKx3JkDdO5IaRJdZeZKNuK4bnKJ1', 'banking', 'USD', 'PLAID-KdDjmojBERUKx3JkDdO5IaRJdZeZKNuK4bnKJ1', '', '', '', '', '', '', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 'Apple Store', 'Apple Store', '', 'place', '', '1', '', '2014-06-23 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '2307.1500', '0.0000', 'true', 'Apple Store', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '', 'plaid', 'Shops:Computers and Electronics', '', '', '', '', '', '', 'CA', 'San Francisco', '1 Stockton St', '19013000', '', '', 0.2, 'place', '', 61, 8502, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21786, 'DAE3Yo3wXgskjXV1JqBDIrDBVvjMLDCQ4rMQdR', 'banking', 'USD', 'PLAID-DAE3Yo3wXgskjXV1JqBDIrDBVvjMLDCQ4rMQdR', '', '', '', '', '', '', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 'Gregorys Coffee', 'Gregorys Coffee', '', 'place', '', '1', '', '2014-06-21 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '3.1900', '0.0000', 'true', 'Gregorys Coffee', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', 'plaid', 'Food and Drink:Restaurants:Coffee Shop', '', '', '', '', '', '', 'NY', 'New York', '874 Avenue of the Americas', '13005043', '', '', 0.2, 'place', '', 61, 8502, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21787, '1vAj1Eja5BIn4R7V6Mp1hBPQgkryZRHryZ0rDY', 'banking', 'USD', 'PLAID-1vAj1Eja5BIn4R7V6Mp1hBPQgkryZRHryZ0rDY', '', '', '', '', '', '', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 'ATM Withdrawal', 'ATM Withdrawal', '', 'special', '', '1', '', '2014-06-08 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '80.0000', '0.0000', 'true', 'ATM Withdrawal', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', 'plaid', 'Transfer:Withdrawal:ATM', '', '', '', '', '', '', 'CA', 'San Francisco', '', '21012002', '', '', 1, 'special', '', 61, 8502, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21788, 'zq7MLAM4N3cjeKvXP9YqtBJXvZeajJCkjQakYv', 'banking', 'USD', 'PLAID-zq7MLAM4N3cjeKvXP9YqtBJXvZeajJCkjQakYv', '', '', '', '', '', '', 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', 'Online Transfer from Chk ...1702', 'Online Transfer from Chk ...1702', '', 'special', '', '1', '', '2014-06-02 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '-240.0000', '0.0000', 'true', 'Online Transfer from Chk ...1702', 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', '', 'plaid', 'Transfer:Account Transfer', '', '', '', '', '', '', '', '', '', '21001000', '', '', 1, 'special', '', 61, 8502, 'QPO8Jo8vdDHMepg41PBwckXm4KdK1yUdmXOwK', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21789, '96d5AO5gLjC9EowVyn5OCBRjJR9LaOHJnBVJzd', 'banking', 'USD', 'PLAID-96d5AO5gLjC9EowVyn5OCBRjJR9LaOHJnBVJzd', '', '', '', '', '', '', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 'Online Transfer to Sav ...9606', 'Online Transfer to Sav ...9606', '', 'special', '', '1', '', '2014-06-01 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '240.0000', '0.0000', 'true', 'Online Transfer to Sav ...9606', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', 'plaid', 'Transfer:Account Transfer', '', '', '', '', '', '', '', '', '', '21001000', '', '', 1, 'special', '', 61, 8502, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21790, 'VK0EQ5Ea13u9Qwzm6nA8CNaze8gdJoCJvx6JDO', 'banking', 'USD', 'PLAID-VK0EQ5Ea13u9Qwzm6nA8CNaze8gdJoCJvx6JDO', '', '', '', '', '', '', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 'Interest Payment', 'Interest Payment', '', 'unresolved', '', '1', '', '2014-05-17 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '-0.9300', '0.0000', 'true', 'Interest Payment', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', 'plaid', 'Interest', '', '', '', '', '', '', '', '', '', '15000000', '', '', 0.2, 'unresolved', '', 61, 8502, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21791, 'aJPEm5EVqxF6yk8K5nPeFbDpnPR57wI3xMR3pP', 'banking', 'USD', 'PLAID-aJPEm5EVqxF6yk8K5nPeFbDpnPR57wI3xMR3pP', '', '', '', '', '', '', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', 'Golden Crepes', 'Golden Crepes', '', 'place', '', '1', '', '2014-05-12 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '12.7400', '0.0000', 'true', 'Golden Crepes', 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '', 'plaid', '', '', '', '', '40.740352', '', '', 'NY', 'New York', '262 W 15th St', '', '', '', 0.2, 'place', '', 61, 8502, 'pJPM4LMBNQFrOwp0jqEyTwyxJQrQbgU6kq37k', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N'),
(21792, 'moPE4dE1yMHJX5pmRzwrcvpQqPdDnZHEKPREYL', 'banking', 'USD', 'PLAID-moPE4dE1yMHJX5pmRzwrcvpQqPdDnZHEKPREYL', '', '', '', '', '', '', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', 'Krankies Coffee', 'Krankies Coffee', '', 'place', '', '1', '', '2014-05-09 00:00:00', '0000-00-00 00:00:00', '2015-10-30 14:35:02', '7.2300', '0.0000', 'true', 'Krankies Coffee', 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', 'plaid', 'Food and Drink:Restaurants:Coffee Shop', '', '', '', '', '', '', 'NC', 'Winston Salem', '211 E 3rd St', '13005043', '', '', 0.2, 'place', '', 61, 8502, 'nban4wnPKEtnmEpaKzbYFYQvA7D7pnCaeDBMy', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-10-30 14:35:02', 'N', 'N', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_run1`
--

CREATE TABLE IF NOT EXISTS `transactions_run1` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_run1`
--

INSERT INTO `transactions_run1` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 466, NULL, NULL, 38693, 'pending', 34, 84656, 'Insufficient Funds Fee', '2015-07-07 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', 'FL', 'Miami Beach', '', '', '', '', 0, 'special', '', 'N', NULL, 'unqualified', 'N'),
(2, 'deposit', 912, 16880587, NULL, 38697, 'pending', -60, 182506, 'ONLINE + TRANSFER FROM Sav PlusApr 15 15:09 9240 ONLINE Reference# 4094', '2016-04-15 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(3, 'buy', 1300, 13362885, NULL, 38698, 'pending', 46.88, 202076, 'ChoLon Bistro', '2016-01-19 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '80202', 'CO', 'Denver', '1555 Blake St.', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(4, 'buy', 466, 16880628, NULL, 38693, 'pending', 46.19, 84657, 'DELANO FOOD &amp; BEVERAGE', '2015-07-07 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', 'FL', 'Miami Beach', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(5, 'buy', 376, 16880568, NULL, 38698, 'pending', 35, 69000, 'Amazon', '2015-07-09 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N'),
(6, 'buy', 200, 16880654, NULL, 8502, 'pending', 29.14, 37688, 'Amazon', '2015-10-07 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '98109', '', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N'),
(7, 'buy', 791, 16880509, NULL, 38698, 'pending', 7, 202077, 'Save As You Go', '2016-03-21 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(8, 'buy', 466, 16880696, NULL, 38693, 'pending', 32.09, 84658, 'AFICIONADOS BRICKELL', '2015-07-07 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', 'FL', 'Miami', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(9, 'buy', 1204, 16880611, NULL, 38692, 'pending', 22.11, 182507, 'Walmart', '2016-04-15 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '92555', 'CA', 'Moreno Valley', '12721 Moreno Beach Dr', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(10, 'buy', 736, 16880666, NULL, 38694, 'pending', 349.32, 202078, 'Air France', '2015-12-17 00:00:00', '2016-06-07 19:39:09', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_run2`
--

CREATE TABLE IF NOT EXISTS `transactions_run2` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_run2`
--

INSERT INTO `transactions_run2` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 306, NULL, NULL, 13647, 'pending', 78.99, 59215, 'INTEREST CHARGED TO STANDARD PURCH', '2014-11-06 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 0, 'special', '', 'N', NULL, 'unqualified', 'N'),
(2, 'buy', 1031, 14049032, NULL, 38695, 'pending', 17.9, 145323, '7-Eleven', '2016-03-29 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '91423', 'CA', 'Sherman Oaks', '13307 Moorpark St', '', '', '', 100, 'place', '', 'N', NULL, 'exact-match', 'N'),
(3, 'buy', 421, 16880571, NULL, 38692, 'pending', 10.28, 76828, 'Cafe Exchange', '2015-07-21 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '10002', 'NY', 'New York', '49 E Broadway', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(4, 'buy', 702, 16880540, NULL, 38692, 'pending', 370, 219689, 'Teachers Federal Credit Union Bill Payment', '2015-10-09 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(5, 'buy', 1077, 16880689, NULL, 38698, 'complete', 227.06, 145324, 'SANTANDER CONSUMER 160330', '2016-03-30 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(6, 'deposit', 791, 16880509, NULL, 38698, 'pending', -3, 204033, 'Save As You Go', '2016-01-27 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(7, 'buy', 477, 16880590, NULL, 38693, 'pending', 28, 90527, 'Ye Olde King&#039;s Head', '2015-09-14 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '90401', 'CA', 'Santa Monica', '116 Santa Monica Blvd', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(8, 'buy', 881, 16880508, NULL, 38693, 'pending', 158.75, 211861, 'ESCAPE ALL HALL', '2014-08-29 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(9, 'buy', 376, 16880568, NULL, 38698, 'pending', 35, 69000, 'Amazon', '2015-07-09 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N'),
(10, 'buy', 306, 16880688, NULL, 13647, 'pending', 29.99, 59216, 'dditservices.com Luxembourg LUX', '2014-11-05 00:00:00', '2016-06-07 21:47:24', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_run3`
--

CREATE TABLE IF NOT EXISTS `transactions_run3` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_run3`
--

INSERT INTO `transactions_run3` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 991, 16880648, NULL, 38697, 'pending', 32, 123796, 'Classic Billiards Llc', '2015-09-19 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '93612', 'CA', 'Clovis', '711 W Shaw Ave Ste 117', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(2, 'buy', 883, 16880514, NULL, 38692, 'pending', 10, 217732, 'External transfer fee Next Day Confirmation:', '2015-06-30 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(3, 'buy', 452, 16880576, NULL, 38693, 'pending', 15, 82699, 'Uber', '2014-02-18 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(4, 'buy', 991, 16880673, NULL, 38697, 'pending', 8.95, 123797, 'FRESNO STATE-DININGQ89', '2015-09-18 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', 'CA', 'Fresno', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(5, 'buy', 452, 16880576, NULL, 38693, 'pending', 7.79, 82700, 'Uber', '2014-02-18 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(6, 'buy', 731, 16880545, NULL, 38698, 'pending', 8.21, 217733, 'Sonic', '2015-08-10 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '78728', 'TX', 'Austin', '1637  Wells Branch Pkwy', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(7, 'buy', 452, NULL, NULL, 38693, 'pending', 1140, 82701, 'CHECK # 288', '2014-02-18 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', '', '', '', '', '', '', 0, 'special', '', 'N', NULL, 'unqualified', 'N'),
(8, 'buy', 731, 16880542, NULL, 38698, 'pending', 55.78, 215775, 'BITESQUAD MN', '2016-03-11 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(9, 'deposit', 991, 16880762, NULL, 38697, 'pending', -0.01, 123798, 'INTEREST', '2015-09-18 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'special', '', 'N', NULL, 'auto_matched', 'N'),
(10, 'buy', 977, 16880645, NULL, 38696, 'pending', 5.99, 160979, 'iTunes', '2016-04-04 00:00:00', '2016-06-07 22:39:27', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `transactions_TEMP_JC` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=18289 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_TEMP_JC`
--

INSERT INTO `transactions_TEMP_JC` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(18279, 'buy', 100, 13436207, NULL, 11279, 'pending', 13.49, 29859, 'Quaker State Liquor', '2015-11-17 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90038', 'CA', 'Los Angeles', '6901 Melrose Ave', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18280, 'buy', 100, 16365959, NULL, 11279, 'pending', 9.85, 29860, 'Susina Bakery', '2015-11-17 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90036', 'CA', 'Los Angeles', '7122 Beverly Blvd', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18281, 'buy', 100, 10794638, NULL, 11279, 'pending', 28.36, 29861, 'Shell', '2015-11-17 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90035', 'CA', 'Los Angeles', '8500 W Pico Blvd', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18282, 'buy', 100, 4966184, NULL, 11279, 'pending', 3, 29862, 'Hollywood Juice Bar', '2015-11-17 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90028', 'CA', 'Los Angeles', '7021  Hollywood Blvd', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18283, 'buy', 100, 13823788, NULL, 11279, 'pending', 26.95, 29863, 'Palm Thai Restaurant', '2015-11-17 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90028', 'CA', 'Los Angeles', '5900 Hollywood Blvd', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18284, 'buy', 100, 5418, NULL, 11279, 'pending', 7.7, 29864, 'Subway', '2015-11-16 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90035', 'CA', 'Los Angeles', '1270 S La Cienega Blvd', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18285, 'buy', 100, 12231004, NULL, 11279, 'pending', 33.5, 29865, 'THE CORNER HOLLYWOOD', '2015-11-16 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '', 'CA', '', '', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18286, 'buy', 100, 68714, NULL, 11279, 'pending', 1.5, 29866, 'City Center Parking Inc', '2015-11-16 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', ''),
(18287, 'buy', 100, 865282, NULL, 11279, 'pending', 42.62, 29867, 'Republique', '2015-11-16 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90036', 'CA', 'Los Angeles', '624 La Brea Ave', '', '', '', 0, '', '', 'N', NULL, 'unqualified', ''),
(18288, 'buy', 100, 68714, NULL, 11279, 'pending', 1.5, 29868, 'City Center Parking Inc', '2015-11-16 00:00:00', '2015-11-18 17:16:02', 0, 0, '', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '', '', '', 0, '', '', 'N', NULL, 'auto_matched', '');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_TEMP_KU`
--

CREATE TABLE IF NOT EXISTS `transactions_TEMP_KU` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_TEMP_KU`
--

INSERT INTO `transactions_TEMP_KU` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 1031, 14049032, NULL, 38695, 'pending', 17.9, 145323, '7-Eleven', '2016-03-29 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '91423', 'CA', 'Sherman Oaks', '13307 Moorpark St', '', '', '', 100, 'place', '', 'N', NULL, 'exact-match', 'N'),
(2, 'buy', 1138, 10044133, NULL, 38693, 'pending', 8.38, 147280, 'Taco Bell', '2015-03-20 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '90003', 'CA', 'Los Angeles', '9919 Avalon Blvd', '', '', '', 100, 'place', '', 'N', NULL, 'exact-match', 'N'),
(3, 'buy', 1077, 16880689, NULL, 38698, 'complete', 227.06, 145324, 'SANTANDER CONSUMER 160330', '2016-03-30 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(4, 'buy', 452, 16880650, NULL, 38693, 'pending', 46.83, 200119, 'CVS', '2016-04-20 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '33125', 'FL', 'Miami', '650 NW 27th Ave', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(5, 'buy', 159, 16880598, NULL, 8502, 'complete', 410.67, 35991, 'VW CREDIT TEL. TEL DEBIT PPD', '2015-12-02 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(6, 'buy', 1138, 16880554, NULL, 38693, 'pending', 2.75, 147281, 'LA CITY METERED PARKIN', '2015-03-20 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '', 'CA', 'Los Angeles', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(7, 'buy', 452, 16880671, NULL, 38693, 'pending', 43.56, 200120, 'Brother Jimmy&#039;s Bbq', '2016-04-20 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '33143', 'FL', 'Miami', '5701 Sunset Dr Ste 266', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(8, 'buy', 159, 16880602, NULL, 8502, 'complete', 11.22, 35992, 'Target', '2015-12-02 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '', '', '', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(9, 'buy', 1138, 16880583, NULL, 38693, 'pending', 5.91, 147282, 'Bites', '2015-03-20 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '90024', 'CA', 'Los Angeles', '10960  Wilshire Blvd  Ste 140', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(10, 'buy', 1025, 16880747, NULL, 38697, 'complete', 58.32, 145325, 'Summer Canteen', '2016-03-29 00:00:00', '2016-06-07 23:27:56', 0, 0, '', '', '91602', 'CA', 'North Hollywood', '4444 Lankershim Blvd', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_TEMP_KU2`
--

CREATE TABLE IF NOT EXISTS `transactions_TEMP_KU2` (
  `id` bigint(20) NOT NULL,
  `transaction_type` enum('buy','sell','bonus','clout_refund','withdrawal','deposit','other') NOT NULL DEFAULT 'other',
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `_bank_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','complete','archived') NOT NULL DEFAULT 'pending',
  `amount` float NOT NULL,
  `_raw_id` bigint(20) DEFAULT NULL,
  `raw_store_name` varchar(300) NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `item_value` float NOT NULL,
  `transaction_tax` float NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `item_category` varchar(200) NOT NULL,
  `contact_telephone` varchar(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `confidence_level` float NOT NULL,
  `place_type` varchar(100) NOT NULL,
  `transaction_description` varchar(300) NOT NULL,
  `is_security_risk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_related_promotion_id` bigint(20) DEFAULT NULL,
  `match_status` varchar(100) NOT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_TEMP_KU2`
--

INSERT INTO `transactions_TEMP_KU2` (`id`, `transaction_type`, `_user_id`, `_store_id`, `_chain_id`, `_bank_id`, `status`, `amount`, `_raw_id`, `raw_store_name`, `start_date`, `end_date`, `item_value`, `transaction_tax`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `item_category`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `transaction_description`, `is_security_risk`, `_related_promotion_id`, `match_status`, `is_processed`) VALUES
(1, 'buy', 1, 16880658, NULL, 8502, 'pending', 893.22, 22774, 'LADWP WEB', '2014-10-01 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(2, 'buy', 1, 16891974, NULL, 8502, 'pending', 9.99, 22234, 'Dropbox*RD9T87HV1QYR db.tt/cchelp', '2015-04-10 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'digital', '', 'N', NULL, 'auto_matched', 'N'),
(3, 'buy', 1, 16885530, NULL, 8502, 'pending', 51, 22304, 'Lucifers Pizza', '2015-03-23 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '90036', 'CA', 'Los Angeles', '7123 Melrose Ave', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(4, 'buy', 1, 16880731, NULL, 8502, 'pending', 2.5, 22734, 'The Grove', '2014-10-20 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', 'CA', 'Los Angeles', '', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(5, 'buy', 1, 16890557, NULL, 8502, 'pending', 39, 22144, 'ARCLIGHT CINEMAS HOLL', '2015-05-26 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(6, 'buy', 1, 16893821, NULL, 8502, 'pending', 466.38, 22584, 'HOLLYWOOD ROOSEVELT HOT HOLLYWOOD', '2014-12-04 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', 'CA', '', '', '', '', '', 50, 'unresolved', '', 'N', NULL, 'auto_matched', 'N'),
(7, 'buy', 1, 13267924, NULL, 8502, 'pending', 0.25, 22775, 'City Center Parking Inc', '2014-09-30 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '', '', '', 100, 'place', '', 'N', NULL, 'exact-match', 'N'),
(8, 'deposit', 1, NULL, NULL, 8502, 'pending', -5000, 21904, 'Online Transfer from CHK ...7376', '2015-09-17 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '', '', '', '', '', '', '', 0, 'special', '', 'N', NULL, 'unqualified', 'N'),
(9, 'buy', 1, 16881736, NULL, 8502, 'pending', 3.65, 22574, 'Starbucks', '2014-12-09 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '92683', 'CA', 'Westminster', '16300 Beach Blvd', '', '', '', 50, 'place', '', 'N', NULL, 'auto_matched', 'N'),
(10, 'buy', 1, 13267924, NULL, 8502, 'pending', 0.25, 22444, 'City Center Parking Inc', '2015-01-28 00:00:00', '2016-06-08 18:21:59', 0, 0, '', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '', '', '', 100, 'place', '', 'N', NULL, 'exact-match', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptors`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptors` (
  `id` bigint(20) NOT NULL,
  `description` varchar(500) NOT NULL,
  `_scope_id` bigint(20) NOT NULL,
  `possible_location_matches` bigint(20) NOT NULL,
  `affected_transaction_amount` float DEFAULT NULL,
  `affected_transaction_number` bigint(20) DEFAULT NULL,
  `status` enum('pending','auto_matched','not_found','user_matched','unqualified','admin_matched','admin_and_user_matched') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=63 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptors`
--

INSERT INTO `transaction_descriptors` (`id`, `description`, `_scope_id`, `possible_location_matches`, `affected_transaction_amount`, `affected_transaction_number`, `status`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'California Chicken Cafe    |    205 Westwood Blvd., Los Angeles CA 90025', 7, 5, 507.75, 160, 'unqualified', '2015-07-30 00:00:00', 1, '2015-07-30 00:00:00', 1),
(54, 'Target 000188 West Hollywoo', 1, 0, 77.14, 2, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(55, 'Best Buy 00003939 W Hollywood', 1, 0, 32.61, 1, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(56, 'Ampco Parking West H West Hollywoo', 1, 0, 3, 1, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(57, 'Omi Sushi West Hollywoo', 1, 0, 69.34, 1, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(58, 'Caffe Primo West Hollywoo', 1, 0, 20.45, 1, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(59, 'godaddy.com', 1, 0, 2476.14, 17, 'pending', '2015-08-06 17:37:21', 1, '2015-12-01 19:28:39', 1),
(60, 'Mercury Casualty Payment Ppd Id:', 1, 0, 381.8, 2, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(61, 'Chipotle 1538 Los Angeles', 1, 0, 10.28, 1, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1),
(62, 'The Gas Company Paid Scgc', 1, 0, 21.31, 2, 'pending', '2015-08-06 17:37:21', 1, '2015-08-06 17:37:21', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptors_suggested_stores`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptors_suggested_stores` (
  `id` bigint(20) NOT NULL,
  `_transaction_descriptor_id` bigint(20) NOT NULL,
  `suggested_store_id` bigint(20) NOT NULL,
  `store_id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `_category_id` bigint(20) NOT NULL,
  `is_selected` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptors_suggested_stores`
--

INSERT INTO `transaction_descriptors_suggested_stores` (`id`, `_transaction_descriptor_id`, `suggested_store_id`, `store_id`, `_chain_id`, `_category_id`, `is_selected`, `status`, `date_entered`, `_entered_by`) VALUES
(1, 82, 0, 11, 29, 13, 'N', 'approved', '2015-08-31 00:00:00', 1),
(2, 82, 0, 912, 29, 13, 'N', 'approved', '2015-08-31 00:00:00', 1),
(8, 82, 0, 16880483, 259, 15, 'Y', 'approved', '2015-09-04 09:03:21', 1),
(9, 82, 0, 16880486, 29, 13, 'N', 'approved', '2015-09-04 15:56:56', 1),
(10, 82, 0, 16880487, 29, 13, 'N', 'approved', '2015-09-04 15:57:18', 1),
(11, 82, 0, 16880488, 259, 15, 'N', 'approved', '2015-09-04 16:02:18', 1),
(12, 225, 0, 16880489, 16880597, 3, 'N', 'approved', '2016-05-17 12:23:10', 0),
(13, 225, 0, 16880490, 16880597, 3, 'Y', 'approved', '2016-05-17 12:25:44', 0),
(14, 225, 0, 16880491, 16880597, 3, 'N', 'approved', '2016-05-17 18:58:51', 1),
(15, 225, 0, 16880492, 16880603, 10, 'Y', 'approved', '2016-05-17 19:14:21', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptor_chains`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptor_chains` (
  `id` bigint(20) NOT NULL,
  `_transaction_descriptor_id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `is_selected` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptor_chains`
--

INSERT INTO `transaction_descriptor_chains` (`id`, `_transaction_descriptor_id`, `_chain_id`, `status`, `is_selected`, `date_entered`, `_entered_by`) VALUES
(8, 82, 259, 'approved', 'Y', '2015-09-04 21:06:13', 1),
(9, 82, 9960238, 'approved', 'N', '2015-10-15 21:37:03', 11),
(15, 225, 16880597, 'approved', 'N', '2016-05-17 10:39:06', 0),
(16, 225, 16880603, 'approved', 'Y', '2016-05-17 12:42:35', 0),
(17, 192, 16880606, 'approved', 'Y', '2016-05-17 19:25:28', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptor_scopes`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptor_scopes` (
  `id` bigint(20) NOT NULL,
  `scope_name` varchar(300) NOT NULL,
  `status_match` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptor_scopes`
--

INSERT INTO `transaction_descriptor_scopes` (`id`, `scope_name`, `status_match`) VALUES
(1, 'Single Store Only', ''),
(2, 'Multiple Stores', ''),
(3, 'Single Website/Product', ''),
(4, 'Multiple Websites/Products', ''),
(5, 'Unknown', 'not_found'),
(6, 'Teller/ATM', 'unqualified'),
(7, 'Check', 'unqualified'),
(8, 'Wire', 'unqualified'),
(9, 'ACH', 'unqualified'),
(10, 'Bank Charge', 'unqualified');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptor_sub_categories`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptor_sub_categories` (
  `id` bigint(20) NOT NULL,
  `_descriptor_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptor_sub_categories`
--

INSERT INTO `transaction_descriptor_sub_categories` (`id`, `_descriptor_id`, `_sub_category_id`) VALUES
(37, 1, 0),
(36, 1, 100),
(33, 82, 0),
(26, 82, 3),
(27, 82, 5),
(28, 82, 26),
(29, 82, 2166),
(43, 82, 2173),
(44, 82, 2174),
(45, 82, 2175);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptor_sub_categories_suggestions`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptor_sub_categories_suggestions` (
  `id` bigint(20) NOT NULL,
  `_descriptor_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) NOT NULL,
  `suggestion_count` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptor_sub_categories_suggestions`
--

INSERT INTO `transaction_descriptor_sub_categories_suggestions` (`id`, `_descriptor_id`, `_sub_category_id`, `suggestion_count`) VALUES
(1, 82, 3, 2),
(2, 82, 5, 2),
(3, 82, 26, 2),
(4, 82, 2166, 2),
(5, 92, 1910, 1),
(6, 92, 1913, 1),
(7, 92, 1988, 1),
(8, 92, 1989, 1),
(9, 225, 1, 15),
(10, 225, 2, 15);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_descriptor_transactions`
--

CREATE TABLE IF NOT EXISTS `transaction_descriptor_transactions` (
  `id` bigint(20) NOT NULL,
  `_transactions_raw_id` bigint(20) NOT NULL,
  `_descriptor_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_descriptor_transactions`
--

INSERT INTO `transaction_descriptor_transactions` (`id`, `_transactions_raw_id`, `_descriptor_id`) VALUES
(1, 16384, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories`
--

INSERT INTO `transaction_sub_categories` (`id`, `_user_id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(1, 12, 1, 9, 925, 'N'),
(2, 12, 1, 9, 977, 'N'),
(3, 12, 1, 9, 1012, 'N'),
(4, 12, 2, 5, 450, 'N'),
(5, 12, 2, 9, 930, 'N'),
(6, 12, 2, 9, 934, 'N'),
(7, 12, 2, 9, 940, 'N'),
(8, 12, 2, 9, 955, 'N'),
(9, 12, 2, 9, 963, 'N'),
(10, 12, 2, 9, 975, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories_bk`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories_bk` (
  `id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=9871 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories_bk`
--

INSERT INTO `transaction_sub_categories_bk` (`id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(9861, 8164, 0, 450, 'N'),
(9862, 8164, 0, 930, 'N'),
(9863, 8164, 0, 934, 'N'),
(9864, 8164, 0, 940, 'N'),
(9865, 8164, 0, 955, 'N'),
(9866, 8164, 0, 963, 'N'),
(9867, 8164, 0, 975, 'N'),
(9868, 8164, 0, 978, 'N'),
(9869, 8164, 0, 995, 'N'),
(9870, 8164, 0, 996, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories_run1`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories_run1` (
  `id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories_run1`
--

INSERT INTO `transaction_sub_categories_run1` (`id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(1, 6, 0, 1958, 'N'),
(2, 18, 0, 1192, 'N'),
(3, 22, 0, 2015, 'N'),
(4, 35, 0, 327, 'N'),
(5, 43, 0, 440, 'N'),
(6, 48, 0, 2166, 'N'),
(7, 75, 0, 1832, 'N'),
(8, 97, 0, 1832, 'N'),
(9, 155, 0, NULL, 'N'),
(10, 332, 0, 965, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories_run2`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories_run2` (
  `id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories_run2`
--

INSERT INTO `transaction_sub_categories_run2` (`id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(1, 6, 0, NULL, 'N'),
(2, 12, 0, NULL, 'N'),
(3, 17, 0, 999, 'N'),
(4, 38, 0, 1362, 'N'),
(5, 45, 0, 148, 'N'),
(6, 65, 0, 628, 'N'),
(7, 84, 0, 1965, 'N'),
(8, 119, 0, NULL, 'N'),
(9, 292, 0, 148, 'N'),
(10, 482, 0, 2132, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories_run3`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories_run3` (
  `id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories_run3`
--

INSERT INTO `transaction_sub_categories_run3` (`id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(1, 11, 0, NULL, 'N'),
(2, 15, 0, 1958, 'N'),
(3, 22, 0, NULL, 'N'),
(4, 27, 0, NULL, 'N'),
(5, 46, 0, NULL, 'N'),
(6, 57, 0, 1007, 'N'),
(7, 90, 0, 1989, 'N'),
(8, 138, 0, NULL, 'N'),
(9, 242, 0, NULL, 'N'),
(10, 512, 0, NULL, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `transaction_sub_categories_TEMP_KU`
--

CREATE TABLE IF NOT EXISTS `transaction_sub_categories_TEMP_KU` (
  `id` bigint(20) NOT NULL,
  `_transaction_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) NOT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL,
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transaction_sub_categories_TEMP_KU`
--

INSERT INTO `transaction_sub_categories_TEMP_KU` (`id`, `_transaction_id`, `_category_id`, `_sub_category_id`, `is_processed`) VALUES
(1, 10, 0, 128, 'N'),
(2, 34, 0, 1958, 'N'),
(3, 65, 0, 628, 'N'),
(4, 82, 0, 991, 'N'),
(5, 89, 0, 393, 'N'),
(6, 116, 0, 1000, 'N'),
(7, 127, 0, 1000, 'N'),
(8, 33, 0, 1958, 'N'),
(9, 9, 0, 943, 'N'),
(10, 44, 0, NULL, 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `user_cash_tracking`
--

CREATE TABLE IF NOT EXISTS `user_cash_tracking` (
  `id` bigint(20) NOT NULL,
  `_bank_account_id` bigint(20) DEFAULT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `cash_amount` float NOT NULL,
  `read_date` datetime NOT NULL,
  `is_latest` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_cash_tracking`
--

INSERT INTO `user_cash_tracking` (`id`, `_bank_account_id`, `_user_id`, `cash_amount`, `read_date`, `is_latest`) VALUES
(1, 1, 1, 4255.34, '2015-07-15 08:22:43', 'Y'),
(2, 1, 1, 1000, '2015-04-23 00:00:00', 'N'),
(3, 3, 1, 1274.93, '2015-09-29 13:38:55', 'Y'),
(4, 4, 1, 1253.32, '2015-09-29 13:38:55', 'Y'),
(5, 5, 1, 7255.23, '2015-09-29 13:38:56', 'Y'),
(6, 7, 1, 1274.93, '2015-09-29 16:59:03', 'Y'),
(7, 8, 1, 1253.32, '2015-09-29 16:59:03', 'Y'),
(8, 9, 1, 7255.23, '2015-09-29 16:59:03', 'Y'),
(9, 11, 44, 1274.93, '2016-02-18 19:46:14', 'N'),
(10, 12, 44, 1253.32, '2016-02-18 19:46:14', 'N');

--
-- Триггеры `user_cash_tracking`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_cash_tracking` AFTER INSERT ON `user_cash_tracking`
 FOR EACH ROW BEGIN

	-- get the current cash balance for the user
	SELECT cash_balance_today FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW._user_id INTO @OLD_cash_balance_today;

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET cash_balance_today=NEW.cash_amount WHERE user_id=NEW._user_id;

	-- now increase the new frequency
	INSERT INTO clout_v1_3cron.datatable__frequency_cash_balance_today (data_value, frequency) 
	(SELECT NEW.cash_amount, 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);
	-- and decrease the old frequency
	IF @OLD_cash_balance_today IS NOT NULL THEN
		UPDATE clout_v1_3cron.datatable__frequency_cash_balance_today SET frequency=(frequency - 1) WHERE data_value=@OLD_cash_balance_today;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_credit_tracking`
--

CREATE TABLE IF NOT EXISTS `user_credit_tracking` (
  `id` bigint(20) NOT NULL,
  `_bank_account_id` bigint(20) DEFAULT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `credit_amount` float NOT NULL,
  `read_date` datetime NOT NULL,
  `is_latest` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_credit_tracking`
--

INSERT INTO `user_credit_tracking` (`id`, `_bank_account_id`, `_user_id`, `credit_amount`, `read_date`, `is_latest`) VALUES
(1, 2, 1, 2980.56, '2015-06-30 08:21:41', 'N'),
(2, 2, 1, 8451.3, '2015-05-20 00:30:05', 'N'),
(3, 2, 1, 1500, '2015-07-16 08:21:41', 'Y'),
(4, 6, 1, 2275.58, '2015-09-29 13:38:56', 'Y'),
(5, 10, 1, 2275.58, '2015-09-29 16:59:03', 'Y'),
(6, 14, 44, 2275.58, '2016-02-18 19:46:14', 'N'),
(7, 14, 44, 2275.58, '2016-02-18 19:46:49', 'Y'),
(8, 22, 44, 2275.58, '2016-02-18 19:48:23', 'N'),
(9, 22, 44, 2275.58, '2016-02-18 19:49:12', 'Y'),
(10, 26, 6, 2275.58, '2016-03-01 10:39:03', 'Y');

--
-- Триггеры `user_credit_tracking`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_credit_tracking` AFTER INSERT ON `user_credit_tracking`
 FOR EACH ROW BEGIN

	-- get the current credit balance for the user
	SELECT credit_balance_today FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW._user_id INTO @OLD_credit_balance_today;

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET credit_balance_today=NEW.credit_amount WHERE user_id=NEW._user_id;

	-- now increase the new frequency
	INSERT INTO clout_v1_3cron.datatable__frequency_credit_balance_today (data_value, frequency) 
	(SELECT NEW.credit_amount, 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);
	-- and decrease the old frequency
	IF @OLD_credit_balance_today IS NOT NULL THEN
		UPDATE clout_v1_3cron.datatable__frequency_credit_balance_today SET frequency=(frequency - 1) WHERE data_value=@OLD_credit_balance_today;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_payment_tracking`
--

CREATE TABLE IF NOT EXISTS `user_payment_tracking` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `amount` float NOT NULL,
  `payment_source` varchar(100) NOT NULL,
  `referral_user_id` varchar(100) NOT NULL,
  `transaction_id` varchar(100) NOT NULL,
  `details` text NOT NULL,
  `pay_date` datetime NOT NULL,
  `status` enum('approved','pending','declined','closed','deleted') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__user_spending_summary`
--
CREATE TABLE IF NOT EXISTS `view__user_spending_summary` (
`transaction_id` bigint(20)
,`store_id` bigint(20)
,`user_id` bigint(20)
,`amount` float
,`start_date` datetime
);

-- --------------------------------------------------------

--
-- Структура таблицы `zipcodes`
--

CREATE TABLE IF NOT EXISTS `zipcodes` (
  `id` bigint(20) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `state_id` bigint(20) NOT NULL,
  `county` varchar(100) NOT NULL,
  `area_code` varchar(10) NOT NULL,
  `time_zone` varchar(10) NOT NULL,
  `has_day_light_saving` enum('Y','N') NOT NULL DEFAULT 'N',
  `region` varchar(100) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=49188 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `zipcodes`
--

INSERT INTO `zipcodes` (`id`, `zipcode`, `latitude`, `longitude`, `state_id`, `county`, `area_code`, `time_zone`, `has_day_light_saving`, `region`, `city`, `_country_code`) VALUES
(49178, '00501', '40.8154', '-73.0456', 51, 'SUFFOLK', '631', '5', 'Y', 'Northeast', 'HOLTSVILLE', 'USA'),
(49179, '00501', '40.8154', '-73.0456', 51, 'SUFFOLK', '631', '5', 'Y', 'Northeast', 'HOLTSVILLE', 'USA'),
(49180, '00544', '40.8154', '-73.0456', 51, 'SUFFOLK', '631', '5', 'Y', 'Northeast', 'HOLTSVILLE', 'USA'),
(49181, '00544', '40.8154', '-73.0456', 51, 'SUFFOLK', '631', '5', 'Y', 'Northeast', 'HOLTSVILLE', 'USA'),
(49182, '00601', '18.196747', '-66.736735', 85, 'ADJUNTAS', '787/939', '4', 'N', '', 'ADJUNTAS', 'USA'),
(49183, '00601', '18.196747', '-66.736735', 85, 'ADJUNTAS', '787/939', '4', 'N', '', 'ADJUNTAS', 'USA'),
(49184, '00601', '18.196747', '-66.736735', 85, 'ADJUNTAS', '787/939', '4', 'N', '', 'ADJUNTAS', 'USA'),
(49185, '00601', '18.196747', '-66.736735', 85, 'ADJUNTAS', '787/939', '4', 'N', '', 'ADJUNTAS', 'USA'),
(49186, '00602', '18.352927', '-67.177532', 85, 'AGUADA', '787', '4', 'N', '', 'AGUADA', 'USA'),
(49187, '00602', '18.352927', '-67.177532', 85, 'AGUADA', '787', '4', 'N', '', 'AGUADA', 'USA');

-- --------------------------------------------------------

--
-- Структура для представления `view__user_spending_summary`
--
DROP TABLE IF EXISTS `view__user_spending_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__user_spending_summary` AS select distinct `transactions`.`id` AS `transaction_id`,`transactions`.`_store_id` AS `store_id`,`transactions`.`_user_id` AS `user_id`,`transactions`.`amount` AS `amount`,`transactions`.`start_date` AS `start_date` from `transactions` where ((`transactions`.`transaction_type` = 'buy') and (`transactions`.`amount` > 0) and (`transactions`.`_store_id` <> '0'));

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
-- Индексы таблицы `advert_and_promo_tracking`
--
ALTER TABLE `advert_and_promo_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_advert_and_promo_tracking__user_id` (`_user_id`),
  ADD KEY `fk_advert_and_promo_tracking__advertisement_id` (`_advertisement_id`),
  ADD KEY `fk_advert_and_promo_tracking__promotion_id` (`_promotion_id`);

--
-- Индексы таблицы `banks`
--
ALTER TABLE `banks`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institution_name` (`institution_name`),
  ADD FULLTEXT KEY `institution_name_index` (`institution_name`);

--
-- Индексы таблицы `banks_raw`
--
ALTER TABLE `banks_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `institution_name` (`institution_name`),
  ADD FULLTEXT KEY `institution_name_index` (`institution_name`);

--
-- Индексы таблицы `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`account_type`,`account_id`,`_bank_id`);

--
-- Индексы таблицы `bank_accounts_credit_raw`
--
ALTER TABLE `bank_accounts_credit_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_id` (`account_id`,`_user_id`,`_institution_id`);

--
-- Индексы таблицы `bank_accounts_other_raw`
--
ALTER TABLE `bank_accounts_other_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `account_id` (`account_id`,`_user_id`,`_institution_id`);

--
-- Индексы таблицы `cacheview__clout_score`
--
ALTER TABLE `cacheview__clout_score`
  ADD UNIQUE KEY `cache_id` (`user_id`);

--
-- Индексы таблицы `cacheview__clout_score_data`
--
ALTER TABLE `cacheview__clout_score_data`
  ADD UNIQUE KEY `cache_id` (`user_id`);

--
-- Индексы таблицы `cacheview__promotions_summary`
--
ALTER TABLE `cacheview__promotions_summary`
  ADD PRIMARY KEY (`table_id`),
  ADD FULLTEXT KEY `store_name` (`store_name`);

--
-- Индексы таблицы `cacheview__store_scores_previous`
--
ALTER TABLE `cacheview__store_scores_previous`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `cacheview__store_score_by_category`
--
ALTER TABLE `cacheview__store_score_by_category`
  ADD UNIQUE KEY `cache_id` (`sub_category_id`,`user_id`);

--
-- Индексы таблицы `cacheview__store_score_by_default`
--
ALTER TABLE `cacheview__store_score_by_default`
  ADD UNIQUE KEY `cache_id` (`user_id`);

--
-- Индексы таблицы `cacheview__store_score_by_store`
--
ALTER TABLE `cacheview__store_score_by_store`
  ADD UNIQUE KEY `cache_id` (`store_id`,`user_id`);

--
-- Индексы таблицы `cacheview__store_score_data_by_category`
--
ALTER TABLE `cacheview__store_score_data_by_category`
  ADD UNIQUE KEY `cache_id` (`sub_category_id`,`user_id`);

--
-- Индексы таблицы `cacheview__store_score_data_by_default`
--
ALTER TABLE `cacheview__store_score_data_by_default`
  ADD UNIQUE KEY `cache_id` (`user_id`);

--
-- Индексы таблицы `cacheview__store_score_data_by_store`
--
ALTER TABLE `cacheview__store_score_data_by_store`
  ADD UNIQUE KEY `cache_id` (`store_id`,`user_id`);

--
-- Индексы таблицы `cacheview__where_user_shopped`
--
ALTER TABLE `cacheview__where_user_shopped`
  ADD PRIMARY KEY (`table_id`);

--
-- Индексы таблицы `chain_match_rules`
--
ALTER TABLE `chain_match_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`rule_type`,`match_chain_id`,`descriptor_id`,`details`);

--
-- Индексы таблицы `commissions_alerts`
--
ALTER TABLE `commissions_alerts`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `commissions_network`
--
ALTER TABLE `commissions_network`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `commissions_transactions`
--
ALTER TABLE `commissions_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `commissions_transfers`
--
ALTER TABLE `commissions_transfers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `cron_external_schedule`
--
ALTER TABLE `cron_external_schedule`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_string` (`job_string`,`scheduler`,`processer`);

--
-- Индексы таблицы `cron_log`
--
ALTER TABLE `cron_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cron_log__cron_job_id` (`_cron_job_id`);

--
-- Индексы таблицы `cron_schedule`
--
ALTER TABLE `cron_schedule`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `activity_code` (`activity_code`,`cron_value`);

--
-- Индексы таблицы `datatable__frequency_ad_spending_last180days`
--
ALTER TABLE `datatable__frequency_ad_spending_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_ad_spending_last360days`
--
ALTER TABLE `datatable__frequency_ad_spending_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_ad_spending_total`
--
ALTER TABLE `datatable__frequency_ad_spending_total`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_average_cash_balance_last24months`
--
ALTER TABLE `datatable__frequency_average_cash_balance_last24months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_average_credit_balance_last24months`
--
ALTER TABLE `datatable__frequency_average_credit_balance_last24months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_cash_balance_today`
--
ALTER TABLE `datatable__frequency_cash_balance_today`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_credit_balance_today`
--
ALTER TABLE `datatable__frequency_credit_balance_today`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_category_spending_last12months`
--
ALTER TABLE `datatable__frequency_my_category_spending_last12months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_category_spending_last90days`
--
ALTER TABLE `datatable__frequency_my_category_spending_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_category_spending_lifetime`
--
ALTER TABLE `datatable__frequency_my_category_spending_lifetime`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_chain_spending_last12months`
--
ALTER TABLE `datatable__frequency_my_chain_spending_last12months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_chain_spending_last90days`
--
ALTER TABLE `datatable__frequency_my_chain_spending_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_chain_spending_lifetime`
--
ALTER TABLE `datatable__frequency_my_chain_spending_lifetime`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_direct_competitors_spending_last12months`
--
ALTER TABLE `datatable__frequency_my_direct_competitors_spending_last12months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_direct_competitors_spending_last90days`
--
ALTER TABLE `datatable__frequency_my_direct_competitors_spending_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_direct_competitors_spending_lifetime`
--
ALTER TABLE `datatable__frequency_my_direct_competitors_spending_lifetime`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_store_spending_last12months`
--
ALTER TABLE `datatable__frequency_my_store_spending_last12months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_store_spending_last90days`
--
ALTER TABLE `datatable__frequency_my_store_spending_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_my_store_spending_lifetime`
--
ALTER TABLE `datatable__frequency_my_store_spending_lifetime`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_number_of_direct_referrals_last180days`
--
ALTER TABLE `datatable__frequency_number_of_direct_referrals_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_number_of_direct_referrals_last360days`
--
ALTER TABLE `datatable__frequency_number_of_direct_referrals_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_number_of_network_referrals_last180days`
--
ALTER TABLE `datatable__frequency_number_of_network_referrals_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_number_of_network_referrals_last360days`
--
ALTER TABLE `datatable__frequency_number_of_network_referrals_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_number_of_surveys_answered_in_last90days`
--
ALTER TABLE `datatable__frequency_number_of_surveys_answered_in_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_related_categories_spending_last12months`
--
ALTER TABLE `datatable__frequency_related_categories_spending_last12months`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_related_categories_spending_last90days`
--
ALTER TABLE `datatable__frequency_related_categories_spending_last90days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_related_categories_spending_lifetime`
--
ALTER TABLE `datatable__frequency_related_categories_spending_lifetime`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_last180days`
--
ALTER TABLE `datatable__frequency_spending_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_last360days`
--
ALTER TABLE `datatable__frequency_spending_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_of_direct_referrals_last180days`
--
ALTER TABLE `datatable__frequency_spending_of_direct_referrals_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_of_direct_referrals_last360days`
--
ALTER TABLE `datatable__frequency_spending_of_direct_referrals_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_of_network_referrals_last180days`
--
ALTER TABLE `datatable__frequency_spending_of_network_referrals_last180days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_of_network_referrals_last360days`
--
ALTER TABLE `datatable__frequency_spending_of_network_referrals_last360days`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_spending_total`
--
ALTER TABLE `datatable__frequency_spending_total`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_total_direct_referrals`
--
ALTER TABLE `datatable__frequency_total_direct_referrals`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_total_network_referrals`
--
ALTER TABLE `datatable__frequency_total_network_referrals`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_total_spending_of_direct_referrals`
--
ALTER TABLE `datatable__frequency_total_spending_of_direct_referrals`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__frequency_total_spending_of_network_referrals`
--
ALTER TABLE `datatable__frequency_total_spending_of_network_referrals`
  ADD PRIMARY KEY (`data_value`);

--
-- Индексы таблицы `datatable__network_data`
--
ALTER TABLE `datatable__network_data`
  ADD PRIMARY KEY (`user_id`);

--
-- Индексы таблицы `datatable__store_344269_data`
--
ALTER TABLE `datatable__store_344269_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_344269_data__age`
--
ALTER TABLE `datatable__store_344269_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_6334156_data`
--
ALTER TABLE `datatable__store_6334156_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_6334156_data__age`
--
ALTER TABLE `datatable__store_6334156_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_8250262_data`
--
ALTER TABLE `datatable__store_8250262_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_8250262_data__age`
--
ALTER TABLE `datatable__store_8250262_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_13267924_data`
--
ALTER TABLE `datatable__store_13267924_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_13267924_data__age`
--
ALTER TABLE `datatable__store_13267924_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_13536808_data`
--
ALTER TABLE `datatable__store_13536808_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_13536808_data__age`
--
ALTER TABLE `datatable__store_13536808_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16365959_data`
--
ALTER TABLE `datatable__store_16365959_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16365959_data__age`
--
ALTER TABLE `datatable__store_16365959_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960491_data`
--
ALTER TABLE `datatable__store_16960491_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960491_data__age`
--
ALTER TABLE `datatable__store_16960491_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960494_data`
--
ALTER TABLE `datatable__store_16960494_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960494_data__age`
--
ALTER TABLE `datatable__store_16960494_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960496_data`
--
ALTER TABLE `datatable__store_16960496_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960496_data__age`
--
ALTER TABLE `datatable__store_16960496_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960498_data`
--
ALTER TABLE `datatable__store_16960498_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960498_data__age`
--
ALTER TABLE `datatable__store_16960498_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960500_data`
--
ALTER TABLE `datatable__store_16960500_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960500_data__age`
--
ALTER TABLE `datatable__store_16960500_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960502_data`
--
ALTER TABLE `datatable__store_16960502_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960502_data__age`
--
ALTER TABLE `datatable__store_16960502_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960504_data`
--
ALTER TABLE `datatable__store_16960504_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960504_data__age`
--
ALTER TABLE `datatable__store_16960504_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960506_data`
--
ALTER TABLE `datatable__store_16960506_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960506_data__age`
--
ALTER TABLE `datatable__store_16960506_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960508_data`
--
ALTER TABLE `datatable__store_16960508_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960508_data__age`
--
ALTER TABLE `datatable__store_16960508_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960510_data`
--
ALTER TABLE `datatable__store_16960510_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960510_data__age`
--
ALTER TABLE `datatable__store_16960510_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960512_data`
--
ALTER TABLE `datatable__store_16960512_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960512_data__age`
--
ALTER TABLE `datatable__store_16960512_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960514_data`
--
ALTER TABLE `datatable__store_16960514_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960514_data__age`
--
ALTER TABLE `datatable__store_16960514_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960516_data`
--
ALTER TABLE `datatable__store_16960516_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960516_data__age`
--
ALTER TABLE `datatable__store_16960516_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960518_data`
--
ALTER TABLE `datatable__store_16960518_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960518_data__age`
--
ALTER TABLE `datatable__store_16960518_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960520_data`
--
ALTER TABLE `datatable__store_16960520_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960520_data__age`
--
ALTER TABLE `datatable__store_16960520_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960522_data`
--
ALTER TABLE `datatable__store_16960522_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960522_data__age`
--
ALTER TABLE `datatable__store_16960522_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960524_data`
--
ALTER TABLE `datatable__store_16960524_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960524_data__age`
--
ALTER TABLE `datatable__store_16960524_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960526_data`
--
ALTER TABLE `datatable__store_16960526_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960526_data__age`
--
ALTER TABLE `datatable__store_16960526_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960528_data`
--
ALTER TABLE `datatable__store_16960528_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960528_data__age`
--
ALTER TABLE `datatable__store_16960528_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960530_data`
--
ALTER TABLE `datatable__store_16960530_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960530_data__age`
--
ALTER TABLE `datatable__store_16960530_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960532_data`
--
ALTER TABLE `datatable__store_16960532_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960532_data__age`
--
ALTER TABLE `datatable__store_16960532_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960536_data`
--
ALTER TABLE `datatable__store_16960536_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960536_data__age`
--
ALTER TABLE `datatable__store_16960536_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960538_data`
--
ALTER TABLE `datatable__store_16960538_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960538_data__age`
--
ALTER TABLE `datatable__store_16960538_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960540_data`
--
ALTER TABLE `datatable__store_16960540_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960540_data__age`
--
ALTER TABLE `datatable__store_16960540_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960542_data`
--
ALTER TABLE `datatable__store_16960542_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960542_data__age`
--
ALTER TABLE `datatable__store_16960542_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960544_data`
--
ALTER TABLE `datatable__store_16960544_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960544_data__age`
--
ALTER TABLE `datatable__store_16960544_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960546_data`
--
ALTER TABLE `datatable__store_16960546_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960546_data__age`
--
ALTER TABLE `datatable__store_16960546_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960548_data`
--
ALTER TABLE `datatable__store_16960548_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960548_data__age`
--
ALTER TABLE `datatable__store_16960548_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960553_data`
--
ALTER TABLE `datatable__store_16960553_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960553_data__age`
--
ALTER TABLE `datatable__store_16960553_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960555_data`
--
ALTER TABLE `datatable__store_16960555_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960555_data__age`
--
ALTER TABLE `datatable__store_16960555_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960557_data`
--
ALTER TABLE `datatable__store_16960557_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960557_data__age`
--
ALTER TABLE `datatable__store_16960557_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960559_data`
--
ALTER TABLE `datatable__store_16960559_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960559_data__age`
--
ALTER TABLE `datatable__store_16960559_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960561_data`
--
ALTER TABLE `datatable__store_16960561_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960561_data__age`
--
ALTER TABLE `datatable__store_16960561_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960563_data`
--
ALTER TABLE `datatable__store_16960563_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960563_data__age`
--
ALTER TABLE `datatable__store_16960563_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960565_data`
--
ALTER TABLE `datatable__store_16960565_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960565_data__age`
--
ALTER TABLE `datatable__store_16960565_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960567_data`
--
ALTER TABLE `datatable__store_16960567_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960567_data__age`
--
ALTER TABLE `datatable__store_16960567_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960569_data`
--
ALTER TABLE `datatable__store_16960569_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960569_data__age`
--
ALTER TABLE `datatable__store_16960569_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960571_data`
--
ALTER TABLE `datatable__store_16960571_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960571_data__age`
--
ALTER TABLE `datatable__store_16960571_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960573_data`
--
ALTER TABLE `datatable__store_16960573_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960573_data__age`
--
ALTER TABLE `datatable__store_16960573_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960575_data`
--
ALTER TABLE `datatable__store_16960575_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960575_data__age`
--
ALTER TABLE `datatable__store_16960575_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960577_data`
--
ALTER TABLE `datatable__store_16960577_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960577_data__age`
--
ALTER TABLE `datatable__store_16960577_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960579_data`
--
ALTER TABLE `datatable__store_16960579_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960579_data__age`
--
ALTER TABLE `datatable__store_16960579_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960583_data`
--
ALTER TABLE `datatable__store_16960583_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960583_data__age`
--
ALTER TABLE `datatable__store_16960583_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960585_data`
--
ALTER TABLE `datatable__store_16960585_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960585_data__age`
--
ALTER TABLE `datatable__store_16960585_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960587_data`
--
ALTER TABLE `datatable__store_16960587_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_16960587_data__age`
--
ALTER TABLE `datatable__store_16960587_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_CACHE_data`
--
ALTER TABLE `datatable__store_CACHE_data`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_CACHE_data__age`
--
ALTER TABLE `datatable__store_CACHE_data__age`
  ADD UNIQUE KEY `user_id_2` (`user_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__store_chain_CACHE_data`
--
ALTER TABLE `datatable__store_chain_CACHE_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `chain_id` (`chain_id`,`other_store_id`);

--
-- Индексы таблицы `datatable__subcategory_6_data`
--
ALTER TABLE `datatable__subcategory_6_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_6_data__age`
--
ALTER TABLE `datatable__subcategory_6_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_93_data`
--
ALTER TABLE `datatable__subcategory_93_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_93_data__age`
--
ALTER TABLE `datatable__subcategory_93_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_108_data`
--
ALTER TABLE `datatable__subcategory_108_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_108_data__age`
--
ALTER TABLE `datatable__subcategory_108_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_112_data`
--
ALTER TABLE `datatable__subcategory_112_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_112_data__age`
--
ALTER TABLE `datatable__subcategory_112_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_119_data`
--
ALTER TABLE `datatable__subcategory_119_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_119_data__age`
--
ALTER TABLE `datatable__subcategory_119_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_125_data`
--
ALTER TABLE `datatable__subcategory_125_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_125_data__age`
--
ALTER TABLE `datatable__subcategory_125_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_126_data`
--
ALTER TABLE `datatable__subcategory_126_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_126_data__age`
--
ALTER TABLE `datatable__subcategory_126_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_127_data`
--
ALTER TABLE `datatable__subcategory_127_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_127_data__age`
--
ALTER TABLE `datatable__subcategory_127_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_128_data`
--
ALTER TABLE `datatable__subcategory_128_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_128_data__age`
--
ALTER TABLE `datatable__subcategory_128_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_129_data`
--
ALTER TABLE `datatable__subcategory_129_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_129_data__age`
--
ALTER TABLE `datatable__subcategory_129_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_135_data`
--
ALTER TABLE `datatable__subcategory_135_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_135_data__age`
--
ALTER TABLE `datatable__subcategory_135_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_147_data`
--
ALTER TABLE `datatable__subcategory_147_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_147_data__age`
--
ALTER TABLE `datatable__subcategory_147_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_148_data`
--
ALTER TABLE `datatable__subcategory_148_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_148_data__age`
--
ALTER TABLE `datatable__subcategory_148_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_160_data`
--
ALTER TABLE `datatable__subcategory_160_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_160_data__age`
--
ALTER TABLE `datatable__subcategory_160_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_210_data`
--
ALTER TABLE `datatable__subcategory_210_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_210_data__age`
--
ALTER TABLE `datatable__subcategory_210_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_450_data`
--
ALTER TABLE `datatable__subcategory_450_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_450_data__age`
--
ALTER TABLE `datatable__subcategory_450_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_918_data`
--
ALTER TABLE `datatable__subcategory_918_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_918_data__age`
--
ALTER TABLE `datatable__subcategory_918_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_921_data`
--
ALTER TABLE `datatable__subcategory_921_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_921_data__age`
--
ALTER TABLE `datatable__subcategory_921_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_924_data`
--
ALTER TABLE `datatable__subcategory_924_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_924_data__age`
--
ALTER TABLE `datatable__subcategory_924_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_925_data`
--
ALTER TABLE `datatable__subcategory_925_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_925_data__age`
--
ALTER TABLE `datatable__subcategory_925_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_926_data`
--
ALTER TABLE `datatable__subcategory_926_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_926_data__age`
--
ALTER TABLE `datatable__subcategory_926_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_927_data`
--
ALTER TABLE `datatable__subcategory_927_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_927_data__age`
--
ALTER TABLE `datatable__subcategory_927_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_930_data`
--
ALTER TABLE `datatable__subcategory_930_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_930_data__age`
--
ALTER TABLE `datatable__subcategory_930_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_931_data`
--
ALTER TABLE `datatable__subcategory_931_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_931_data__age`
--
ALTER TABLE `datatable__subcategory_931_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_933_data`
--
ALTER TABLE `datatable__subcategory_933_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_933_data__age`
--
ALTER TABLE `datatable__subcategory_933_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_934_data`
--
ALTER TABLE `datatable__subcategory_934_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_934_data__age`
--
ALTER TABLE `datatable__subcategory_934_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_936_data`
--
ALTER TABLE `datatable__subcategory_936_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_936_data__age`
--
ALTER TABLE `datatable__subcategory_936_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_940_data`
--
ALTER TABLE `datatable__subcategory_940_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_940_data__age`
--
ALTER TABLE `datatable__subcategory_940_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_943_data`
--
ALTER TABLE `datatable__subcategory_943_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_943_data__age`
--
ALTER TABLE `datatable__subcategory_943_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_947_data`
--
ALTER TABLE `datatable__subcategory_947_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_947_data__age`
--
ALTER TABLE `datatable__subcategory_947_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_955_data`
--
ALTER TABLE `datatable__subcategory_955_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_955_data__age`
--
ALTER TABLE `datatable__subcategory_955_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_960_data`
--
ALTER TABLE `datatable__subcategory_960_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_960_data__age`
--
ALTER TABLE `datatable__subcategory_960_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_963_data`
--
ALTER TABLE `datatable__subcategory_963_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_963_data__age`
--
ALTER TABLE `datatable__subcategory_963_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_965_data`
--
ALTER TABLE `datatable__subcategory_965_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_965_data__age`
--
ALTER TABLE `datatable__subcategory_965_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_971_data`
--
ALTER TABLE `datatable__subcategory_971_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_971_data__age`
--
ALTER TABLE `datatable__subcategory_971_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_972_data`
--
ALTER TABLE `datatable__subcategory_972_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_972_data__age`
--
ALTER TABLE `datatable__subcategory_972_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_975_data`
--
ALTER TABLE `datatable__subcategory_975_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_975_data__age`
--
ALTER TABLE `datatable__subcategory_975_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_977_data`
--
ALTER TABLE `datatable__subcategory_977_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_977_data__age`
--
ALTER TABLE `datatable__subcategory_977_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_978_data`
--
ALTER TABLE `datatable__subcategory_978_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_978_data__age`
--
ALTER TABLE `datatable__subcategory_978_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_989_data`
--
ALTER TABLE `datatable__subcategory_989_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_989_data__age`
--
ALTER TABLE `datatable__subcategory_989_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_993_data`
--
ALTER TABLE `datatable__subcategory_993_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_993_data__age`
--
ALTER TABLE `datatable__subcategory_993_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_995_data`
--
ALTER TABLE `datatable__subcategory_995_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_995_data__age`
--
ALTER TABLE `datatable__subcategory_995_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_996_data`
--
ALTER TABLE `datatable__subcategory_996_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_996_data__age`
--
ALTER TABLE `datatable__subcategory_996_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1009_data`
--
ALTER TABLE `datatable__subcategory_1009_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1009_data__age`
--
ALTER TABLE `datatable__subcategory_1009_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1011_data`
--
ALTER TABLE `datatable__subcategory_1011_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1011_data__age`
--
ALTER TABLE `datatable__subcategory_1011_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1012_data`
--
ALTER TABLE `datatable__subcategory_1012_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1012_data__age`
--
ALTER TABLE `datatable__subcategory_1012_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1064_data`
--
ALTER TABLE `datatable__subcategory_1064_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1064_data__age`
--
ALTER TABLE `datatable__subcategory_1064_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1065_data`
--
ALTER TABLE `datatable__subcategory_1065_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1065_data__age`
--
ALTER TABLE `datatable__subcategory_1065_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1144_data`
--
ALTER TABLE `datatable__subcategory_1144_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1144_data__age`
--
ALTER TABLE `datatable__subcategory_1144_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1179_data`
--
ALTER TABLE `datatable__subcategory_1179_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1179_data__age`
--
ALTER TABLE `datatable__subcategory_1179_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1180_data`
--
ALTER TABLE `datatable__subcategory_1180_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1180_data__age`
--
ALTER TABLE `datatable__subcategory_1180_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1192_data`
--
ALTER TABLE `datatable__subcategory_1192_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1192_data__age`
--
ALTER TABLE `datatable__subcategory_1192_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1927_data`
--
ALTER TABLE `datatable__subcategory_1927_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1927_data__age`
--
ALTER TABLE `datatable__subcategory_1927_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1928_data`
--
ALTER TABLE `datatable__subcategory_1928_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1928_data__age`
--
ALTER TABLE `datatable__subcategory_1928_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1949_data`
--
ALTER TABLE `datatable__subcategory_1949_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1949_data__age`
--
ALTER TABLE `datatable__subcategory_1949_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1965_data`
--
ALTER TABLE `datatable__subcategory_1965_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_1965_data__age`
--
ALTER TABLE `datatable__subcategory_1965_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2032_data`
--
ALTER TABLE `datatable__subcategory_2032_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2032_data__age`
--
ALTER TABLE `datatable__subcategory_2032_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2072_data`
--
ALTER TABLE `datatable__subcategory_2072_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2072_data__age`
--
ALTER TABLE `datatable__subcategory_2072_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2096_data`
--
ALTER TABLE `datatable__subcategory_2096_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2096_data__age`
--
ALTER TABLE `datatable__subcategory_2096_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2155_data`
--
ALTER TABLE `datatable__subcategory_2155_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2155_data__age`
--
ALTER TABLE `datatable__subcategory_2155_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2165_data`
--
ALTER TABLE `datatable__subcategory_2165_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2165_data__age`
--
ALTER TABLE `datatable__subcategory_2165_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2166_data`
--
ALTER TABLE `datatable__subcategory_2166_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_2166_data__age`
--
ALTER TABLE `datatable__subcategory_2166_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_CACHE_data`
--
ALTER TABLE `datatable__subcategory_CACHE_data`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__subcategory_CACHE_data__age`
--
ALTER TABLE `datatable__subcategory_CACHE_data__age`
  ADD PRIMARY KEY (`user_id`),
  ADD UNIQUE KEY `user_id` (`user_id`);

--
-- Индексы таблицы `datatable__system_stats`
--
ALTER TABLE `datatable__system_stats`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `datatable__user_data`
--
ALTER TABLE `datatable__user_data`
  ADD PRIMARY KEY (`user_id`);

--
-- Индексы таблицы `datatable__user_data__age`
--
ALTER TABLE `datatable__user_data__age`
  ADD PRIMARY KEY (`user_id`);

--
-- Индексы таблицы `data_processing_crons`
--
ALTER TABLE `data_processing_crons`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `descriptor_TEMP_JC`
--
ALTER TABLE `descriptor_TEMP_JC`
  ADD PRIMARY KEY (`id`),
  ADD KEY `indx1` (`descriptor`,`address`,`city`);

--
-- Индексы таблицы `descriptor_TEMP_JC_RM`
--
ALTER TABLE `descriptor_TEMP_JC_RM`
  ADD KEY `index1` (`descriptor`),
  ADD KEY `index2` (`address`),
  ADD KEY `index3` (`city`);

--
-- Индексы таблицы `match_history_chains`
--
ALTER TABLE `match_history_chains`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_matched_store_id` (`_matched_chain_id`,`_raw_transaction_id`),
  ADD KEY `fk_match_history__matched_store_id` (`_matched_chain_id`),
  ADD KEY `fk_match_history__raw_transaction_id` (`_raw_transaction_id`);

--
-- Индексы таблицы `match_history_stores`
--
ALTER TABLE `match_history_stores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_matched_store_id` (`_matched_store_id`,`_raw_transaction_id`),
  ADD KEY `fk_match_history__matched_store_id` (`_matched_store_id`),
  ADD KEY `fk_match_history__raw_transaction_id` (`_raw_transaction_id`);

--
-- Индексы таблицы `payee_distinct_temp_jc`
--
ALTER TABLE `payee_distinct_temp_jc`
  ADD KEY `indx2` (`payee_name`),
  ADD FULLTEXT KEY `indx1` (`payee_name`);

--
-- Индексы таблицы `plaid_access_token`
--
ALTER TABLE `plaid_access_token`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`_bank_id`,`bank_code`,`is_active`);

--
-- Индексы таблицы `plaid_categories`
--
ALTER TABLE `plaid_categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `plaid_category_matches`
--
ALTER TABLE `plaid_category_matches`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `plaid_sub_category_id` (`plaid_sub_category_id`,`_clout_sub_category_id`);

--
-- Индексы таблицы `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `owner_id` (`owner_id`,`owner_type`,`promotion_type`,`start_score`,`end_score`,`name`,`start_date`,`end_date`,`cash_back_percentage`,`description`);

--
-- Индексы таблицы `promotion_notices`
--
ALTER TABLE `promotion_notices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_promotion_id` (`_promotion_id`,`_user_id`);

--
-- Индексы таблицы `promotion_rules`
--
ALTER TABLE `promotion_rules`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_promotion_rules__promotion_id` (`_promotion_id`);

--
-- Индексы таблицы `queries`
--
ALTER TABLE `queries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `score_criteria`
--
ALTER TABLE `score_criteria`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `score_levels`
--
ALTER TABLE `score_levels`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `score_tracking_clout`
--
ALTER TABLE `score_tracking_clout`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_score_tracking_clout__user_id` (`_user_id`);

--
-- Индексы таблицы `score_tracking_stores`
--
ALTER TABLE `score_tracking_stores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_score_tracking_stores__store_id` (`_store_id`),
  ADD KEY `fk_score_tracking_stores__user_id` (`_user_id`);

--
-- Индексы таблицы `store_match_patterns`
--
ALTER TABLE `store_match_patterns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`command`,`name_pattern`,`address_pattern`);

--
-- Индексы таблицы `store_match_patterns_bk`
--
ALTER TABLE `store_match_patterns_bk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`command`,`name_pattern`,`address_pattern`);

--
-- Индексы таблицы `store_match_rules`
--
ALTER TABLE `store_match_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`rule_type`,`match_store_id`,`descriptor_id`,`details`);

--
-- Индексы таблицы `store_match_rule_patterns`
--
ALTER TABLE `store_match_rule_patterns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`command`,`name_pattern`,`address_pattern`,`city_pattern`) USING BTREE,
  ADD FULLTEXT KEY `name_pattern` (`name_pattern`);

--
-- Индексы таблицы `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_bk`
--
ALTER TABLE `transactions_bk`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_match_jobs`
--
ALTER TABLE `transactions_match_jobs`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transactions_match_jobs_run1`
--
ALTER TABLE `transactions_match_jobs_run1`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transactions_match_jobs_run2`
--
ALTER TABLE `transactions_match_jobs_run2`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transactions_match_jobs_run3`
--
ALTER TABLE `transactions_match_jobs_run3`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transactions_raw`
--
ALTER TABLE `transactions_raw`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`,`_user_id`,`_bank_id`),
  ADD KEY `indx_name_address` (`address`,`city`,`payee_name`),
  ADD FULLTEXT KEY `payee_name` (`payee_name`);

--
-- Индексы таблицы `transactions_raw_TEMP_AZ`
--
ALTER TABLE `transactions_raw_TEMP_AZ`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`,`_user_id`,`_bank_id`),
  ADD KEY `indx_name_address` (`address`,`city`,`payee_name`),
  ADD FULLTEXT KEY `payee_name` (`payee_name`);

--
-- Индексы таблицы `transactions_raw_TEMP_KU`
--
ALTER TABLE `transactions_raw_TEMP_KU`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`,`_user_id`,`_bank_id`),
  ADD KEY `indx_name_address` (`address`,`city`,`payee_name`),
  ADD FULLTEXT KEY `payee_name` (`payee_name`);

--
-- Индексы таблицы `transactions_raw_TEMP_KU2`
--
ALTER TABLE `transactions_raw_TEMP_KU2`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`,`_user_id`,`_bank_id`),
  ADD KEY `indx_name_address` (`address`,`city`,`payee_name`),
  ADD FULLTEXT KEY `payee_name` (`payee_name`);

--
-- Индексы таблицы `transactions_run1`
--
ALTER TABLE `transactions_run1`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_run2`
--
ALTER TABLE `transactions_run2`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_run3`
--
ALTER TABLE `transactions_run3`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_TEMP_JC`
--
ALTER TABLE `transactions_TEMP_JC`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_TEMP_KU`
--
ALTER TABLE `transactions_TEMP_KU`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transactions_TEMP_KU2`
--
ALTER TABLE `transactions_TEMP_KU2`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_transactions__store_id` (`_store_id`),
  ADD KEY `fk_transactions__user_id` (`_user_id`),
  ADD KEY `fk_transactions__raw_id` (`_raw_id`),
  ADD KEY `fk_transactions__related_promotion_id` (`_related_promotion_id`),
  ADD KEY `fk_transactions__bank_id` (`_bank_id`);

--
-- Индексы таблицы `transaction_descriptors`
--
ALTER TABLE `transaction_descriptors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `description` (`description`),
  ADD FULLTEXT KEY `descriptor_index` (`description`);

--
-- Индексы таблицы `transaction_descriptors_suggested_stores`
--
ALTER TABLE `transaction_descriptors_suggested_stores`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_descriptor_id` (`_transaction_descriptor_id`,`suggested_store_id`,`store_id`);

--
-- Индексы таблицы `transaction_descriptor_chains`
--
ALTER TABLE `transaction_descriptor_chains`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transaction_descriptor_scopes`
--
ALTER TABLE `transaction_descriptor_scopes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transaction_descriptor_sub_categories`
--
ALTER TABLE `transaction_descriptor_sub_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_descriptor_id` (`_descriptor_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_descriptor_sub_categories_suggestions`
--
ALTER TABLE `transaction_descriptor_sub_categories_suggestions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_descriptor_id` (`_descriptor_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_descriptor_transactions`
--
ALTER TABLE `transaction_descriptor_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transaction_sub_categories`
--
ALTER TABLE `transaction_sub_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_sub_categories_bk`
--
ALTER TABLE `transaction_sub_categories_bk`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_sub_categories_run1`
--
ALTER TABLE `transaction_sub_categories_run1`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_sub_categories_run2`
--
ALTER TABLE `transaction_sub_categories_run2`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_sub_categories_run3`
--
ALTER TABLE `transaction_sub_categories_run3`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `transaction_sub_categories_TEMP_KU`
--
ALTER TABLE `transaction_sub_categories_TEMP_KU`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_transaction_id` (`_transaction_id`,`_sub_category_id`);

--
-- Индексы таблицы `user_cash_tracking`
--
ALTER TABLE `user_cash_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_cash_tracking__user_id` (`_user_id`),
  ADD KEY `fk_user_cash_tracking__bank_account_id` (`_bank_account_id`);

--
-- Индексы таблицы `user_credit_tracking`
--
ALTER TABLE `user_credit_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_credit_tracking__user_id` (`_user_id`),
  ADD KEY `fk_user_credit_tracking__bank_account_id` (`_bank_account_id`);

--
-- Индексы таблицы `user_payment_tracking`
--
ALTER TABLE `user_payment_tracking`
  ADD KEY `fk_user_payment_tracking__user_id` (`_user_id`),
  ADD KEY `fk_user_payment_tracking__entered_by` (`_entered_by`),
  ADD KEY `fk_user_payment_tracking__last_updated_by` (`_last_updated_by`);

--
-- Индексы таблицы `zipcodes`
--
ALTER TABLE `zipcodes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_zipcodes__country_code` (`_country_code`),
  ADD KEY `fk_zipcodes__state_id` (`state_id`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `advert_and_promo_tracking`
--
ALTER TABLE `advert_and_promo_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `banks`
--
ALTER TABLE `banks`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `banks_raw`
--
ALTER TABLE `banks_raw`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `bank_accounts`
--
ALTER TABLE `bank_accounts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `bank_accounts_credit_raw`
--
ALTER TABLE `bank_accounts_credit_raw`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT для таблицы `bank_accounts_other_raw`
--
ALTER TABLE `bank_accounts_other_raw`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `cacheview__promotions_summary`
--
ALTER TABLE `cacheview__promotions_summary`
  MODIFY `table_id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1049;
--
-- AUTO_INCREMENT для таблицы `cacheview__store_scores_previous`
--
ALTER TABLE `cacheview__store_scores_previous`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `cacheview__where_user_shopped`
--
ALTER TABLE `cacheview__where_user_shopped`
  MODIFY `table_id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=74;
--
-- AUTO_INCREMENT для таблицы `chain_match_rules`
--
ALTER TABLE `chain_match_rules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=32;
--
-- AUTO_INCREMENT для таблицы `commissions_alerts`
--
ALTER TABLE `commissions_alerts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `commissions_network`
--
ALTER TABLE `commissions_network`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `commissions_transactions`
--
ALTER TABLE `commissions_transactions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `commissions_transfers`
--
ALTER TABLE `commissions_transfers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `cron_external_schedule`
--
ALTER TABLE `cron_external_schedule`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `cron_log`
--
ALTER TABLE `cron_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `cron_schedule`
--
ALTER TABLE `cron_schedule`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT для таблицы `datatable__store_chain_CACHE_data`
--
ALTER TABLE `datatable__store_chain_CACHE_data`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `datatable__system_stats`
--
ALTER TABLE `datatable__system_stats`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `data_processing_crons`
--
ALTER TABLE `data_processing_crons`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `descriptor_TEMP_JC`
--
ALTER TABLE `descriptor_TEMP_JC`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `match_history_chains`
--
ALTER TABLE `match_history_chains`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT для таблицы `match_history_stores`
--
ALTER TABLE `match_history_stores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3469;
--
-- AUTO_INCREMENT для таблицы `plaid_access_token`
--
ALTER TABLE `plaid_access_token`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=50;
--
-- AUTO_INCREMENT для таблицы `plaid_categories`
--
ALTER TABLE `plaid_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `plaid_category_matches`
--
ALTER TABLE `plaid_category_matches`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `promotions`
--
ALTER TABLE `promotions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=274;
--
-- AUTO_INCREMENT для таблицы `promotion_notices`
--
ALTER TABLE `promotion_notices`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=76;
--
-- AUTO_INCREMENT для таблицы `promotion_rules`
--
ALTER TABLE `promotion_rules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `queries`
--
ALTER TABLE `queries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=487;
--
-- AUTO_INCREMENT для таблицы `score_levels`
--
ALTER TABLE `score_levels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `score_tracking_clout`
--
ALTER TABLE `score_tracking_clout`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `score_tracking_stores`
--
ALTER TABLE `score_tracking_stores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `store_match_patterns`
--
ALTER TABLE `store_match_patterns`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8336;
--
-- AUTO_INCREMENT для таблицы `store_match_patterns_bk`
--
ALTER TABLE `store_match_patterns_bk`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `store_match_rules`
--
ALTER TABLE `store_match_rules`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `store_match_rule_patterns`
--
ALTER TABLE `store_match_rule_patterns`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transactions_bk`
--
ALTER TABLE `transactions_bk`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8173;
--
-- AUTO_INCREMENT для таблицы `transactions_match_jobs`
--
ALTER TABLE `transactions_match_jobs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT для таблицы `transactions_match_jobs_run1`
--
ALTER TABLE `transactions_match_jobs_run1`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `transactions_match_jobs_run2`
--
ALTER TABLE `transactions_match_jobs_run2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT для таблицы `transactions_match_jobs_run3`
--
ALTER TABLE `transactions_match_jobs_run3`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT для таблицы `transactions_raw`
--
ALTER TABLE `transactions_raw`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29869;
--
-- AUTO_INCREMENT для таблицы `transactions_raw_TEMP_AZ`
--
ALTER TABLE `transactions_raw_TEMP_AZ`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29869;
--
-- AUTO_INCREMENT для таблицы `transactions_raw_TEMP_KU`
--
ALTER TABLE `transactions_raw_TEMP_KU`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29869;
--
-- AUTO_INCREMENT для таблицы `transactions_raw_TEMP_KU2`
--
ALTER TABLE `transactions_raw_TEMP_KU2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=21793;
--
-- AUTO_INCREMENT для таблицы `transactions_run1`
--
ALTER TABLE `transactions_run1`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transactions_run2`
--
ALTER TABLE `transactions_run2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transactions_run3`
--
ALTER TABLE `transactions_run3`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transactions_TEMP_JC`
--
ALTER TABLE `transactions_TEMP_JC`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=18289;
--
-- AUTO_INCREMENT для таблицы `transactions_TEMP_KU`
--
ALTER TABLE `transactions_TEMP_KU`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transactions_TEMP_KU2`
--
ALTER TABLE `transactions_TEMP_KU2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptors`
--
ALTER TABLE `transaction_descriptors`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=63;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptors_suggested_stores`
--
ALTER TABLE `transaction_descriptors_suggested_stores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptor_chains`
--
ALTER TABLE `transaction_descriptor_chains`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptor_scopes`
--
ALTER TABLE `transaction_descriptor_scopes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptor_sub_categories`
--
ALTER TABLE `transaction_descriptor_sub_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=46;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptor_sub_categories_suggestions`
--
ALTER TABLE `transaction_descriptor_sub_categories_suggestions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_descriptor_transactions`
--
ALTER TABLE `transaction_descriptor_transactions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories`
--
ALTER TABLE `transaction_sub_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories_bk`
--
ALTER TABLE `transaction_sub_categories_bk`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=9871;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories_run1`
--
ALTER TABLE `transaction_sub_categories_run1`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories_run2`
--
ALTER TABLE `transaction_sub_categories_run2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories_run3`
--
ALTER TABLE `transaction_sub_categories_run3`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `transaction_sub_categories_TEMP_KU`
--
ALTER TABLE `transaction_sub_categories_TEMP_KU`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `user_cash_tracking`
--
ALTER TABLE `user_cash_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `user_credit_tracking`
--
ALTER TABLE `user_credit_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `zipcodes`
--
ALTER TABLE `zipcodes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=49188;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
