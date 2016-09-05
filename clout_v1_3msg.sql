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
-- База данных: `clout_v1_3msg`
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
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `activity_log`
--

INSERT INTO `activity_log` (`id`, `user_id`, `activity_code`, `result`, `uri`, `log_details`, `device`, `ip_address`, `event_time`) VALUES
(1, 45, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Website Message From Al Zious|sent_to=|sent_by=al.zziwa@tech.gov (Aloy Zziwa)', '', '127.0.0.1', '2016-03-01 13:07:27'),
(2, 74, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=cruzw@clout.com (Cruz)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-14 18:27:22'),
(3, 75, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=khimu@clout.com (khim)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-20 22:06:06'),
(4, 75, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=khimu@clout.com (khim)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-20 22:25:32'),
(5, 75, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=khimu@clout.com (khim)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-20 22:40:26'),
(6, 75, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=khimu@clout.com (khim)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-20 23:01:10'),
(7, 75, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=khimu@clout.com (khim)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-20 23:01:12'),
(8, 76, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=dimitri.rokha@gmail.com (Dmytro)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-26 12:22:16'),
(9, 76, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=dimitri.rokha@gmail.com (Dmytro)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-26 12:37:08'),
(10, 76, 'sms__message_sent', 'SUCCESS', 'main/index', 'message=Your Verification Code For Your Clout Account|sent_to=dimitri.rokha@gmail.com (Dmytro)|sent_by=no-reply@clout.com (Clout)', '', '192.168.88.251', '2016-04-26 12:37:31'),
(11, 50, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogbog@ram.ru (bogdan)|sent_by=no-reply@clout.com (Clout)', '', '127.0.0.1', '2016-08-18 22:42:39'),
(12, 51, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogggbo@ram.ru (dfgdgdfg)|sent_by=no-reply@clout.com (Clout)', '', '127.0.0.1', '2016-08-18 22:47:14'),
(13, 52, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogbogfff@ram.ru (ddddddd)|sent_by=no-reply@clout.com (Clout)', '', '127.0.0.1', '2016-08-18 23:27:35'),
(14, 53, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bog@ram.ru (bogdan)|sent_by=no-reply@clout.com (Clout)', '', '127.0.0.1', '2016-08-18 23:38:01'),
(15, 54, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bog@ram.ru (bogdan)|sent_by=no-reply@clout.com (Clout)', '', '127.0.0.1', '2016-08-18 23:59:30'),
(16, 55, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=gggobboggo@ram.ru (gfdgdfgdfgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 02:30:56'),
(17, 56, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=fgooo@ram.rtu (ertertret)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:05:28'),
(18, 57, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=etertt@rrr.ru (rtertert)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:09:38'),
(19, 58, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=fsdfsdf@ram.ru (sdfsdfsdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:11:20'),
(20, 59, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=boggo@ram.ru (ertertert)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:14:34'),
(21, 60, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=boggoo@ram.ru (dfgdfgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:17:29'),
(22, 61, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=fffobnbono@ram.ru (aaaaaaaaaaaa)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:25:47'),
(23, 62, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=ggobgo@ram.ru (dfsdfsdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:28:30'),
(24, 63, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (fdgdfgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:47:18'),
(25, 68, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (gdfgdfgdfgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 03:59:29'),
(26, 69, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (dgfdfgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:06:22'),
(27, 70, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (dfgdgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:15:12'),
(28, 71, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (dfgdfgf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:18:16'),
(29, 72, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (sdfsdfsdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:21:17'),
(30, 73, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdfdf@df.com (dfgdfgdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:24:43'),
(31, 74, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogdandvini@gmail.com (fdgfdgdfg)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:31:43'),
(32, 75, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bog@fdfsdfsdf.ram (fsdfsdfsdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:41:58'),
(33, 76, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=boggfgdfgo@ram.ru (rfgdfgdf)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:47:22'),
(34, 77, 'email__message_sent', 'SUCCESS', 'main/index', 'message=Your Clout Account Verification Link|sent_to=bogoo@fsdfds.com (alert&amp;#40;234&amp;#41;)|sent_by=no-reply@clout.com (Clout)', '', '192.168.0.130', '2016-08-19 04:49:09');

-- --------------------------------------------------------

--
-- Структура таблицы `contact_emails`
--

CREATE TABLE IF NOT EXISTS `contact_emails` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `is_primary` enum('Y','N') NOT NULL DEFAULT 'N',
  `activation_code` varchar(500) NOT NULL,
  `date_entered` datetime NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `contact_emails`
--

INSERT INTO `contact_emails` (`id`, `_user_id`, `email_address`, `is_primary`, `activation_code`, `date_entered`, `is_active`) VALUES
(2, 1, 'azziwa@timbukutu.com', 'N', 'c5e8754637504e5ebf868efc915ae09cb8ba1c3b', '2015-10-07 11:47:07', 'Y'),
(3, 1, 'azziwa@timbukutu.org', 'N', '5caa47a3e35d5c847e2666a8f9c82c5287640e40', '2015-10-07 11:49:20', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `contact_phones`
--

CREATE TABLE IF NOT EXISTS `contact_phones` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_provider_id` bigint(20) DEFAULT NULL,
  `telephone` varchar(100) NOT NULL,
  `is_primary` enum('Y','N') NOT NULL DEFAULT 'N',
  `activation_code` varchar(500) NOT NULL,
  `date_entered` datetime NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `contact_phones`
--

INSERT INTO `contact_phones` (`id`, `_user_id`, `_provider_id`, `telephone`, `is_primary`, `activation_code`, `date_entered`, `is_active`) VALUES
(3, 1, 0, '2348902344', 'N', '5caa47a3e35d5c847e2666a8f9c82c5287640e40', '2015-10-07 11:56:58', 'Y'),
(4, 1, 0, '89792374234', 'N', 'a031eb6d2f6330f89b937098d4439578421617df', '2015-10-07 12:00:48', 'N'),
(5, 1, NULL, '94674567456', 'N', '0708fb5f0cd29753792787e8c0e0479aade4ec0d', '2015-10-07 12:05:30', 'Y'),
(6, 1, 4, '78903709450', 'N', 'c634a167030b9baca992d8a88ae52b909833dd12', '2015-10-07 12:06:57', 'Y'),
(7, 1, 1, '12323423332', 'N', '83de061fb52099b8b9b03b3ae4e888d6b10d9e5e', '2015-10-07 12:09:44', 'N'),
(8, 1, 1, '70293483455', 'N', 'bfac6a4b8fac8cc5337c3e58459324c560cfea67', '2015-10-07 13:47:21', 'Y'),
(40, 18, 2, '6786442425', 'Y', '', '2015-12-16 15:53:59', 'N'),
(55, 21, 2, '6786442425', 'N', '', '0000-00-00 00:00:00', 'Y'),
(58, 23, 1, '678324452', 'N', '', '0000-00-00 00:00:00', 'Y'),
(69, 44, 2, '6786442425', 'N', '', '0000-00-00 00:00:00', 'Y'),
(70, 50, 9, '5345435345', 'N', '', '0000-00-00 00:00:00', 'Y'),
(71, 51, 10, '34534534535', 'N', '', '0000-00-00 00:00:00', 'Y'),
(72, 52, 8, '2342343243', 'N', '', '0000-00-00 00:00:00', 'Y'),
(73, 53, 8, '4543534534', 'N', '', '0000-00-00 00:00:00', 'Y'),
(74, 54, 8, '3453453453', 'N', '', '0000-00-00 00:00:00', 'Y'),
(75, 55, 9, '4234234234', 'N', '', '0000-00-00 00:00:00', 'Y'),
(76, 56, 9, '34534534535', 'N', '', '0000-00-00 00:00:00', 'Y'),
(77, 57, 8, '3453453453', 'N', '', '0000-00-00 00:00:00', 'Y'),
(78, 58, 9, '4534534534', 'N', '', '0000-00-00 00:00:00', 'Y'),
(79, 59, 10, '43534534355', 'N', '', '0000-00-00 00:00:00', 'Y'),
(80, 60, 8, '2342342342', 'N', '', '0000-00-00 00:00:00', 'Y'),
(81, 61, 10, '3343242342', 'N', '', '0000-00-00 00:00:00', 'Y'),
(82, 62, 8, '3453453453', 'N', '', '0000-00-00 00:00:00', 'Y'),
(83, 63, 9, '2342342343', 'N', '', '0000-00-00 00:00:00', 'Y'),
(84, 68, 7, '5345345345', 'N', '', '0000-00-00 00:00:00', 'Y'),
(85, 69, 9, '3234234234', 'N', '', '0000-00-00 00:00:00', 'Y'),
(86, 70, 9, '4453453453', 'N', '', '0000-00-00 00:00:00', 'Y'),
(87, 71, 8, '2342242343', 'N', '', '0000-00-00 00:00:00', 'Y'),
(88, 72, 7, '2342342343', 'N', '', '0000-00-00 00:00:00', 'Y'),
(89, 73, 10, '234234234234', 'N', '', '0000-00-00 00:00:00', 'Y'),
(90, 74, 9, '3423423423', 'N', '', '0000-00-00 00:00:00', 'Y'),
(91, 75, 7, '3324234324', 'N', '', '0000-00-00 00:00:00', 'Y'),
(92, 76, 3, '2342342342', 'N', '', '0000-00-00 00:00:00', 'Y'),
(93, 77, 6, '2334234234', 'N', '', '0000-00-00 00:00:00', 'Y'),
(94, 78, 123123, '123123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(95, 80, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(96, 82, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(97, 83, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(98, 84, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(99, 86, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(100, 87, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(101, 88, 1235123, '1235123', 'N', '', '0000-00-00 00:00:00', 'Y'),
(102, 89, 0, '4345564564', 'N', '', '0000-00-00 00:00:00', 'Y'),
(103, 90, 0, '', 'N', '', '0000-00-00 00:00:00', 'Y'),
(104, 91, 123123, '123123', 'N', '', '0000-00-00 00:00:00', 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `contact_phone_providers`
--

CREATE TABLE IF NOT EXISTS `contact_phone_providers` (
  `id` bigint(20) NOT NULL,
  `full_carrier_name` varchar(250) NOT NULL,
  `carrier_name` varchar(100) NOT NULL,
  `country_code` varchar(10) NOT NULL DEFAULT 'USA',
  `carrier_logo_url` varchar(200) NOT NULL,
  `sms_email_domain` varchar(250) NOT NULL,
  `mms_email_domain` varchar(250) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `contact_phone_providers`
--

INSERT INTO `contact_phone_providers` (`id`, `full_carrier_name`, `carrier_name`, `country_code`, `carrier_logo_url`, `sms_email_domain`, `mms_email_domain`) VALUES
(1, 'Verizon Wireless', 'Verizon', 'USA', '', 'vtext.com', ''),
(2, 'AT&amp;T Mobility', 'AT&T', 'USA', '', 'txt.att.net', 'mms.att.net'),
(3, 'Sprint Corporation', 'Sprint', 'USA', '', 'messaging.sprintpcs.com', 'pm.sprint.com'),
(4, 'T-Mobile US', 'T-Mobile', 'USA', '', 'tmomail.net', ''),
(5, 'U.S. Cellular', 'U.S. Cellular', 'USA', '', 'email.uscc.net', ''),
(6, 'Alltel', '', 'USA', '', 'message.alltel.com', ''),
(7, 'BellSouth Mobility', '', 'USA', '', 'blsdcs.net', ''),
(8, 'Blue Sky Frog', '', 'USA', '', 'blueskyfrog.com', ''),
(9, 'Boost Mobile', '', 'USA', '', 'myboostmobile.com', ''),
(10, 'Cellular South', '', 'USA', '', 'csouth1.com', '');

-- --------------------------------------------------------

--
-- Структура таблицы `mail_hosts`
--

CREATE TABLE IF NOT EXISTS `mail_hosts` (
  `id` bigint(20) NOT NULL,
  `domain` varchar(300) NOT NULL,
  `host_url` varchar(300) NOT NULL,
  `port` varchar(10) NOT NULL,
  `actual_url` varchar(300) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `mail_hosts`
--

INSERT INTO `mail_hosts` (`id`, `domain`, `host_url`, `port`, `actual_url`, `date_entered`) VALUES
(1, 'gmail.com', 'imap.gmail.com', '993', '{imap.gmail.com:993/imap/ssl/novalidate-cert/norsh}INBOX', '0000-00-00 00:00:00'),
(2, 'yahoo.com', 'imap.mail.yahoo.com', '993', '{imap.mail.yahoo.com:993/imap/ssl}INBOX', '0000-00-00 00:00:00'),
(3, 'aol.com3', 'imap.aol.com', '993', '', '0000-00-00 00:00:00'),
(4, 'live.com', 'pop3.live.com', '995', '', '0000-00-00 00:00:00'),
(5, 'clout.com', 'imap.gmail.com', '993', '', '0000-00-00 00:00:00'),
(6, 'hotmail.com', 'pop3.live.com', '995', '', '0000-00-00 00:00:00'),
(7, 'outlook.com', 'pop3.live.com', '995', '', '0000-00-00 00:00:00'),
(8, 'ntlworld.com', 'pop.ntlworld.com', '995', '', '0000-00-00 00:00:00'),
(9, 'btconnect.com', 'pop3.btconnect.com', '995', '', '0000-00-00 00:00:00'),
(10, '1and1.com', 'imap.1and1.com', '993', '', '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `message_exchange`
--

CREATE TABLE IF NOT EXISTS `message_exchange` (
  `id` bigint(20) NOT NULL,
  `template_id` bigint(20) DEFAULT NULL,
  `template_type` enum('system','user') NOT NULL DEFAULT 'system',
  `details` text NOT NULL,
  `subject` varchar(300) NOT NULL,
  `sms` varchar(200) NOT NULL,
  `attachment_url` varchar(300) NOT NULL,
  `_sender_id` bigint(20) DEFAULT NULL,
  `sender_type` enum('user','store','chain') NOT NULL DEFAULT 'user',
  `_recipient_id` bigint(20) DEFAULT NULL,
  `cashback` float NOT NULL,
  `is_perk` enum('Y','N') NOT NULL DEFAULT 'N',
  `_category_id` bigint(20) NOT NULL,
  `scheduled_send_date` datetime NOT NULL,
  `send_date` datetime NOT NULL,
  `send_system` enum('Y','N') NOT NULL DEFAULT 'Y',
  `send_email` enum('Y','N') NOT NULL DEFAULT 'N',
  `send_sms` enum('Y','N') NOT NULL DEFAULT 'N',
  `send_system_result` enum('pending','success','fail') NOT NULL DEFAULT 'pending',
  `send_email_result` enum('pending','success','fail') NOT NULL DEFAULT 'pending',
  `send_sms_result` enum('pending','success','fail') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_exchange`
--

INSERT INTO `message_exchange` (`id`, `template_id`, `template_type`, `details`, `subject`, `sms`, `attachment_url`, `_sender_id`, `sender_type`, `_recipient_id`, `cashback`, `is_perk`, `_category_id`, `scheduled_send_date`, `send_date`, `send_system`, `send_email`, `send_sms`, `send_system_result`, `send_email_result`, `send_sms_result`, `date_entered`, `_entered_by`) VALUES
(1, 11, 'system', 'A message was submitted by Al Zious to Clout. The details:\r\n&lt;br&gt;\r\n&lt;br&gt;Name: Al Zious\r\n&lt;br&gt;Email: azziwa@gmail.com\r\n&lt;br&gt;Message: Al is checking this form again.\r\n&lt;br&gt;Date Sent: 03/01/2016 01:07PM\r\n&lt;br&gt;\r\n&lt;br&gt;Regards,\r\n&lt;br&gt;Your Clout Team\r\n&lt;br&gt;https://www.clout.com\r\n&lt;br&gt;\r\n&lt;br&gt;Message ID: 201603B010722\r\n', 'Website Message From Al Zious', '', '', 45, 'user', NULL, 0, 'N', 0, '0000-00-00 00:00:00', '2016-03-01 13:07:27', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-03-01 13:07:27', 45),
(2, 9, 'system', 'Hi fdgfdgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000004a\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089043143\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 74, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-14 18:27:22', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:31:43', 2),
(3, 9, 'system', 'Hi fsdfsdfsdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000004b\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089044158\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 75, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-20 22:06:06', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:41:58', 2),
(4, 9, 'system', 'Hi rfgdfgdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000004c\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089044722\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 76, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-26 12:22:16', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:47:22', 2),
(5, 0, 'user', 'test', 'test', 'test', '', 1, 'user', 74, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-27 15:41:00', 'Y', 'Y', 'Y', 'pending', 'pending', 'pending', '2016-04-27 15:40:42', 1),
(7, 0, 'user', 'sdfsdfsdf', 'sdfsdf', 'dsfsdfsdf', '', 1, 'user', 74, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-27 15:54:00', 'Y', 'Y', 'Y', 'pending', 'pending', 'pending', '2016-04-27 15:51:44', 1),
(8, 9, 'system', 'Hi alert&amp;#40;234&amp;#41;,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000004d\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089044909\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 77, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-28 15:56:45', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:49:09', 2),
(10, 9, 'system', 'Hi Rebecca,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://localhost:8888/clout-dev/dev-v1.3.2-web/u/CT000000004e\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016049040014\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 78, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-28 15:59:54', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-04-28 15:59:54', 2),
(11, 1, 'user', 'TESTING', 'TESTING', '', '', 1, 'user', 74, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-28 17:52:00', 'Y', 'Y', 'Y', 'pending', 'pending', 'pending', '2016-04-28 17:52:06', 1),
(12, 1, 'user', 'TESTING', 'TESTING', '', '', 1, 'user', 77, 0, 'N', 0, '0000-00-00 00:00:00', '2016-04-28 17:52:00', 'Y', 'Y', 'Y', 'pending', 'pending', 'pending', '2016-04-28 17:52:06', 1),
(13, 9, 'system', 'Hi bogdan,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000032\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089104239\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 50, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-18 22:42:39', 2),
(14, 9, 'system', 'Hi dfgdgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000033\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089104714\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 51, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-18 22:47:14', 2),
(15, 9, 'system', 'Hi ddddddd,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000034\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089112735\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 52, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-18 23:27:35', 2),
(16, 9, 'system', 'Hi bogdan,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000035\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089113801\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 53, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-18 23:38:01', 2),
(17, 9, 'system', 'Hi bogdan,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000036\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089115930\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 54, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-18 23:59:30', 2),
(18, 9, 'system', 'Hi gfdgdfgdfgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000037\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089023056\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 55, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 02:30:56', 2),
(19, 9, 'system', 'Hi ertertret,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000038\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089030528\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 56, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:05:28', 2),
(20, 9, 'system', 'Hi rtertert,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000039\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089030938\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 57, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:09:38', 2),
(21, 9, 'system', 'Hi sdfsdfsdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003a\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089031120\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 58, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:11:20', 2),
(22, 9, 'system', 'Hi ertertert,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003b\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089031434\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 59, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:14:34', 2),
(23, 9, 'system', 'Hi dfgdfgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003c\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089031729\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 60, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:17:29', 2),
(24, 9, 'system', 'Hi aaaaaaaaaaaa,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003d\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089032547\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 61, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:25:47', 2),
(25, 9, 'system', 'Hi dfsdfsdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003e\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089032830\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 62, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:28:30', 2),
(26, 9, 'system', 'Hi fdgdfgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT000000003f\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089034718\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 63, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:47:18', 2),
(27, 9, 'system', 'Hi gdfgdfgdfgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000044\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089035929\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 68, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 03:59:29', 2),
(28, 9, 'system', 'Hi dgfdfgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000045\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089040622\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 69, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:06:22', 2),
(29, 9, 'system', 'Hi dfgdgdfg,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000046\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089041512\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 70, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:15:12', 2),
(30, 9, 'system', 'Hi dfgdfgf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000047\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089041816\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 71, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:18:16', 2),
(31, 9, 'system', 'Hi sdfsdfsdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000048\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089042117\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 72, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:21:17', 2),
(32, 9, 'system', 'Hi dfgdfgdf,\n&lt;br&gt;\n&lt;br&gt;Your Clout account verification link is:\n&lt;br&gt;http://dev-web/u/CT0000000049\n&lt;br&gt;\n&lt;br&gt;Click on the link to activate your account or copy and paste it to your browser address to continue.\n&lt;br&gt;\n&lt;br&gt;Regards,\n&lt;br&gt;Your Clout Team\n&lt;br&gt;https://www.clout.com\n&lt;br&gt;\n&lt;br&gt;Message ID: 2016089042443\n', 'Your Clout Account Verification Link', '', '', 2, 'user', 73, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 'Y', 'N', 'N', 'success', 'pending', 'pending', '2016-08-19 04:24:43', 2);

-- --------------------------------------------------------

--
-- Структура таблицы `message_invites`
--

CREATE TABLE IF NOT EXISTS `message_invites` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `friend_id` varchar(100) NOT NULL,
  `first_name` varchar(100) NOT NULL,
  `middle_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `invite_message` varchar(300) NOT NULL,
  `join_link` varchar(500) NOT NULL,
  `email_address` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `method_used` enum('email','phone','other') NOT NULL DEFAULT 'other',
  `invitation_time` datetime NOT NULL,
  `referral_status` enum('accepted','pending','declined','cancelled') NOT NULL DEFAULT 'pending',
  `message_status` enum('pending','paused','cancelled','sent','read','bounced','unsubscribed','clicked') NOT NULL DEFAULT 'pending',
  `number_of_invitations` int(11) NOT NULL,
  `last_invitation_sent_on` datetime NOT NULL,
  `sent_at_ip_address` varchar(100) NOT NULL,
  `_invitation_sent_by` bigint(20) DEFAULT NULL,
  `blocked_invitation` enum('Y','N') NOT NULL DEFAULT 'N',
  `read_ip_address` varchar(100) NOT NULL,
  `read_location` varchar(300) NOT NULL,
  `read_zipcode` varchar(10) NOT NULL,
  `message_status_date` datetime NOT NULL,
  `referral_status_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_invites`
--

INSERT INTO `message_invites` (`id`, `_user_id`, `friend_id`, `first_name`, `middle_name`, `last_name`, `invite_message`, `join_link`, `email_address`, `phone_number`, `method_used`, `invitation_time`, `referral_status`, `message_status`, `number_of_invitations`, `last_invitation_sent_on`, `sent_at_ip_address`, `_invitation_sent_by`, `blocked_invitation`, `read_ip_address`, `read_location`, `read_zipcode`, `message_status_date`, `referral_status_date`) VALUES
(1, 1, '6', 'Al', '', 'Zziwa', 'Hey, Check this out', '', 'azziwa@gmail.com', '6786442425', 'email', '2015-10-01 00:00:00', 'accepted', 'read', 3, '2015-10-01 09:00:00', '0.0.0.0', 1, 'N', '0.0.0.0', 'Los Angeles', '90030', '2015-10-01 09:00:00', '2015-10-01 09:00:00'),
(2, 2, '', '', '', '', 'invitation_to_join_clout', '', 'noreply@clout.com', '', 'email', '2015-10-02 19:51:51', 'pending', 'bounced', 2, '2015-10-02 20:03:18', '99.59.233.60', 1, 'N', '', '', '', '2015-10-02 20:03:18', '2015-10-02 19:51:51'),
(5, 3, '', '', '', '', 'second_reminder_to_join_clout', '', 'sjane@yahoo.com', '', 'email', '2015-10-02 22:20:01', 'pending', 'bounced', 3, '2015-10-02 22:20:01', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:19', '2015-10-02 22:20:01'),
(6, 1, '', '', '', '', 'second_reminder_to_join_clout', '', 'felix@clout.com', '', 'email', '2015-10-03 15:36:26', 'pending', 'bounced', 3, '2015-10-03 15:36:26', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-03 15:36:26'),
(7, 5, '', '', '', '', 'second_reminder_to_join_clout', '', 'gmail@gmail.com', '', 'email', '2015-10-03 15:36:26', 'pending', 'bounced', 3, '2015-10-03 15:36:26', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-03 15:36:26'),
(8, 6, '', '', '', '', 'second_reminder_to_join_clout', '', 'tinga@yahoo.com', '', 'email', '2015-10-03 15:36:26', 'pending', 'bounced', 4, '2015-10-03 15:40:51', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-03 15:36:26'),
(9, 7, '', '', '', '', 'invitation_to_join_clout', '', 'admin@clout.com', '', 'email', '2015-10-03 15:38:36', 'pending', 'bounced', 2, '2015-10-03 15:40:51', '99.59.233.60', 1, 'N', '', '', '', '2015-10-03 15:40:51', '2015-10-03 15:38:36'),
(11, 8, '', '', '', '', 'second_reminder_to_join_clout', '', 'geringa@clout.com', '', 'email', '2015-10-03 15:38:36', 'pending', 'bounced', 3, '2015-10-03 15:38:36', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-03 15:38:36'),
(14, 9, '', '', '', '', 'second_reminder_to_join_clout', '', 'ingea@gmail.com', '', 'email', '2015-10-03 15:40:51', 'pending', 'bounced', 3, '2015-10-03 15:40:51', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-03 15:40:51'),
(15, 10, '', '', '', '', 'second_reminder_to_join_clout', '', 'kellog@yahoomail.com', '', 'email', '2015-10-21 15:27:09', 'pending', 'bounced', 3, '2015-10-21 15:27:09', '99.59.233.60', 1, 'N', '', '', '', '2015-12-17 19:16:20', '2015-10-21 15:27:09');

-- --------------------------------------------------------

--
-- Структура таблицы `message_likes`
--

CREATE TABLE IF NOT EXISTS `message_likes` (
  `id` bigint(20) NOT NULL,
  `_exchange_id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `user_like` enum('Y','N') NOT NULL DEFAULT 'N',
  `user_dislike` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_likes`
--

INSERT INTO `message_likes` (`id`, `_exchange_id`, `_user_id`, `user_like`, `user_dislike`, `date_entered`, `last_updated`) VALUES
(1, 17, 1, 'N', 'Y', '2015-10-07 17:45:34', '2015-10-07 17:50:32'),
(2, 19, 1, 'Y', 'N', '2015-10-07 17:45:34', '2015-10-07 17:47:28'),
(6, 16, 1, 'Y', 'N', '2015-10-07 17:48:27', '2015-10-07 17:50:06'),
(12, 18, 1, 'N', 'Y', '2015-10-07 17:50:32', '2015-10-07 17:50:32');

-- --------------------------------------------------------

--
-- Структура таблицы `message_status`
--

CREATE TABLE IF NOT EXISTS `message_status` (
  `id` bigint(20) NOT NULL,
  `_exchange_id` bigint(20) DEFAULT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `status` enum('received','read','replied','archived') NOT NULL DEFAULT 'received',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_status`
--

INSERT INTO `message_status` (`id`, `_exchange_id`, `_user_id`, `status`, `date_entered`) VALUES
(1, 15, 13, 'read', '2016-05-11 15:04:11'),
(2, 75, 1, 'received', '2016-05-11 17:00:00'),
(3, 55, 1, 'received', '2016-05-11 00:00:00'),
(4, 57, 1, 'received', '2016-05-11 17:00:00'),
(5, 61, 1, 'received', '2016-05-11 17:00:00'),
(6, 69, 1, 'received', '2016-05-11 17:00:00'),
(7, 55, 1, 'read', '2016-05-12 15:15:19'),
(8, 191, 1, 'read', '2016-06-13 14:57:52'),
(9, 188, 1, 'read', '2016-06-13 14:57:55'),
(10, 285, 1, 'read', '2016-06-22 17:50:55');

-- --------------------------------------------------------

--
-- Структура таблицы `message_templates`
--

CREATE TABLE IF NOT EXISTS `message_templates` (
  `id` bigint(20) NOT NULL,
  `message_type` varchar(100) NOT NULL,
  `subject` varchar(300) NOT NULL,
  `details` text NOT NULL,
  `sms` varchar(160) NOT NULL,
  `copy_admin` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_templates`
--

INSERT INTO `message_templates` (`id`, `message_type`, `subject`, `details`, `sms`, `copy_admin`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'user_defined_message', '_USER_DEFINED_SUBJECT_', '_USER_DEFINED_MESSAGE_', '_USER_DEFINED_SMS_', 'N', '2015-07-24 00:00:00', 1, '2015-07-24 00:00:00', 1),
(2, 'send_store_schedule', 'Reservation Made on Offer _PROMOTIONBARCODE_', 'A reservation has been made for _RESERVATIONNAME_ for the business at:\n<br>_STORENAME_\n<br>_STOREADDRESS_\n<br>\n<br>The details of the offer are:\n<br>Offer Bar Code Number: _PROMOTIONBARCODE_ (quote in future communication)\n<br>Offer Description: _OFFERDESCRIPTION_\n<br>Offer Conditions: _OFFERCONDITIONS_\n<br>\n<br>The details of the reservation are:\n<br>Reservation Date/Time: _RESERVATIONDATE_\n<br>Number in Party: _RESERVATIONNUMBER_\n<br>Contact Phone: _RESERVATIONPHONE_\n<br>Special Requests: _SPECIALREQUESTS_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', 'A reservation has been made for _RESERVATIONNAME_ (_RESERVATIONPHONE_) at _STORENAME_ (_STOREADDRESS_) on _RESERVATIONDATE_. Details in your Clout Inbox.', 'Y', '2015-07-25 00:00:00', 1, '2015-07-25 00:00:00', 1),
(3, 'send_verification_code', 'Your Verification Code For Your Clout Account', 'Hi _FIRSTNAME_,\n<br>Welcome to Clout!\n<br>\n<br>The verification code for your Clout account is:\n<br>_VERIFICATIONCODE_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', 'Welcome to Clout! The verification code for your Clout account is: _VERIFICATIONCODE_', 'N', '2015-09-07 00:00:00', 1, '2015-09-07 00:00:00', 1),
(4, 'new_store_scores', 'Your New Store Scores', 'Hi _FIRSTNAME_,\n<br>Your new store scores are: _EMAILSTRING_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', '_SMSSTRING_', 'N', '2015-09-07 00:00:00', 1, '2015-09-07 00:00:00', 1),
(5, 'data_import_complete', 'Your Data Import Has Completed', 'Hi _FIRSTNAME_,\n<br>\n<br>Your scores have been generated. \n<br>Please login to check your new scores and get more cashback offers.\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_\n', 'Your scores have been generated. Please login to check your new scores and get more cash back offers.', 'N', '2015-09-07 00:00:00', 1, '2015-09-07 00:00:00', 1),
(6, 'invitation_to_join_clout', '_FROMNAME_ sent you a private invite to CLOUT', '<b><u>This is a private invite to the Clout BETA.</u></b>  \n<br>Clout is not yet open to the general public.  Right now, we are allowing members to pass out 5 private invitations to their friends. \n<br>\n<br>- _FROMNAME_ picked you. \n<br>\n<br>What is Clout?...\n<br>\n<br><b><u>Clout automates VIP.</u></b>  \n<br>Clout makes it easy for you to automatically get better treatment from the merchants who value you the most.  Merchants on Clout can offer members <u>VIP treatment</u>, <u>special access</u>, <u>private invitations</u>, <u>cash back rewards</u>, <u>perks</u>, and more.  Rewards are given by the merchants, not the credit card company, so instead of getting a few points (or a few percent) you can get much more.  Simply sign up and link your credit and debit cards.  Clout keeps track of your rewards and seamlessly processes your cash back rewards back to the credit or debit card account you spent from when you spend at participating merchants.\n<br>\n<br>Its free to join and use. We hope you like it!\n<br>\n<br>Learn more and signup here:\n<br>_JOINLINK_\n<br>\n<br>Yours truly,\n<br><br>\nThe founding team at Clout\n<br>\n<br>Message ID: _MESSAGEID_', '_FROMNAME_ sent you a private invite to CLOUT', 'N', '2015-10-02 00:00:00', 1, '2015-10-02 00:00:00', 1),
(7, 'contact_activation_code', 'Your Contact Activation Code', 'Hi _FIRSTNAME_,\n<br>\n<br>Your _METHOD_ verification code for _CONTACTVALUE_ is:\n<br>_ACTIVATIONCODE_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', 'Your _METHOD_ verification code for _CONTACTVALUE_ is _ACTIVATIONCODE_', 'N', '2015-10-06 00:00:00', 1, '2015-10-06 00:00:00', 1),
(8, 'password_has_changed', 'Your Clout Password Has Changed', 'Hi _FIRSTNAME_,\n<br>\n<br>Your Clout password has been changed.\n<br>\n<br>If you did not change it or authorize this change, please contact us immediately on _SECURITYEMAIL_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', 'Your Clout password has been changed. If you did not make this change, please contact us now using _SECURITYEMAIL_', 'N', '2015-10-06 00:00:00', 1, '2015-10-06 00:00:00', 1),
(9, 'account_verification_link', 'Your Clout Account Verification Link', 'Hi _FIRSTNAME_,\n<br>\n<br>Your Clout account verification link is:\n<br>_VERIFICATIONLINK_\n<br>\n<br>Click on the link to activate your account or copy and paste it to your browser address to continue.\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_\n', 'Your clout account verification link is:\n_VERIFICATIONLINK_', 'N', '2015-10-02 00:00:00', 1, '2015-10-02 00:00:00', 1),
(10, 'password_recovery_link', 'Reset Your Clout Password Link', 'Hi _FIRSTNAME_,\n<br>\n<br>Go to the link below to reset your password:\n<br>_RECOVERYLINK_\n<br>\n<br>If you did not request this link, please contact us immediately on _SECURITYEMAIL_\n<br>\n<br>Regards,\n<br>Your Clout Team\n<br>_LOGINLINK_\n<br>\n<br>Message ID: _MESSAGEID_', 'Go to the link below to reset your password: _RECOVERYLINK_', 'N', '2015-10-06 00:00:00', 1, '2015-10-06 00:00:00', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `message_user_templates`
--

CREATE TABLE IF NOT EXISTS `message_user_templates` (
  `id` bigint(20) NOT NULL,
  `owner_id` varchar(100) NOT NULL,
  `owner_type` enum('user','store','chain') NOT NULL DEFAULT 'user',
  `name` varchar(300) NOT NULL,
  `subject` varchar(300) NOT NULL,
  `body` text NOT NULL,
  `sms` varchar(200) NOT NULL,
  `attachment` varchar(200) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `message_user_templates`
--

INSERT INTO `message_user_templates` (`id`, `owner_id`, `owner_type`, `name`, `subject`, `body`, `sms`, `attachment`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, '1', 'user', 'TESTING TEMPLATE', 'TESTING', 'TESTING', '', '', '2016-04-28 17:52:06', 1, '2016-04-28 17:52:06', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `notification_settings`
--

CREATE TABLE IF NOT EXISTS `notification_settings` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `email_address` varchar(300) NOT NULL,
  `first_name` varchar(250) NOT NULL,
  `last_name` varchar(250) NOT NULL,
  `sender_type` enum('user','store','chain') NOT NULL DEFAULT 'user',
  `send_me_adverts` enum('Y','N') NOT NULL DEFAULT 'N',
  `send_me_messages` enum('Y','N') NOT NULL DEFAULT 'Y',
  `send_me_system_messages` enum('Y','N') NOT NULL DEFAULT 'Y',
  `send_me_friend_messages` enum('Y','N') NOT NULL DEFAULT 'N',
  `send_me_other_user_messages` enum('Y','N') NOT NULL DEFAULT 'N',
  `categories_of_interest` text NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `notification_settings`
--

INSERT INTO `notification_settings` (`id`, `_user_id`, `email_address`, `first_name`, `last_name`, `sender_type`, `send_me_adverts`, `send_me_messages`, `send_me_system_messages`, `send_me_friend_messages`, `send_me_other_user_messages`, `categories_of_interest`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 'admin@clout.com', 'Clout', 'Admin', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 1),
(2, 2, 'noreply@clout.com', 'Clout', 'No-Reply', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 2),
(3, 12, 'azziwa@gmail.com', 'Almond', 'Zziwa', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 12),
(4, 13, 'azziwa@gmail.gov', 'Aloysious', 'Zziwa', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 13),
(5, 14, 'azziwa@gmail.me', 'Almond', 'Test 2', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 14),
(6, 18, 'al.zziwa@gmail.com', 'Albright', 'Zious', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 18),
(7, 21, 'jenny.c@gmail.com', 'Jenny', 'Craig', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 21),
(8, 23, 'tinga@gmail.com', 'Joseph', 'Tinga', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 11:23:10', 23),
(16, 30, 'al.felix@gmail.com', 'Al', 'Felix', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 15:10:57', 30),
(17, 31, 'al.felix@gmail.com', 'Al', 'Felix', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-02-17 15:28:57', 31),
(18, 50, 'bogbog@ram.ru', 'bogdan', 'dvinin', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-18 22:42:38', 50),
(19, 51, 'bogggbo@ram.ru', 'dfgdgdfg', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-18 22:47:13', 51),
(20, 52, 'bogbogfff@ram.ru', 'ddddddd', 'ggggggggggggg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-18 23:27:34', 52),
(21, 53, 'bog@ram.ru', 'bogdan', 'dvinin', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-18 23:38:00', 53),
(22, 54, 'bog@ram.ru', 'bogdan', 'dvinin', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-18 23:59:29', 54),
(23, 55, 'gggobboggo@ram.ru', 'gfdgdfgdfgdfg', 'dfgdfgdfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 02:30:56', 55),
(24, 56, 'fgooo@ram.rtu', 'ertertret', 'ertertert', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:05:28', 56),
(25, 57, 'etertt@rrr.ru', 'rtertert', 'ertertertert', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:09:37', 57),
(26, 58, 'fsdfsdf@ram.ru', 'sdfsdfsdf', 'sdfsdfsdfsd', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:11:20', 58),
(27, 59, 'boggo@ram.ru', 'ertertert', 'ertertertert', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:14:33', 59),
(28, 60, 'boggoo@ram.ru', 'dfgdfgdfg', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:17:29', 60),
(29, 61, 'fffobnbono@ram.ru', 'aaaaaaaaaaaa', 'abbbbbbbbbbbbb', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:25:46', 61),
(30, 62, 'ggobgo@ram.ru', 'dfsdfsdf', 'sdfsdfsdf', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:28:29', 62),
(32, 68, 'bogdandvini@gmail.com', 'gdfgdfgdfgdfg', 'dfgdfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 03:59:29', 68),
(33, 69, 'bogdandvini@gmail.com', 'dgfdfgdfg', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:06:22', 69),
(34, 70, 'bogdandvini@gmail.com', 'dfgdgdfg', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:15:11', 70),
(35, 71, 'bogdandvini@gmail.com', 'dfgdfgf', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:18:16', 71),
(36, 72, 'bogdandvini@gmail.com', 'sdfsdfsdf', 'sdfsdfsdfsdf', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:21:16', 72),
(37, 73, 'bogdfdf@df.com', 'dfgdfgdf', 'gdfgdfgdg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:24:42', 73),
(38, 74, 'bogdandvini@gmail.com', 'fdgfdgdfg', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:31:43', 74),
(39, 75, 'bog@fdfsdfsdf.ram', 'fsdfsdfsdf', 'sdfsdfsdf', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:41:57', 75),
(40, 76, 'boggfgdfgo@ram.ru', 'rfgdfgdf', 'dfgdfgdfg', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:47:22', 76),
(41, 77, 'bogoo@fsdfds.com', 'alert&amp;#40;234&amp;#41;', 'rwerwerwer', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-19 04:49:09', 77),
(42, 78, 'pulghjghjsar557@gmail.com', 'gjgjghj', 'ghjghjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:41:59', 78),
(43, 80, 'pul45tghjghjsar557@gmail.com', 'dt54f', 'ghjgt45hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:46:47', 80),
(44, 82, 'pul45tghjfghghjsar557@gmail.com', 'dht54f', 'ghhjgt45hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:47:27', 82),
(45, 83, 'pulf45tghjfghghjsar557@gmail.com', 'dht5f4f', 'ghhjgt4f5hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:50:13', 83),
(46, 84, 'pulf45tghgjfghghjsar557@gmail.com', 'dhgt5f4f', 'ghhjggt4f5hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:52:23', 84),
(47, 86, 'pulfgh45tghgjfghghjsar557@gmail.com', 'dhgght5f4f', 'ghhjghggt4f5hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:52:51', 86),
(48, 87, 'puglfgh45tghgjfghghjsar557@gmail.com', 'dhggght5f4f', 'ghhjgghggt4f5hjghj', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 02:53:26', 87),
(49, 89, '2016-12-23', 'perk', '4563456455462', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 04:03:55', 89),
(50, 90, '0', '', '', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 04:10:18', 90),
(51, 91, 'pulsahhhr557@gmail.com', 'afghsdas', 'asfghdasd', 'user', 'Y', 'Y', 'Y', 'N', 'N', '', '2016-08-23 04:11:43', 91);

-- --------------------------------------------------------

--
-- Структура таблицы `queries`
--

CREATE TABLE IF NOT EXISTS `queries` (
  `id` bigint(20) NOT NULL,
  `code` varchar(300) NOT NULL,
  `details` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=362 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `queries`
--

INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(1, 'get_message_templates', 'SELECT id AS template_id, subject, name, body, sms, \nIF(attachment <> '''', CONCAT(''_BASE_URL_'',attachment), '''') AS attachment \nFROM message_user_templates WHERE owner_id IN (''_OWNER_ID_'') AND owner_type=''_OWNER_TYPE_'' _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(22, 'get_sending_format', 'SELECT * FROM user_preferred_communication WHERE _user_id=''_USER_ID_'' AND message_type=''_MESSAGE_TYPE_'' AND message_format=''_MESSAGE_FORMAT_'''),
(25, 'add_event_log', 'INSERT INTO activity_log (user_id, activity_code, result, uri, log_details, ip_address, event_time)\nVALUES (''_USER_ID_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_IP_ADDRESS_'', NOW())'),
(26, 'get_message_template', 'SELECT *, copy_admin AS copyadmin FROM message_templates WHERE message_type=''_MESSAGE_TYPE_'''),
(27, 'get_provider_email_domain', 'SELECT IF(P.mms_email_domain <>'''',P.mms_email_domain,P.sms_email_domain) AS email_domain FROM contact_phones C LEFT JOIN contact_phone_providers P ON (C._provider_id=P.id AND C._user_id=''_USER_ID_'') WHERE telephone=''_TELEPHONE_''  HAVING email_domain IS NOT NULL LIMIT 1'),
(28, 'record_message_exchange', 'INSERT INTO message_exchange (template_id, template_type, details, `subject`, attachment_url, _sender_id, _recipient_id, send_system, send_system_result, scheduled_send_date, date_entered, _entered_by)\n\n(SELECT T.id AS template_id, ''system'' AS template_type, ''_DETAILS_'' AS details, ''_SUBJECT_'' AS `subject`, ''_ATTACHMENT_URL_'' AS attachment_url, \n''_SENDER_ID_'' AS _sender_id, \nN._user_id AS _recipient_id, ''Y'' AS send_system, ''success'' AS send_system_result, \nIF(''_SCHEDULED_SEND_DATE_'' <> '''', ''_SCHEDULED_SEND_DATE_'', ''0000-00-00 00:00:00'') AS scheduled_send_date, \nNOW() AS date_entered, \n''_SENDER_ID_'' AS _entered_by\nFROM message_templates T LEFT JOIN notification_settings N ON (N._user_id IN (''_RECIPIENT_ID_'') AND N.sender_type=''user'') WHERE T.message_type=''_TEMPLATE_CODE_'')\n\nON DUPLICATE KEY UPDATE `subject`=VALUES(`subject`), details=VALUES(details), attachment_url=VALUES(attachment_url), date_entered=VALUES(date_entered), scheduled_send_date=VALUES(scheduled_send_date);'),
(215, 'get_message_details', 'SELECT X.subject, X.details, X.sms, X.sender_type, X._recipient_id AS recipient_id, \nIF(X.attachment_url <> '''', CONCAT(''_DOWNLOAD_URL_'',X.attachment_url), '''') AS attachment_url, \nUNIX_TIMESTAMP(X.date_entered) AS date_received, \n\nIF(X.sender_type=''user'', (SELECT CONCAT(N.first_name,'' '',N.last_name) FROM notification_settings N WHERE N._user_id=X._recipient_id AND N.sender_type=''user''), \nIF(X.sender_type=''store'', (SELECT N.first_name FROM notification_settings N WHERE N._user_id=X._recipient_id AND N.sender_type=''store'' LIMIT 1), \nIF(X.sender_type=''chain'', (SELECT N.first_name FROM notification_settings N WHERE N._user_id=X._recipient_id AND N.sender_type=''chain'' LIMIT 1)\n, ''UNKNOWN''))) AS sender\n\nFROM message_exchange X \nWHERE X.id = ''_MESSAGE_ID_''\n\n'),
(216, 'add_message_status', 'INSERT INTO message_status (_exchange_id, _user_id, status, date_entered) \nVALUES (''_MESSAGE_ID_'', ''_USER_ID_'', ''_STATUS_'', NOW()) \n\nON DUPLICATE KEY UPDATE date_entered = NOW();'),
(288, 'update_invite_status_with_limit', 'UPDATE message_invites M, (SELECT id FROM message_invites WHERE _user_id=''_USER_ID_'' _STATUS_CONDITION_ ORDER BY invitation_time _LIMIT_TEXT_) A SET M.message_status = ''_NEW_STATUS_'', message_status_date=NOW() \nWHERE M.id = A.id'),
(289, 'get_user_invitations_by_status', 'SELECT * FROM message_invites WHERE message_status=''_STATUS_'' AND _user_id=''_USER_ID_'''),
(290, 'get_invitation_list', 'SELECT id AS invite_id, _user_id AS user_id, email_address, join_link, invitation_time, invite_message\n\nFROM message_invites WHERE message_status=''_STATUS_'' ORDER BY invitation_time _LIMIT_TEXT_'),
(291, 'update_invite_status', 'UPDATE message_invites SET message_status=''_MESSAGE_STATUS_'', message_status_date=NOW() WHERE id=''_INVITE_ID_'''),
(292, 'get_invitation_list_users', 'SELECT DISTINCT _user_id AS user_id FROM message_invites WHERE message_status=''_STATUS_'' ORDER BY invitation_time _LIMIT_TEXT_'),
(293, 'get_non_responsive_invitations', 'SELECT id AS invite_id FROM message_invites I \nWHERE message_status IN (''sent'',''read'',''bounced'') \nAND DATEDIFF(NOW(),invitation_time) >= _DAYS_OLD_ \nAND referral_status=''pending'' \nAND invite_message=''_OLD_MESSAGE_CODE_'' \nAND (SELECT id FROM users WHERE email_address=I.email_address LIMIT 1) IS NULL\n\nORDER BY invitation_time \n\n_LIMIT_TEXT_'),
(294, 'resend_old_invite', 'UPDATE message_invites SET invite_message=''_NEW_CODE_'', message_status=''_NEW_STATUS_'', \nnumber_of_invitations = (number_of_invitations + 1), \nmessage_status_date=NOW() \n\nWHERE id=''_INVITE_ID_'''),
(296, 'cancel_invitation_message', 'UPDATE message_invites SET message_status=''cancelled'', number_of_invitations=''0'', message_status_date=NOW() WHERE id=''_INVITE_ID_'''),
(304, 'get_message_exchange_list', 'SELECT * FROM message_exchange \nWHERE (send_system=''Y'' AND send_system_result=''_STATUS_'' \nOR send_email=''Y'' AND send_email_result=''_STATUS_'' \nOR send_sms=''Y'' AND send_sms_result=''_STATUS_'') \n\nAND DATE(send_date) <= NOW()\nORDER BY send_date ASC \n\n_LIMIT_TEXT_'),
(305, 'update_message_exchange_field', 'UPDATE message_exchange SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_EXCHANGE_ID_'''),
(306, 'get_user_view_details', 'SELECT * FROM view__user_details_msg WHERE user_id IN (''_ID_LIST_'')'),
(307, 'get_user_phone_details', 'SELECT (SELECT P.full_carrier_name FROM contact_phones C \n	LEFT JOIN contact_phone_providers P ON (P.id=C._provider_id) \n	WHERE C._user_id=''_USER_ID_'' AND C.telephone=U.telephone AND U.telephone <> '''' LIMIT 1\n) AS telephone_carrier, \n\n(SELECT C._provider_id FROM contact_phones C  \n	WHERE C._user_id=''_USER_ID_'' AND C.telephone=U.telephone AND U.telephone <> '''' LIMIT 1\n) AS telephone_carrier_id \n\nFROM (SELECT telephone FROM contact_phones WHERE _user_id=''_USER_ID_'' ORDER BY is_primary DESC LIMIT 1) U'),
(308, 'get_number_of_invites', 'SELECT COUNT(id) AS invite_count FROM message_invites WHERE _user_id = ''_USER_ID_'' AND number_of_invitations > 0'),
(309, 'get_provider_list', 'SELECT * FROM contact_phone_providers WHERE full_carrier_name LIKE ''_SEARCH_PHRASE_'' _LIMIT_TEXT_'),
(311, 'update_invite_details', 'UPDATE message_invites SET \nfirst_name=''_FIRST_NAME_'', \nlast_name=''_LAST_NAME_'', \nphone_number=''_PHONE_NUMBER_''\n\nWHERE email_address=''_EMAIL_ADDRESS_'''),
(312, 'add_user_contact', 'INSERT INTO contact_phones (_user_id, _provider_id, telephone)  \nVALUES (''_USER_ID_'', ''_PROVIDER_ID_'', ''_TELEPHONE_'')\nON DUPLICATE KEY UPDATE telephone=''_TELEPHONE_'', _provider_id=''_PROVIDER_ID_'''),
(313, 'add_message_settings', 'INSERT INTO user_preferred_communication (_user_id, 	message_format, message_type)\r\n(SELECT ''_USER_ID_'' AS _user_id, M.word AS message_format, ''_MESSAGE_TYPES_'' AS message_type FROM\r\n \r\n(SELECT IF(''email'' IN (_MESSAGE_FORMATS_), ''email'','''') AS word \r\nUNION SELECT IF(''sms'' IN (_MESSAGE_FORMATS_), ''sms'','''') AS word \r\nUNION SELECT IF(''system'' IN (_MESSAGE_FORMATS_), ''system'','''') AS word) M \r\n\r\nWHERE M.word <> '''')\r\n\r\nON DUPLICATE KEY UPDATE message_type=VALUES(message_type);'),
(314, 'add_notification_settings', 'INSERT INTO notification_settings (_user_id, email_address, first_name, last_name, sender_type, send_me_adverts, last_updated, _last_updated_by)\n\nVALUES (''_USER_ID_'', ''_EMAIL_ADDRESS_'', ''_FIRST_NAME_'', ''_LAST_NAME_'', ''_SENDER_TYPE_'', ''_SEND_ME_ADVERTS_'', NOW(), ''_UPDATED_BY_'')\n\nON DUPLICATE KEY UPDATE email_address=''_EMAIL_ADDRESS_'', first_name=''_FIRST_NAME_'', last_name=''_LAST_NAME_'', sender_type=''_SENDER_TYPE_'', send_me_adverts=''_SEND_ME_ADVERTS_'', last_updated=NOW(), _last_updated_by=''_UPDATED_BY_'''),
(315, 'link_new_user_to_invitation', 'UPDATE message_invites SET friend_id=''_NEW_USER_ID_'', referral_status=''_REFERRAL_STATUS_'',\r\nmessage_status=''_MESSAGE_STATUS_'', \r\nread_ip_address=''_READ_IP_ADDRESS_'', \r\nmessage_status_date=NOW(),\r\nreferral_status_date=NOW() \r\nWHERE email_address=''_EMAIL_ADDRESS_'' AND _user_id=''_REFERRER_ID_'''),
(316, 'get_list_of_inviters_by_email', 'SELECT DISTINCT I._user_id AS user_id \nFROM message_invites I \nLEFT JOIN notification_settings U ON (U._user_id=I._user_id) \nWHERE I.email_address = ''_EMAIL_ADDRESS_'' _INVITER_CONDITION_ \n\nORDER BY I.invitation_time ASC'),
(318, 'remove_user_contact', 'DELETE FROM contact_phones WHERE _user_id=''_USER_ID_'''),
(319, 'remove_user_message_settings', 'DELETE FROM user_preferred_communication WHERE _user_id=''_USER_ID_'''),
(320, 'remove_user_sending_record', 'DELETE FROM message_exchange WHERE _sender_id=''_USER_ID_'''),
(321, 'remove_user_sending_status', 'DELETE FROM message_status WHERE _user_id=''_USER_ID_'''),
(322, 'get_user_by_id', 'SELECT N.email_address, N.first_name, N.last_name, (SELECT telephone FROM contact_phones WHERE _user_id=N._user_id ORDER BY is_primary DESC LIMIT 1) AS telephone \n\nFROM notification_settings N \nWHERE N._user_id=''_USER_ID_'''),
(323, 'delete_activity_log', 'DELETE FROM activity_log WHERE user_id=''_USER_ID_'''),
(324, 'delete_contact_addresses', 'DELETE FROM contact_addresses WHERE _user_id=''_USER_ID_'''),
(325, 'delete_contact_emails', 'DELETE FROM contact_emails WHERE _user_id=''_USER_ID_'''),
(326, 'delete_contact_phones', 'DELETE FROM contact_phones WHERE _user_id=''_USER_ID_'''),
(327, 'delete_message_exchange', 'DELETE FROM message_exchange WHERE _sender_id=''_USER_ID_'' OR _recipient_id=''_USER_ID_'''),
(328, 'delete_message_invites', 'DELETE FROM message_invites WHERE _user_id=''_USER_ID_'''),
(329, 'delete_message_likes', 'DELETE FROM message_likes WHERE _user_id=''_USER_ID_'''),
(330, 'delete_message_status', 'DELETE FROM message_status WHERE _user_id=''_USER_ID_'''),
(331, 'delete_user_preferred_communication', 'DELETE FROM user_preferred_communication WHERE _user_id=''_USER_ID_'''),
(332, 'add_telephone_activation_code', 'UPDATE contact_phones SET activation_code=''_ACTIVATION_CODE_'' WHERE id=''_CONTACT_ID_'''),
(333, 'activate_telephone_by_code', 'UPDATE contact_phones SET is_active=''Y'' WHERE id=''_CONTACT_ID_'' AND activation_code=''_ACTIVATION_CODE_'''),
(334, 'get_provider_by_id', 'SELECT id AS provider_id, full_carrier_name FROM contact_phone_providers WHERE id=''_PROVIDER_ID_'''),
(335, 'activate_email_by_code', 'UPDATE contact_emails SET is_active=''Y'' WHERE id=''_CONTACT_ID_'' AND activation_code=''_ACTIVATION_CODE_'''),
(336, 'get_user_messages', 'SELECT A.*,\nIF(A.status <> ''received'', ''Y'', ''N'') AS is_read\n\nFROM \n(SELECT X.id AS message_id, X.subject, X.attachment_url, UNIX_TIMESTAMP(X.date_entered) AS date_received, X._sender_id AS sender_id, X.sender_type, X.send_date,\n(SELECT CONCAT(first_name, '' '', last_name) FROM notification_settings WHERE _user_id=X._sender_id LIMIT 1) AS sender_name, \n\nIF((SELECT message_type FROM message_templates WHERE id=X.template_id AND X.template_type=''system'' LIMIT 1) = ''system_alert_notification'', ''Y'', ''N'') AS is_alert,\nIFNULL((SELECT status FROM message_status WHERE _user_id= ''_USER_ID_'' AND _exchange_id=X.id ORDER BY date_entered DESC LIMIT 1), ''received'') AS status\n\nFROM message_exchange X \nWHERE X._recipient_id = ''_USER_ID_'' \n_PHRASE_CONDITION_ \n) A \n\nWHERE A.status <> ''archived'' AND UNIX_TIMESTAMP(A.send_date) <= UNIX_TIMESTAMP(NOW()) AND UNIX_TIMESTAMP(A.send_date) <> ''0000-00-00 00:00:00''  \n_SENDER_CONDITION_ \nGROUP BY A.message_id\nORDER BY FIELD(is_read, ''N'',''Y''), A.date_received DESC  \n_LIMIT_TEXT_'),
(337, 'get_message_statistics', 'SELECT \n(SELECT COUNT(_exchange_id) FROM message_status MS WHERE \n	(SELECT status FROM message_status WHERE _exchange_id=MS._exchange_id AND _user_id=MS._user_id ORDER BY date_entered DESC LIMIT 1) IN (''received'', NULL) \n	AND MS._user_id=''_USER_ID_''\n) AS unread, \n\n(SELECT COUNT(S._exchange_id) FROM message_status S \nLEFT JOIN message_exchange X ON (X.id=S._exchange_id) \nLEFT JOIN message_templates T ON (T.id=X.template_id AND X.template_type=''system'' AND T.message_type=''send_store_schedule'') \nWHERE T.id IS NOT NULL AND S.status=''received'' AND S._user_id=''_USER_ID_'') AS reservations'),
(338, 'get_known_mail_host', 'SELECT * FROM clout_v1_3msg.mail_hosts WHERE domain=''_DOMAIN_'''),
(339, 'get_users_invited_emails', 'SELECT email_address FROM contact_emails WHERE _user_id=''_USER_ID_'''),
(340, 'check_if_user_unsubscribed_by_email', 'SELECT * FROM unsubscribe_list WHERE email_address=''_EMAIL_ADDRESS_'' AND DATEDIFF(DATE(expiry_date), NOW()) > 0 LIMIT 1'),
(341, 'get_total_invites', 'SELECT COUNT(id) AS invite_count, _user_id AS referral_id FROM message_invites WHERE _user_id IN (''_USER_IDS_'') AND number_of_invitations > 0 GROUP BY _user_id;'),
(342, 'get_existing_user_emails', 'SELECT * FROM (\n(SELECT DISTINCT(email_address) AS email_address FROM notification_settings WHERE _user_id=''_USER_ID_'')\nUNION \n(SELECT DISTINCT(email_address) AS email_address FROM contact_emails WHERE _user_id=''_USER_ID_'')\n) A '),
(344, 'add_message_invite', 'INSERT INTO message_invites (_user_id, first_name , last_name, invite_message, join_link, email_address, phone_number, method_used, invitation_time, referral_status, message_status, number_of_invitations, last_invitation_sent_on, sent_at_ip_address, _invitation_sent_by, message_status_date, referral_status_date) \r\n\r\nVALUES (''_USER_ID_'', ''_FIRST_NAME_'' , ''_LAST_NAME_'', ''_INVITE_MESSAGE_'', ''_JOIN_LINK_'', ''_EMAIL_ADDRESS_'', ''_PHONE_NUMBER_'', ''_METHOD_USED_'', NOW(), ''pending'', ''_MESSAGE_STATUS_'', ''1'', NOW(), ''_SENT_AT_IP_ADDRESS_'', ''_USER_ID_'', NOW(), NOW())\r\n\r\nON DUPLICATE KEY UPDATE first_name=''_FIRST_NAME_'' , last_name=''_LAST_NAME_'', invite_message=''_INVITE_MESSAGE_'', phone_number=''_PHONE_NUMBER_'', message_status=''_MESSAGE_STATUS_'', sent_at_ip_address=''_SENT_AT_IP_ADDRESS_'', message_status_date=NOW();'),
(345, 'get_last_time_invite_was_sent', 'SELECT MAX(last_invitation_sent_on)  AS last_time_invite_was_sent FROM message_invites WHERE _user_id=''_USER_ID_'' AND message_status=''sent'''),
(346, 'get_saved_emails', 'SELECT id AS contact_id, email_address, is_primary, UNIX_TIMESTAMP(date_entered) AS date_entered, is_active \r\nFROM contact_emails WHERE _user_id=''_USER_ID_'' AND is_active IN (''_IS_ACTIVE_'') ORDER BY date_entered DESC'),
(347, 'get_saved_phones', 'SELECT C.id AS contact_id, C._provider_id AS provider_id, C.telephone, C.is_active, \r\nIF(C._provider_id <> '''', (SELECT full_carrier_name FROM contact_phone_providers WHERE id=C._provider_id LIMIT 1), '''') AS provider_name, \r\nC.is_primary, UNIX_TIMESTAMP(C.date_entered) AS date_entered \r\nFROM contact_phones C \r\nWHERE C._user_id=''_USER_ID_'' AND C.is_active IN (''_IS_ACTIVE_'') \r\nORDER BY C.date_entered DESC'),
(348, 'get_communication_preferences', 'SELECT message_format FROM user_preferred_communication WHERE _user_id=''_USER_ID_'''),
(349, 'add_communication_privacy', 'INSERT IGNORE INTO user_preferred_communication (_user_id, message_format) VALUES (''_USER_ID_'', ''_MESSAGE_FORMAT_'')'),
(350, 'delete_communication_privacy', 'DELETE FROM user_preferred_communication WHERE _user_id=''_USER_ID_'' AND message_format=''_MESSAGE_FORMAT_'''),
(351, 'add_user_email_address', 'INSERT IGNORE INTO contact_emails (_user_id, email_address, date_entered, is_active) \r\nVALUES (''_USER_ID_'', ''_EMAIL_ADDRESS_'', NOW(), ''N'')'),
(352, 'add_email_activation_code', 'UPDATE contact_emails SET activation_code=''_ACTIVATION_CODE_'' WHERE id=''_CONTACT_ID_'''),
(353, 'record_like_messages', 'INSERT INTO message_likes (_exchange_id, _user_id, user_like, user_dislike, date_entered, last_updated)\r\n\r\n(SELECT X.id AS _exchange_id, ''_USER_ID_'' AS _user_id, ''_LIKE_'' AS user_like, ''_DISLIKE_'' AS user_dislike, NOW() AS date_entered, NOW() AS last_updated FROM message_exchange X WHERE X.id IN (''_MESSAGES_''))\r\n\r\nON DUPLICATE KEY UPDATE user_like=VALUES(user_like), user_dislike=VALUES(user_dislike), last_updated=NOW()'),
(354, 'extract_favorites_from_messages', 'SELECT ''_USER_ID_'' AS _user_id, X._sender_id AS _store_id, NOW() AS date_entered \nFROM message_exchange X \nWHERE X.sender_type=''store'' AND X._sender_id <> ''0'' AND X.id IN (''_MESSAGES_'')'),
(355, 'add_user_message_template', 'INSERT INTO message_user_templates (owner_id, owner_type, name, subject, body, sms, attachment, date_entered, _entered_by, 	last_updated) \r\nVALUES \r\n(''_OWNER_ID_'', ''_OWNER_TYPE_'', ''_NAME_'', ''_SUBJECT_'', ''_BODY_'', ''_SMS_'', ''_ATTACHMENT_'', NOW(), ''_USER_ID_'', 	NOW())\r\n\r\nON DUPLICATE KEY UPDATE \r\nsubject=''_SUBJECT_'', body=''_BODY_'', sms=''_SMS_'', attachment=''_ATTACHMENT_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'''),
(356, 'add_custom_message_exchange', 'INSERT IGNORE INTO message_exchange (template_id, template_type, details, sms, subject, attachment_url, _sender_id, sender_type, _recipient_id, cashback, is_perk, _category_id, send_date, send_system, send_email, send_sms, send_system_result, send_email_result, send_sms_result, scheduled_send_date, date_entered, _entered_by)\n\nVALUES (''_TEMPLATE_ID_'', ''_TEMPLATE_TYPE_'', ''_DETAILS_'', ''_SMS_'', ''_SUBJECT_'', ''_ATTACHMENT_URL_'', ''_SENDER_ID_'', ''_SENDER_TYPE_'', ''_RECIPIENT_ID_'', ''_CASHBACK_'', ''_IS_PERK_'', ''_CATEGORY_ID_'', \nIF(''_SEND_DATE_'' <> '''', ''_SEND_DATE_'', ''0000-00-00 00:00:00''), ''_SEND_SYSTEM_'', ''_SEND_EMAIL_'', ''_SEND_SMS_'', ''_SEND_SYSTEM_RESULT_'', ''_SEND_EMAIL_RESULT_'', ''_SEND_SMS_RESULT_'', IF(''_SCHEDULED_SEND_DATE_'' <> '''', ''_SCHEDULED_SEND_DATE_'', ''0000-00-00 00:00:00''), NOW(), ''_USER_ID_'')\n \n\n'),
(357, 'add_user_to_unsubscribe_list', 'INSERT IGNORE INTO unsubscribe_list (email_address, telephone, contacted_by, reason, date_entered, expiry_date) \r\n\r\n(SELECT ''_EMAIL_ADDRESS_'' AS email_address, \r\n''_TELEPHONE_'' AS telephone, \r\n\r\nIFNULL((SELECT _user_id FROM message_invites WHERE email_address=''_EMAIL_ADDRESS_'' AND ''_EMAIL_ADDRESS_'' <> '''' LIMIT 1),\r\nIFNULL((SELECT _user_id FROM message_invites WHERE phone_number=''_TELEPHONE_'' AND ''_TELEPHONE_'' <> '''' LIMIT 1), \r\n''system'')) AS contacted_by, \r\n\r\n''_REASON_'' AS reason, \r\nNOW() AS date_entered, \r\n''_EXPIRY_DATE_'' AS expiry_date)'),
(358, 'get_searchable_invite_list', 'SELECT I.last_invitation_sent_on AS last_invite_date, \nI.first_name, I.last_name, CONCAT(I.first_name, '' '', I.last_name) AS name, I.email_address,\nIF(I.friend_id <> '''', (SELECT COUNT(id) AS invite_count FROM message_invites WHERE _user_id = I.friend_id AND number_of_invitations > 0), ''0'') AS total_invites, \nI.message_status AS invitation_status, \nI.friend_id AS referral_id\n\nFROM message_invites I \nWHERE I._user_id=''_USER_ID_'' _PHRASE_CONDITION_\nORDER BY I.last_invitation_sent_on DESC \n_LIMIT_TEXT_'),
(359, 'add_user_telephone', 'INSERT IGNORE INTO contact_phones (_user_id, _provider_id, telephone, is_primary, date_entered, is_active ) \nVALUES \n(''_USER_ID_'', ''_PROVIDER_ID_'', ''_TELEPHONE_'', ''_IS_PRIMARY_'', NOW(), ''N'')'),
(360, 'get_user_invite_count', 'SELECT COUNT(*) AS invite_count FROM message_invites WHERE _user_id IN (''_USER_IDS_'')'),
(361, 'get_user_total_messages', 'SELECT S._user_id AS user_id,\r\n(SELECT COUNT(id) FROM message_exchange WHERE _recipient_id = S._user_id) AS total_msgs_received\r\nFROM clout_v1_3msg.notification_settings S\r\nWHERE S._user_id IN (''_ID_LIST_'')');

-- --------------------------------------------------------

--
-- Структура таблицы `unsubscribe_list`
--

CREATE TABLE IF NOT EXISTS `unsubscribe_list` (
  `id` bigint(20) NOT NULL,
  `email_address` varchar(250) NOT NULL,
  `telephone` varchar(100) NOT NULL,
  `contacted_by` varchar(100) NOT NULL DEFAULT 'system',
  `reason` text NOT NULL,
  `date_entered` datetime NOT NULL,
  `expiry_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Структура таблицы `user_preferred_communication`
--

CREATE TABLE IF NOT EXISTS `user_preferred_communication` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `message_format` varchar(100) NOT NULL,
  `message_type` varchar(100) NOT NULL DEFAULT 'all'
) ENGINE=InnoDB AUTO_INCREMENT=150 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_preferred_communication`
--

INSERT INTO `user_preferred_communication` (`id`, `_user_id`, `message_format`, `message_type`) VALUES
(2, 1, 'sms', 'all'),
(3, 1, 'system', 'all'),
(10, 1, 'email', 'all'),
(41, 12, 'email', 'all'),
(42, 12, 'sms', 'all'),
(43, 12, 'system', 'all'),
(44, 13, 'email', 'all'),
(45, 13, 'sms', 'all'),
(46, 13, 'system', 'all'),
(47, 14, 'email', 'all'),
(48, 50, 'email', 'all'),
(49, 50, 'sms', 'all'),
(50, 50, 'system', 'all'),
(51, 51, 'email', 'all'),
(52, 51, 'sms', 'all'),
(53, 51, 'system', 'all'),
(54, 52, 'email', 'all'),
(55, 52, 'sms', 'all'),
(56, 52, 'system', 'all'),
(57, 53, 'email', 'all'),
(58, 53, 'sms', 'all'),
(59, 53, 'system', 'all'),
(60, 54, 'email', 'all'),
(61, 54, 'sms', 'all'),
(62, 54, 'system', 'all'),
(63, 55, 'email', 'all'),
(64, 55, 'sms', 'all'),
(65, 55, 'system', 'all'),
(66, 56, 'email', 'all'),
(67, 56, 'sms', 'all'),
(68, 56, 'system', 'all'),
(69, 57, 'email', 'all'),
(70, 57, 'sms', 'all'),
(71, 57, 'system', 'all'),
(72, 58, 'email', 'all'),
(73, 58, 'sms', 'all'),
(74, 58, 'system', 'all'),
(75, 59, 'email', 'all'),
(76, 59, 'sms', 'all'),
(77, 59, 'system', 'all'),
(78, 60, 'email', 'all'),
(79, 60, 'sms', 'all'),
(80, 60, 'system', 'all'),
(81, 61, 'email', 'all'),
(82, 61, 'sms', 'all'),
(83, 61, 'system', 'all'),
(84, 62, 'email', 'all'),
(85, 62, 'sms', 'all'),
(86, 62, 'system', 'all'),
(88, 63, 'sms', 'all'),
(89, 63, 'system', 'all'),
(90, 68, 'email', 'all'),
(91, 68, 'sms', 'all'),
(92, 68, 'system', 'all'),
(93, 69, 'email', 'all'),
(94, 69, 'sms', 'all'),
(95, 69, 'system', 'all'),
(96, 70, 'email', 'all'),
(97, 70, 'sms', 'all'),
(98, 70, 'system', 'all'),
(99, 71, 'email', 'all'),
(100, 71, 'sms', 'all'),
(101, 71, 'system', 'all'),
(102, 72, 'email', 'all'),
(103, 72, 'sms', 'all'),
(104, 72, 'system', 'all'),
(105, 73, 'email', 'all'),
(106, 73, 'sms', 'all'),
(107, 73, 'system', 'all'),
(108, 74, 'email', 'all'),
(109, 74, 'sms', 'all'),
(110, 74, 'system', 'all'),
(111, 75, 'email', 'all'),
(112, 75, 'sms', 'all'),
(113, 75, 'system', 'all'),
(114, 76, 'email', 'all'),
(115, 76, 'sms', 'all'),
(116, 76, 'system', 'all'),
(117, 77, 'email', 'all'),
(118, 77, 'sms', 'all'),
(119, 77, 'system', 'all'),
(120, 78, 'email', 'all'),
(121, 78, 'sms', 'all'),
(122, 78, 'system', 'all'),
(123, 80, 'email', 'all'),
(124, 80, 'sms', 'all'),
(125, 80, 'system', 'all'),
(126, 82, 'email', 'all'),
(127, 82, 'sms', 'all'),
(128, 82, 'system', 'all'),
(129, 83, 'email', 'all'),
(130, 83, 'sms', 'all'),
(131, 83, 'system', 'all'),
(132, 84, 'email', 'all'),
(133, 84, 'sms', 'all'),
(134, 84, 'system', 'all'),
(135, 86, 'email', 'all'),
(136, 86, 'sms', 'all'),
(137, 86, 'system', 'all'),
(138, 87, 'email', 'all'),
(139, 87, 'sms', 'all'),
(140, 87, 'system', 'all'),
(141, 89, 'email', 'all'),
(142, 89, 'sms', 'all'),
(143, 89, 'system', 'all'),
(144, 90, 'email', 'all'),
(145, 90, 'sms', 'all'),
(146, 90, 'system', 'all'),
(147, 91, 'email', 'all'),
(148, 91, 'sms', 'all'),
(149, 91, 'system', 'all');

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__user_details_msg`
--
CREATE TABLE IF NOT EXISTS `view__user_details_msg` (
`user_id` bigint(20)
,`total_msgs_received` bigint(21)
,`total_invited_level_1` bigint(21)
,`total_invited_level_2` bigint(21)
,`total_invited_level_3` bigint(21)
,`total_invited_level_4` bigint(21)
,`total_joined_level_1` bigint(21)
,`total_joined_level_2` bigint(21)
,`total_joined_level_3` bigint(21)
,`total_joined_level_4` bigint(21)
);

-- --------------------------------------------------------

--
-- Структура для представления `view__user_details_msg`
--
DROP TABLE IF EXISTS `view__user_details_msg`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__user_details_msg` AS select distinct `C`.`_user_id` AS `user_id`,(select count(`message_exchange`.`id`) from `message_exchange` where (`message_exchange`.`_recipient_id` = `C`.`_user_id`)) AS `total_msgs_received`,(select count(distinct `message_invites`.`email_address`) from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`)) AS `total_invited_level_1`,(select count(distinct `message_invites`.`email_address`) from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`))) AS `total_invited_level_2`,(select count(distinct `message_invites`.`email_address`) from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`)))) AS `total_invited_level_3`,(select count(distinct `message_invites`.`email_address`) from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`))))) AS `total_invited_level_4`,(select count(`message_invites`.`friend_id`) from `message_invites` where ((`message_invites`.`_user_id` = `C`.`_user_id`) and (`message_invites`.`friend_id` <> ''))) AS `total_joined_level_1`,(select count(`message_invites`.`friend_id`) from `message_invites` where (`message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`)) and (`message_invites`.`friend_id` <> ''))) AS `total_joined_level_2`,(select count(`message_invites`.`friend_id`) from `message_invites` where (`message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`))) and (`message_invites`.`friend_id` <> ''))) AS `total_joined_level_3`,(select count(`message_invites`.`friend_id`) from `message_invites` where (`message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where `message_invites`.`_user_id` in (select `message_invites`.`friend_id` from `message_invites` where (`message_invites`.`_user_id` = `C`.`_user_id`)))) and (`message_invites`.`friend_id` <> ''))) AS `total_joined_level_4` from `user_preferred_communication` `C` where (`C`.`_user_id` > 0);

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
-- Индексы таблицы `contact_emails`
--
ALTER TABLE `contact_emails`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `contact_phones`
--
ALTER TABLE `contact_phones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`telephone`);

--
-- Индексы таблицы `contact_phone_providers`
--
ALTER TABLE `contact_phone_providers`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `mail_hosts`
--
ALTER TABLE `mail_hosts`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `message_exchange`
--
ALTER TABLE `message_exchange`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `template_id` (`template_id`,`template_type`,`subject`,`_sender_id`,`sender_type`,`_recipient_id`),
  ADD FULLTEXT KEY `subject_index` (`subject`);

--
-- Индексы таблицы `message_invites`
--
ALTER TABLE `message_invites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`email_address`);

--
-- Индексы таблицы `message_likes`
--
ALTER TABLE `message_likes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_exchange_id` (`_exchange_id`,`_user_id`);

--
-- Индексы таблицы `message_status`
--
ALTER TABLE `message_status`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_exchange_id` (`_exchange_id`,`_user_id`,`status`);

--
-- Индексы таблицы `message_templates`
--
ALTER TABLE `message_templates`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `message_user_templates`
--
ALTER TABLE `message_user_templates`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `owner_id` (`owner_id`,`owner_type`,`name`);

--
-- Индексы таблицы `notification_settings`
--
ALTER TABLE `notification_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`);

--
-- Индексы таблицы `queries`
--
ALTER TABLE `queries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `unsubscribe_list`
--
ALTER TABLE `unsubscribe_list`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `single_unique_unsubscribe` (`email_address`,`telephone`,`contacted_by`);

--
-- Индексы таблицы `user_preferred_communication`
--
ALTER TABLE `user_preferred_communication`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`message_format`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `activity_log`
--
ALTER TABLE `activity_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=35;
--
-- AUTO_INCREMENT для таблицы `contact_emails`
--
ALTER TABLE `contact_emails`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT для таблицы `contact_phones`
--
ALTER TABLE `contact_phones`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=105;
--
-- AUTO_INCREMENT для таблицы `contact_phone_providers`
--
ALTER TABLE `contact_phone_providers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `mail_hosts`
--
ALTER TABLE `mail_hosts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `message_exchange`
--
ALTER TABLE `message_exchange`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=33;
--
-- AUTO_INCREMENT для таблицы `message_invites`
--
ALTER TABLE `message_invites`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `message_likes`
--
ALTER TABLE `message_likes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT для таблицы `message_status`
--
ALTER TABLE `message_status`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `message_templates`
--
ALTER TABLE `message_templates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `message_user_templates`
--
ALTER TABLE `message_user_templates`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `notification_settings`
--
ALTER TABLE `notification_settings`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT для таблицы `queries`
--
ALTER TABLE `queries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=362;
--
-- AUTO_INCREMENT для таблицы `unsubscribe_list`
--
ALTER TABLE `unsubscribe_list`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `user_preferred_communication`
--
ALTER TABLE `user_preferred_communication`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=150;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
