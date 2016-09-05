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
-- База данных: `clout_v1_3`
--

DELIMITER $$
--
-- Функции
--
CREATE DEFINER=`user`@`%` FUNCTION `active`(`user_id` INT) RETURNS text CHARSET utf8
RETURN (SELECT case when (SELECT clout_v1_3cron.store_schedule.reservation_status FROM clout_v1_3cron.store_schedule where clout_v1_3cron.store_schedule._user_id = user_id GROUP BY clout_v1_3cron.store_schedule._user_id) IS NULL 
            then (SELECT if(clout_v1_3.user_geo_tracking.source = 'checkin','Here now',null) FROM clout_v1_3.user_geo_tracking WHERE clout_v1_3.user_geo_tracking._user_id = user_id GROUP BY clout_v1_3cron.store_schedule._user_id )
            else clout_v1_3cron.store_schedule.reservation_status
            end
from clout_v1_3cron.store_schedule GROUP BY clout_v1_3cron.store_schedule._user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `category_spending`(`user_id` INT(255)) RETURNS int(11)
RETURN(SELECT sum(clout_v1_3cron.cacheview__store_score_by_store.my_direct_competitors_spending_lifetime) FROM clout_v1_3cron.cacheview__store_score_by_store WHERE clout_v1_3cron.cacheview__store_score_by_store.user_id =  user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `competitor_spending`(`user_id` INT) RETURNS int(11)
RETURN(SELECT sum(clout_v1_3cron.cacheview__store_score_by_store.my_direct_competitors_spending_lifetime) FROM clout_v1_3cron.cacheview__store_score_by_store WHERE clout_v1_3cron.cacheview__store_score_by_store.user_id =  user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `get_upcoming_date`(`user_id` INT(255), `lati` FLOAT(5), `langi` FLOAT(5)) RETURNS datetime
RETURN (SELECT upcoming_date_.schedule_date FROM (SELECT upcoming_date.schedule_date FROM (SELECT MIN(distance_count.distance), distance_count.schedule_date
FROM (SELECT clout_v1_3.stores.latitude, clout_v1_3.stores.longitude, clout_v1_3.store_schedule.schedule_date, SQRT(
    POW(69.1 * (clout_v1_3.stores.latitude - lati), 2) +
    POW(69.1 * (langi - clout_v1_3.stores.longitude) * COS(clout_v1_3.stores.latitude / 57.3), 2)) AS distance
FROM clout_v1_3.stores
LEFT JOIN clout_v1_3.store_schedule ON clout_v1_3.stores.id = clout_v1_3.store_schedule._store_id WHERE clout_v1_3.store_schedule._user_id=user_id) AS distance_count) AS upcoming_date) AS upcoming_date_)$$

CREATE DEFINER=`user`@`%` FUNCTION `in_store_spending`(`user_id` INT) RETURNS int(11)
RETURN(SELECT sum(clout_v1_3cron.cacheview__store_score_by_store.my_store_spending_lifetime) FROM clout_v1_3cron.cacheview__store_score_by_store WHERE clout_v1_3cron.cacheview__store_score_by_store.user_id =  user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `last_activity_ed`(`user_id` INT) RETURNS datetime
RETURN (SELECT max(clout_v1_3.user_geo_tracking.tracking_time) FROM `user_geo_tracking` WHERE  clout_v1_3.user_geo_tracking._user_id = user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `other_reser_ed`(`user_id` INT(255)) RETURNS int(11)
RETURN (SELECT count(*) FROM clout_v1_3.store_schedule  where clout_v1_3.store_schedule._user_id<>user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `priority`(`user_id` INT) RETURNS int(11)
RETURN (SELECT IFNULL( (SELECT
                  
                    (
    CASE 
        WHEN clout_v1_3cron.store_schedule.status = 'active' and date(clout_v1_3cron.store_schedule.schedule_date) = date(now()) THEN '1'
        WHEN clout_v1_3cron.store_schedule.status = 'active' and date(clout_v1_3cron.store_schedule.schedule_date) < date(now()) THEN '2'
        WHEN clout_v1_3cron.store_schedule.status = 'confirmed' and date(clout_v1_3cron.store_schedule.schedule_date) < date(now()) THEN '3'               
        
        ELSE 4
    END) AS total
                 
                  
                  FROM clout_v1_3cron.store_schedule where clout_v1_3cron.store_schedule._user_id = user_id ) ,4))$$

CREATE DEFINER=`user`@`%` FUNCTION `related_spending`(`user_id` INT) RETURNS int(11)
RETURN(SELECT sum(clout_v1_3cron.cacheview__store_score_by_store.related_categories_spending_lifetime) FROM clout_v1_3cron.cacheview__store_score_by_store WHERE clout_v1_3cron.cacheview__store_score_by_store.user_id =  user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `score`(`user_id` INT) RETURNS int(11)
RETURN(SELECT sum(clout_v1_3cron.cacheview__store_score_by_store.total_score) FROM clout_v1_3cron.cacheview__store_score_by_store WHERE clout_v1_3cron.cacheview__store_score_by_store.user_id =  user_id)$$

CREATE DEFINER=`user`@`%` FUNCTION `store_distance`(`lati` FLOAT(5), `langi` FLOAT(5)) RETURNS int(11)
RETURN (SELECT min(distance)
FROM (SELECT clout_v1_3.stores.latitude, clout_v1_3.stores.longitude, SQRT(
    POW(69.1 * (clout_v1_3.stores.latitude - lati), 2) +
    POW(69.1 * (langi - clout_v1_3.stores.longitude) * COS(clout_v1_3.stores.latitude / 57.3), 2)) AS distance
FROM clout_v1_3.stores) AS distance_count)$$

CREATE DEFINER=`user`@`%` FUNCTION `store_last_transaction_ed`(`user_id` INT) RETURNS datetime
RETURN (SELECT max(clout_v1_3cron.transactions.start_date) FROM clout_v1_3cron.transactions WHERE clout_v1_3cron.transactions._user_id=user_id)$$

DELIMITER ;

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
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `activity_log`
--

INSERT INTO `activity_log` (`id`, `user_id`, `activity_code`, `result`, `uri`, `log_details`, `device`, `ip_address`, `event_time`) VALUES
(13, 1, 'email__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:28:49'),
(14, 1, 'sms__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:28:49'),
(15, 1, 'email__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:44:27'),
(16, 1, 'sms__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:44:27'),
(17, 1, 'email__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:44:28'),
(18, 1, 'sms__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:44:28'),
(19, 1, 'email__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:50:15'),
(20, 1, 'sms__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:50:16'),
(21, 1, 'email__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:50:16'),
(22, 1, 'sms__message_sent', 'FAIL', 'store/reservation', 'message=Reservation Made on Offer 20150713-0832-0000000342|sent_to=John|sent_by=noreply@clout.com (Clout)', '', '::1', '2015-07-25 12:50:16');

--
-- Триггеры `activity_log`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__activity_log` AFTER INSERT ON `activity_log`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.activity_code='login' AND LOWER(NEW.result) = 'success' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET last_login_date=NEW.event_time, total_logins=(total_logins+1) WHERE user_id=NEW.user_id;
	END IF;

	IF NEW.activity_code='store_view' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_store_views=(total_store_views+1) WHERE user_id=NEW.user_id;
	END IF;

	-- update the tracker of the unique locations of this user

	IF NEW.activity_code='store_view' THEN
		INSERT IGNORE INTO clout_v1_3.user_locations (_user_id, latitude, longitude, ip_address, `source`, device, date_entered) 
		(SELECT NEW.user_id, '', '', NEW.ip_address, 'activity', IF(NEW.device <> '', NEW.device, 'other'), NEW.event_time);
	END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `advertisements`
--

CREATE TABLE IF NOT EXISTS `advertisements` (
  `id` bigint(20) NOT NULL,
  `_promotion_id` bigint(20) DEFAULT NULL,
  `ad_text` text NOT NULL,
  `ad_image_url` varchar(300) NOT NULL,
  `ad_video_url` varchar(300) NOT NULL,
  `bitly_short_url` varchar(100) NOT NULL,
  `internal_note` varchar(300) NOT NULL,
  `amount` float NOT NULL,
  `discount_percentage` float NOT NULL,
  `discount_amount` float NOT NULL,
  `max_buy_limit` int(11) NOT NULL,
  `min_buy_limit` int(11) NOT NULL,
  `is_featured` enum('Y','N') NOT NULL DEFAULT 'N',
  `ad_category` varchar(100) NOT NULL DEFAULT 'third_party',
  `status` enum('active','pending','live','archived') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `agents`
--

CREATE TABLE IF NOT EXISTS `agents` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `alternate_phone_number` int(11) NOT NULL,
  `commit_time` int(11) NOT NULL,
  `education` varchar(300) NOT NULL,
  `is_enrolled_in_school` enum('Y','N') NOT NULL DEFAULT 'N',
  `expectations` varchar(500) NOT NULL,
  `referred_by_id` bigint(20) NOT NULL,
  `date_registered` datetime NOT NULL,
  `has_worked_in_sales` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_worked_in_pos` enum('Y','N') NOT NULL DEFAULT 'N',
  `years_of_experience_in_sales` int(11) NOT NULL,
  `years_of_experience_in_pos` int(11) NOT NULL,
  `rate_on_computer_skills` int(11) NOT NULL,
  `days_available_to_socialize` int(11) NOT NULL,
  `networking_rate` int(11) NOT NULL,
  `percentage_shown` float NOT NULL,
  `resume_url` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `agent_experience`
--

CREATE TABLE IF NOT EXISTS `agent_experience` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `company_name` varchar(300) NOT NULL,
  `website` varchar(300) NOT NULL,
  `title` varchar(500) NOT NULL,
  `role` varchar(300) NOT NULL,
  `compesation_amount` float NOT NULL,
  `compesation_type` enum('annual','rate') NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `archived_photos`
--

CREATE TABLE IF NOT EXISTS `archived_photos` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `photo_url` varchar(300) NOT NULL,
  `status` enum('archived','deleted') NOT NULL DEFAULT 'archived',
  `date_added` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `brands`
--

CREATE TABLE IF NOT EXISTS `brands` (
  `id` bigint(20) NOT NULL,
  `_store_owner_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `brand_name` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `business_id`
--

CREATE TABLE IF NOT EXISTS `business_id` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `has_multiple_locations` enum('Y','N') NOT NULL DEFAULT 'N',
  `online_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `slogan` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `_country_code` varchar(10) NOT NULL,
  `phone_number` int(11) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `star_rating` int(11) NOT NULL,
  `price_range` int(11) NOT NULL,
  `description` text NOT NULL,
  `public_store_key` text NOT NULL,
  `key_words` text,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `business_id`
--

INSERT INTO `business_id` (`id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'IKONDU MEDICAL CENTER - DESMOND IKONDU MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2502 W TRENTON RD', '', 'EDINBURG', 44, 'TX', '78539', 'USA', 2147483647, 1, '', 0, 0, '', 'ikondu-medical-center-desmond-ikondu-md-2502-w-trenton-rd--edinburg-tx-78539-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-98.18303', '26.25544', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(2, 'EWING INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '44 CLINTON ST', '', 'HUDSON', 36, 'OH', '44236', 'USA', 2147483647, 1, '', 0, 0, '', 'ewing-insurance-44-clinton-st--hudson-oh-44236-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-81.44158', '41.24222', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(3, 'NATIONAL INSURANCE CRIME', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '510 THORNALL ST', '', 'EDISON', 31, 'NJ', '08837', 'USA', 2147483647, 1, '', 0, 0, '', 'national-insurance-crime-510-thornall-st--edison-nj-08837-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-74.33839', '40.55822', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(4, 'MEMORIAL HERMANN MEMORIAL CITY - STEPHANIE FREEMAN MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '921 GESSNER RD', '', 'HOUSTON', 44, 'TX', '77024', 'USA', 2147483647, 1, 'WWW.MEMORIALHERMANNHOSPITAL.COM', 0, 0, '', 'memorial-hermann-memorial-city-stephanie-freeman-md-921-gessner-rd--houston-tx-77024-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-95.54449', '29.77935', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(6, 'ST LOUIS UNIVERSITY HOSPITAL - LAURIE E BYRNE MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '3635 VISTA AVE', '', 'SAINT LOUIS', 26, 'MO', '63110', 'USA', 2147483647, 1, '', 0, 0, '', 'st-louis-university-hospital-laurie-e-byrne-md-3635-vista-ave--saint louis-mo-63110-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-90.2396', '38.62266', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(7, 'MCGRAW INSURANCE SERVICES', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', 'banner_7.png', '', '8185 E KAISER BLVD', '', 'ANAHEIM', 5, 'CA', '92808', 'USA', 2147483647, 1, '', 0, 0, '', 'mcgraw-insurance-services-8185-e-kaiser-blvd--anaheim-ca-92808-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-117.7449', '33.8659', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(8, 'CAPE FEAR VALLEY MEDICAL CENTER - JASON G COLLINS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1638 OWEN DR', '', 'FAYETTEVILLE', 34, 'NC', '28304', 'USA', 2147483647, 1, '', 0, 0, '', 'cape-fear-valley-medical-center-jason-g-collins-md-1638-owen-dr--fayetteville-nc-28304-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-78.93105', '35.03121', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(9, 'FARM BUREAU INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '334 N STATE ST, STE B', '', 'DESLOGE', 26, 'MO', '63601', 'USA', 2147483647, 1, 'WWW.MOFB.COM', 0, 0, '', 'farm-bureau-insurance-334-n-state-st-ste-b--desloge-mo-63601-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-90.51013', '37.88674', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(10, 'NORTHSHORE UNIVERSITY EVANSTON - BRUCE A HARRIS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2650 RIDGE AVE', '', 'EVANSTON', 14, 'IL', '60201', 'USA', 2147483647, 1, '', 0, 0, '', 'northshore-university-evanston-bruce-a-harris-md-2650-ridge-ave--evanston-il-60201-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-87.68336', '42.06533', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);
INSERT INTO `business_id` (`id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(11, 'AMERICAN FAMILY INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '5310 WARD RD', '', 'ARVADA', 6, 'CO', '80002', 'USA', 2147483647, 1, '', 0, 0, '', 'american-family-insurance-5310-ward-rd--arvada-co-80002-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-105.1373', '39.79301', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__default_search_suggestions`
--

CREATE TABLE IF NOT EXISTS `cacheview__default_search_suggestions` (
  `user_id` varchar(100) DEFAULT NULL,
  `store_id` varchar(100) DEFAULT NULL,
  `store_score` varchar(100) DEFAULT NULL,
  `name` varchar(250) DEFAULT NULL,
  `longitude` varchar(10) DEFAULT NULL,
  `latitude` varchar(10) DEFAULT NULL,
  `price_range` varchar(5) DEFAULT NULL,
  `address_line_1` varchar(250) DEFAULT NULL,
  `address_line_2` varchar(250) DEFAULT NULL,
  `city` varchar(250) DEFAULT NULL,
  `state` varchar(250) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `sub_category_tags` text,
  `is_favorite` varchar(1) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `has_perk` varchar(1) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `max_cashback` double DEFAULT NULL,
  `min_cashback` double DEFAULT NULL,
  `table_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=74 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cacheview__default_search_suggestions`
--

INSERT INTO `cacheview__default_search_suggestions` (`user_id`, `store_id`, `store_score`, `name`, `longitude`, `latitude`, `price_range`, `address_line_1`, `address_line_2`, `city`, `state`, `zipcode`, `sub_category_tags`, `is_favorite`, `has_perk`, `max_cashback`, `min_cashback`, `table_id`) VALUES
('1', '615931', '1150', 'OMI SUSHI', '-118.36693', '34.09108', '0', '8163 SANTA MONICA BLVD', '', 'WEST HOLLYWOOD', 'CA', '90046', 'RESTAURANTS', 'N', 'N', NULL, NULL, 64),
('1', '30661', '1150', 'CAFFE', '-122.33034', '47.62223', '0', '422 YALE AVE N', '', 'SEATTLE', 'WA', '98109', 'COFFEE & TEA SHOPS, RESTAURANTS', 'N', 'N', NULL, NULL, 65),
('1', '15693715', '1150', 'CHIPOTLE', '-118.34483', '34.0837', '0', '7101 MELROSE AVE', '', 'LOS ANGELES', 'CA', '90046', 'FAST FOOD RESTAURANTS, MEXICAN RESTAURANTS, RESTAURANTS, TAKE OUT', 'N', 'N', NULL, NULL, 66),
('1', '16157906', '1150', 'TACO BELL', '-118.38835', '34.03805', '0', '2628 S ROBERTSON BLVD', '', 'LOS ANGELES', 'CA', '90034', 'FAMILY RESTAURANTS, FAST FOOD RESTAURANTS, MEXICAN RESTAURANTS, RESTAURANTS, TAKE OUT', 'N', 'N', NULL, NULL, 67),
('1', '10201215', '1150', 'EL COMPADRE', '-93.72468', '32.48103', '0', '502 E KINGS HWY', '', 'SHREVEPORT', 'LA', '71105', 'MEXICAN RESTAURANTS, RESTAURANTS', 'N', 'N', NULL, NULL, 68),
('1', '13386085', '1150', 'MCCORMICK & SCHMICK''S SEAFOOD - BEVERLY HILLS', '-118.40171', '34.06808', '0', '206 N RODEO DR', '', 'BEVERLY HILLS', 'CA', '90210', 'FINE DINING RESTAURANTS, RESTAURANTS, SEAFOOD RESTAURANTS', 'N', 'N', NULL, NULL, 69),
('1', '10122005', '1150', 'HARD ROCK CAFE', '-115.15235', '36.10874', '0', '4455 PARADISE RD', '', 'LAS VEGAS', 'NV', '89169', 'AMERICAN RESTAURANTS, BAR & GRILL RESTAURANTS, BURGER RESTAURANTS, RESTAURANTS', 'N', 'N', NULL, NULL, 70),
('1', '12738423', '1150', 'TOMMY', '-80.53835', '38.22342', '0', '1 W MAIN ST', '', 'RICHWOOD', 'WV', '26261', 'RESTAURANTS', 'N', 'N', NULL, NULL, 71),
('1', '2540657', '1150', 'KFC GROVE', '-94.76824', '36.58112', '0', '1621 S MAIN ST', '', 'GROVE', 'OK', '74344', 'BUFFETS RESTAURANTS, CHICKEN RESTAURANTS, FAST FOOD RESTAURANTS, RESTAURANTS, SOUTHERN STYLE RESTAURANTS', 'N', 'N', NULL, NULL, 72),
('1', '5895038', '1150', 'PINK TACO - LOS ANGELES', '-118.41904', '34.0586', '0', '10250 SANTA MONICA BLVD STE 220', '', 'LOS ANGELES', 'CA', '90067', 'MEXICAN RESTAURANTS, RESTAURANTS', 'N', 'N', NULL, NULL, 73);

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__search_tracking_by_user_summary`
--

CREATE TABLE IF NOT EXISTS `cacheview__search_tracking_by_user_summary` (
  `user_phrase` varchar(250) NOT NULL,
  `search_type` varchar(100) NOT NULL,
  `user_id` varchar(100) NOT NULL,
  `frequency` bigint(21) DEFAULT NULL,
  `date_of_search` datetime NOT NULL,
  `table_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `cacheview__search_tracking_summary`
--

CREATE TABLE IF NOT EXISTS `cacheview__search_tracking_summary` (
  `search_type` varchar(100) NOT NULL,
  `user_phrase` varchar(250) NOT NULL,
  `frequency` bigint(21) DEFAULT NULL,
  `date_of_search` datetime NOT NULL,
  `table_id` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_1`
--

CREATE TABLE IF NOT EXISTS `categories_level_1` (
  `id` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` varchar(300) NOT NULL,
  `icon_url` varchar(100) NOT NULL,
  `preferred_rank` int(11) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_1`
--

INSERT INTO `categories_level_1` (`id`, `name`, `description`, `icon_url`, `preferred_rank`, `is_active`) VALUES
(1, 'Arts & Entertainment', '', 'blue_entertainment_icon.png', 1, 'Y'),
(2, 'Automotive', '', 'blue_automotive_icon.png', 1, 'Y'),
(3, 'Business & Professional Services', '', 'blue_professional_service_icon.png', 1, 'Y'),
(4, 'Clothing & Accessories', '', 'blue_clothing_icon.png', 1, 'Y'),
(5, 'Community & Government', '', 'blue_services_icon.png', 1, 'Y'),
(6, 'Computers & Electronics', '', 'blue_computer_icon.png', 1, 'Y'),
(7, 'Construction & Contractors', '', 'blue_home_services_icon.png', 1, 'Y'),
(8, 'Education', '', 'blue_education_icon.png', 1, 'Y'),
(9, 'Food & Dining', '', 'blue_restaurant_icon.png', 1, 'Y'),
(10, 'Health & Medicine', '', 'blue_healthcare_icon.png', 1, 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2`
--

CREATE TABLE IF NOT EXISTS `categories_level_2` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `_category_id` bigint(20) DEFAULT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2`
--

INSERT INTO `categories_level_2` (`id`, `name`, `_category_id`, `is_active`) VALUES
(1, 'AMUSEMENT & THEME PARKS', 1, 'Y'),
(2, 'ARCADES & AMUSEMENTS', 1, 'Y'),
(3, 'ART GALLERIES & DEALERS', 1, 'Y'),
(4, 'ART RESTORATION & CONSERVATION', 1, 'Y'),
(5, 'ART SCHOOLS', 1, 'Y'),
(6, 'ART SUPPLIES RETAIL', 1, 'Y'),
(7, 'ARTISTS & ART STUDIOS', 1, 'Y'),
(8, 'ARTS ORGANIZATIONS & INFORMATION', 1, 'Y'),
(9, 'BALLROOMS', 1, 'Y'),
(10, 'CULTURAL ATTRACTIONS EVENTS & FACILITIES', 1, 'Y');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_naics_mapping`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_naics_mapping` (
  `id` bigint(20) NOT NULL,
  `_category_level_2_id` bigint(20) NOT NULL,
  `naics_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=563670 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_naics_mapping`
--

INSERT INTO `categories_level_2_naics_mapping` (`id`, `_category_level_2_id`, `naics_code`) VALUES
(439853, 1, '111331'),
(424016, 1, '112111'),
(563669, 1, '114210'),
(325569, 1, '115210'),
(410685, 1, '221121'),
(312291, 1, '236115'),
(262660, 1, '236116'),
(346141, 1, '236118'),
(269161, 1, '236220'),
(244220, 1, '237130');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_naics_mapping_new`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_naics_mapping_new` (
  `id` bigint(20) NOT NULL,
  `_category_level_2_id` bigint(20) NOT NULL,
  `naics_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_naics_mapping_new`
--

INSERT INTO `categories_level_2_naics_mapping_new` (`id`, `_category_level_2_id`, `naics_code`) VALUES
(1, 1, '71'),
(2, 2, '71'),
(3, 3, '45392'),
(4, 4, '45392'),
(6, 5, '61161'),
(5, 5, '71'),
(7, 6, '45392'),
(8, 7, '71'),
(9, 7, '7115'),
(11, 8, '519');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_sic_mapping`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_sic_mapping` (
  `id` bigint(20) NOT NULL,
  `_category_level_2_id` bigint(20) NOT NULL,
  `sic_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=206760 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_sic_mapping`
--

INSERT INTO `categories_level_2_sic_mapping` (`id`, `_category_level_2_id`, `sic_code`) VALUES
(181784, 1, '0752'),
(148035, 1, '0782'),
(136440, 1, '2311'),
(122813, 1, '3715'),
(174433, 1, '3827'),
(84268, 1, '4493'),
(206759, 1, '4729'),
(138566, 1, '5047'),
(174615, 1, '5091'),
(62015, 1, '5092');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_sic_mapping_new`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_sic_mapping_new` (
  `id` bigint(20) NOT NULL,
  `_category_level_2_id` bigint(20) NOT NULL,
  `sic_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=211945 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_sic_mapping_new`
--

INSERT INTO `categories_level_2_sic_mapping_new` (`id`, `_category_level_2_id`, `sic_code`) VALUES
(211938, 1, '7996'),
(211939, 1, '799600'),
(211940, 1, '79960000'),
(211941, 1, '799699'),
(211942, 1, '79969900'),
(211943, 2, '799303'),
(211944, 2, '79930300'),
(211936, 3, '79999901'),
(211933, 3, '841201'),
(211935, 3, '84120100');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_split_JC`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_split_JC` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `full_name` varchar(300) NOT NULL DEFAULT '',
  `name1` varchar(255) DEFAULT NULL,
  `name2` varchar(255) DEFAULT NULL,
  `name3` varchar(255) DEFAULT NULL,
  `name4` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_split_JC`
--

INSERT INTO `categories_level_2_split_JC` (`id`, `full_name`, `name1`, `name2`, `name3`, `name4`) VALUES
(1, 'AMUSEMENT  THEME PARKS', 'AMUSEMENT', '', 'THEME', 'PARKS'),
(2, 'ARCADES  AMUSEMENTS', 'ARCADES', '', 'AMUSEMENTS', ''),
(3, 'ART GALLERIES  DEALERS', 'ART', 'GALLERIES', '', 'DEALERS'),
(4, 'ART RESTORATION  CONSERVATION', 'ART', 'RESTORATION', '', 'CONSERVATION'),
(5, 'ART SCHOOLS', 'ART', 'SCHOOLS', '', ''),
(6, 'ART SUPPLIES RETAIL', 'ART', 'SUPPLIES', 'RETAIL', ''),
(7, 'ARTISTS  ART STUDIOS', 'ARTISTS', '', 'ART', 'STUDIOS'),
(8, 'ARTS ORGANIZATIONS  INFORMATION', 'ARTS', 'ORGANIZATIONS', '', 'INFORMATION'),
(9, 'BALLROOMS', 'BALLROOMS', '', '', ''),
(10, 'CULTURAL ATTRACTIONS EVENTS  FACILITIES', 'CULTURAL', 'ATTRACTIONS', 'EVENTS', '');

-- --------------------------------------------------------

--
-- Структура таблицы `categories_level_2_suggestions`
--

CREATE TABLE IF NOT EXISTS `categories_level_2_suggestions` (
  `id` bigint(20) NOT NULL,
  `suggestion` varchar(300) NOT NULL,
  `_categories_level_1_id` bigint(20) DEFAULT NULL,
  `_transaction_descriptor_id` bigint(20) DEFAULT NULL,
  `status` enum('pending','approved','rejected','deleted') NOT NULL DEFAULT 'pending',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_level_2_suggestions`
--

INSERT INTO `categories_level_2_suggestions` (`id`, `suggestion`, `_categories_level_1_id`, `_transaction_descriptor_id`, `status`, `date_entered`, `_entered_by`) VALUES
(1, 'THESUBCA', 19, 82, 'pending', '2015-08-07 21:20:18', 1),
(2, 'THI CATEGORY', 19, 82, 'pending', '2015-08-07 21:20:55', 1),
(3, 'A THING ONE', 19, 82, 'pending', '2015-08-07 21:22:13', 1),
(4, 'A THING FOR ME', 19, 82, 'pending', '2015-08-07 21:26:53', 1),
(5, 'THIS IS A NEW CATEGORY', 19, 82, 'pending', '2015-08-07 21:32:28', 1),
(8, 'A TEAT', 19, 82, 'pending', '2015-08-07 21:33:34', 1),
(9, 'PINK CLOTHES SHOPPING', 16, 82, 'pending', '2015-08-10 07:47:48', 1),
(15, 'MUSEUMS FOR FUN', 1, 82, 'pending', '2015-08-10 07:50:42', 1),
(16, 'FRANCIS TAKEOUT', 1, 82, 'pending', '2015-08-27 11:30:27', 1),
(18, 'BATTERY CHECK REVIEWS', 2, 82, 'pending', '2015-08-31 10:17:07', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `categories_SPLIT_JC`
--

CREATE TABLE IF NOT EXISTS `categories_SPLIT_JC` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `cat_name` varchar(300) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `categories_SPLIT_JC`
--

INSERT INTO `categories_SPLIT_JC` (`id`, `cat_name`) VALUES
(1, 'AMUSEMENT  THEME PARKS'),
(2, 'ARCADES  AMUSEMENTS'),
(3, 'ART GALLERIES  DEALERS'),
(4, 'ART RESTORATION  CONSERVATION'),
(5, 'ART SCHOOLS'),
(6, 'ART SUPPLIES RETAIL'),
(7, 'ARTISTS  ART STUDIOS'),
(8, 'ARTS ORGANIZATIONS  INFORMATION'),
(9, 'BALLROOMS'),
(10, 'CULTURAL ATTRACTIONS EVENTS  FACILITIES');

-- --------------------------------------------------------

--
-- Структура таблицы `chains`
--

CREATE TABLE IF NOT EXISTS `chains` (
  `id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `country` varchar(10) NOT NULL,
  `website` varchar(300) NOT NULL,
  `small_banner` varchar(300) NOT NULL,
  `large_banner` varchar(300) NOT NULL,
  `is_live` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chains`
--

INSERT INTO `chains` (`id`, `name`, `address_line_1`, `address_line_2`, `city`, `state`, `zipcode`, `country`, `website`, `small_banner`, `large_banner`, `is_live`, `date_entered`, `_entered_by`) VALUES
(1, 'ikondu medical center - desmond ikondu md', '2502 w trenton rd', '', 'edinburg', 'tx', '78539', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(2, 'ewing insurance', '44 clinton st', '', 'hudson', 'oh', '44236', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(3, 'national insurance crime', '510 thornall st', '', 'edison', 'nj', '08837', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(4, 'memorial hermann memorial city - stephanie freeman md', '921 gessner rd', '', 'houston', 'tx', '77024', 'usa', 'www.memorialhermannhospital.com', '', '', 'Y', '2015-11-16 11:30:43', 1),
(6, 'st louis university hospital - laurie e byrne md', '3635 vista ave', '', 'saint louis', 'mo', '63110', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(7, 'mcgraw insurance services', '8185 e kaiser blvd', '', 'anaheim', 'ca', '92808', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(8, 'cape fear valley medical center - jason g collins md', '1638 owen dr', '', 'fayetteville', 'nc', '28304', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(9, 'farm bureau insurance', '334 n state st, ste b', '', 'desloge', 'mo', '63601', 'usa', 'www.mofb.com', '', '', 'Y', '2015-11-16 11:30:43', 1),
(10, 'northshore university evanston - bruce a harris md', '2650 ridge ave', '', 'evanston', 'il', '60201', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(11, 'american family insurance', '5310 ward rd', '', 'arvada', 'co', '80002', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `chains_new`
--

CREATE TABLE IF NOT EXISTS `chains_new` (
  `id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `country` varchar(10) NOT NULL,
  `website` varchar(300) NOT NULL,
  `small_banner` varchar(300) NOT NULL,
  `large_banner` varchar(300) NOT NULL,
  `is_live` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chains_new`
--

INSERT INTO `chains_new` (`id`, `name`, `address_line_1`, `address_line_2`, `city`, `state`, `zipcode`, `country`, `website`, `small_banner`, `large_banner`, `is_live`, `date_entered`, `_entered_by`) VALUES
(1, 'ikondu medical center - desmond ikondu md', '2502 w trenton rd', '', 'edinburg', 'tx', '78539', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(2, 'ewing insurance', '44 clinton st', '', 'hudson', 'oh', '44236', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(3, 'national insurance crime', '510 thornall st', '', 'edison', 'nj', '08837', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(4, 'memorial hermann memorial city - stephanie freeman md', '921 gessner rd', '', 'houston', 'tx', '77024', 'usa', 'www.memorialhermannhospital.com', '', '', 'Y', '2015-11-16 11:30:43', 1),
(6, 'st louis university hospital - laurie e byrne md', '3635 vista ave', '', 'saint louis', 'mo', '63110', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(7, 'mcgraw insurance services', '8185 e kaiser blvd', '', 'anaheim', 'ca', '92808', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(8, 'cape fear valley medical center - jason g collins md', '1638 owen dr', '', 'fayetteville', 'nc', '28304', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(9, 'farm bureau insurance', '334 n state st, ste b', '', 'desloge', 'mo', '63601', 'usa', 'www.mofb.com', '', '', 'Y', '2015-11-16 11:30:43', 1),
(10, 'northshore university evanston - bruce a harris md', '2650 ridge ave', '', 'evanston', 'il', '60201', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(11, 'american family insurance', '5310 ward rd', '', 'arvada', 'co', '80002', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `chains_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `chains_TEMP_JC` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `name` varchar(500) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `country` varchar(10) NOT NULL,
  `website` varchar(300) NOT NULL,
  `small_banner` varchar(300) NOT NULL,
  `large_banner` varchar(300) NOT NULL,
  `is_live` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chains_TEMP_JC`
--

INSERT INTO `chains_TEMP_JC` (`id`, `name`, `address_line_1`, `address_line_2`, `city`, `state`, `zipcode`, `country`, `website`, `small_banner`, `large_banner`, `is_live`, `date_entered`, `_entered_by`) VALUES
(24, 'farmers insurance group', '814 e 1st st', '', 'newberg', 'or', '97132', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(79, 'allstate insurance', '1708 peachtree st nw, # 307', '', 'atlanta', 'ga', '30309', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(499, 'farmers insurance', '112 n broadway', '', 'de pere', 'wi', '54115', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(836, 'allstate insurance companies', '29424 pacific hwy s, ste c', '', 'federal way', 'wa', '98003', 'usa', '', '', '', 'Y', '2015-11-16 11:30:43', 1),
(1348, 'allstate insurance agency', '4709 margaret wallace rd, ste 103', '', 'matthews', 'nc', '28105', 'usa', 'www.allstateagencies.com', '', '', 'Y', '2015-11-16 11:40:51', 1),
(4577, 'mcdonald''s', '615 228th ave ne', '', 'sammamish', 'wa', '98074', 'usa', '', '', '', 'Y', '2015-11-16 11:40:51', 1),
(6390, 'mc donald''s', '2461 e gulf to lake hwy', '', 'inverness', 'fl', '34453', 'usa', 'www.mcdonalds.com', '', '', 'Y', '2015-11-16 11:40:51', 1),
(16419, 'enterprise rent-a-car', '1717 r t dunn dr', '', 'bloomington', 'il', '61701', 'usa', 'www.enterprise.com', '', '', 'Y', '2015-11-16 11:40:51', 1),
(27128, 'allstate insurance company - mark ormond', '723 s dearborn st', '', 'chicago', 'il', '60605', 'usa', 'www.tomtracker.com', '', '', 'Y', '2015-11-16 11:40:51', 1),
(34811, 'mcdonalds', '1516 sw 114th st', '', 'seattle', 'wa', '98146', 'usa', '', '', '', 'Y', '2015-11-16 11:40:51', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `chain_categories`
--

CREATE TABLE IF NOT EXISTS `chain_categories` (
  `id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `_category_id` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chain_categories`
--

INSERT INTO `chain_categories` (`id`, `_chain_id`, `_category_id`) VALUES
(2, 258, 15),
(4, 260, 13),
(5, 262, 13),
(11, 29, 13),
(12, 259, 15),
(13, 9960238, 2),
(17, 16880547, 2),
(26, 16880525, 8),
(27, 16880563, 8),
(28, 16880564, 12);

-- --------------------------------------------------------

--
-- Структура таблицы `chain_references`
--

CREATE TABLE IF NOT EXISTS `chain_references` (
  `id` bigint(20) NOT NULL,
  `details` text NOT NULL,
  `reference_link` varchar(500) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `chain_references`
--

INSERT INTO `chain_references` (`id`, `details`, `reference_link`, `date_entered`, `_chain_id`, `_entered_by`) VALUES
(6, 'Los Angeles Neighborhood Market - Walmart.com', 'http://www.walmart.com/store/3086/whats-new', '2015-08-14 12:58:21', 3, 1),
(7, 'Walmart Neighborhood Market - Drugstores - Chinatown - Los ...', 'http://www.yelp.com/biz/walmart-neighborhood-market-los-angeles-4', '2015-08-14 12:58:21', 3, 1),
(8, 'Walmart Pharmacy - Drugstores - Chinatown - Los Angeles, CA ...', 'http://www.yelp.com/biz/walmart-pharmacy-los-angeles', '2015-08-14 12:58:21', 3, 1),
(9, 'Walmart Neighborhood Market - Chinatown - Los Angeles, CA', 'https://foursquare.com/v/walmart-neighborhood-market/4f46b5ade4b01d17b7c55a80', '2015-08-14 12:58:21', 3, 1),
(10, 'Carlton Pools', 'http://www.carltonpools.com/', '2015-08-14 13:40:45', 4, 1),
(11, 'Calton &amp; Associates, Inc.', 'http://www.calton.com/', '2015-08-14 13:40:46', 4, 1),
(12, 'Main Line Today | StageSide', 'http://www.mainlinetoday.com/Blogs/StageSide/', '2015-08-14 13:40:46', 4, 1),
(17, 'Serra Medical Clinic: Home', 'http://www.serramedicalclinic.com/', '2015-08-17 19:23:20', 5, 1),
(18, 'CVS pharmacy 645 Market Street, San Diego, CA 92101 location', 'http://www.cvs.com/stores/cvs-pharmacy-address/645+Market+Street-San+Diego-CA-92101/storeid=6332', '2015-08-17 19:23:20', 5, 1),
(19, 'Triple R - Melbourne Independent Radio - 102.7FM', 'http://www.rrr.org.au/', '2016-05-16 15:28:51', 16880525, 1);

-- --------------------------------------------------------

--
-- Структура таблицы `changes`
--

CREATE TABLE IF NOT EXISTS `changes` (
  `id` bigint(20) NOT NULL,
  `_transaction_descriptor_id` bigint(20) NOT NULL,
  `description` text NOT NULL,
  `contributors` bigint(20) NOT NULL,
  `change_code` varchar(300) NOT NULL,
  `change_value` varchar(500) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `changes`
--

INSERT INTO `changes` (`id`, `_transaction_descriptor_id`, `description`, `contributors`, `change_code`, `change_value`, `date_entered`, `_entered_by`) VALUES
(31, 82, 'Scope changed from &lt;b&gt;Wire&lt;/b&gt; to &lt;b&gt;ACH&lt;/b&gt;', 0, 'scope_changed', 'previous_scope_id=8|new_scope_id=9', '2015-08-09 11:10:09', 1),
(45, 82, 'Sub-category list changed to &lt;b&gt;ART GALLERIES &amp; DEALERS, ART SCHOOLS, MUSEUMS, NONCLASSIFIED ESTABLISHMENTS&lt;/b&gt; and suggested sub-categories &lt;b&gt;A Thing One, Museums For Fun, Thesubca, Thi Category&lt;/b&gt;', 0, 'sub_categories_changed', 'sub_category_ids=3,5,26,2166|suggested_sub_category_ids=15,3,1,2', '2015-08-11 08:57:16', 1),
(47, 82, 'Sub-category list changed to &lt;b&gt;Art Galleries &amp; Dealers, Art Schools, Museums, Nonclassified Establishments&lt;/b&gt; and suggested sub-categories &lt;b&gt;A Thing One, This Is A New Category&lt;/b&gt;&lt;br&gt;Flags added with a note: Please review this again. Thanks', 0, 'sub_categories_changed', 'sub_category_ids=3,5,26,2166|suggested_sub_category_ids=3,5', '2015-08-11 09:13:59', 1),
(48, 89, 'Scope changed from &lt;b&gt;Single Store Only&lt;/b&gt; to &lt;b&gt;Check&lt;/b&gt;', 0, 'scope_changed', 'previous_scope_id=1|new_scope_id=7', '2015-08-11 09:18:35', 1),
(50, 82, 'New store suggested &lt;b green&gt;walmart pharmacy | 701 W Cesar E Chavez Ave&lt;/b&gt;', 0, 'descriptor_new_store_suggestion', 'new_store_id=3', '2015-08-14 12:58:21', 1),
(51, 82, 'New store suggested &lt;b green&gt;Calton | 234 China Town Ave&lt;/b&gt;', 0, 'descriptor_new_store_suggestion', 'new_store_id=4', '2015-08-14 13:40:46', 1),
(52, 82, 'New store suggested &lt;b green&gt;Sera Pharmacies | 8100 Sunland Blvd&lt;/b&gt;', 0, 'descriptor_new_store_suggestion', 'new_store_id=5', '2015-08-14 14:08:36', 1),
(53, 82, 'New chain suggested &lt;b green&gt;Walmart Stores&lt;/b&gt;', 0, 'store_chain_added', 'chain_name=Walmart Stores|chain_id=3|store_id=3|store_type=suggested', '2015-08-14 22:32:50', 1),
(56, 82, 'New chain suggested &lt;b green&gt;Target Stores&lt;/b&gt;', 0, 'store_chain_added', 'chain_name=Target Stores|chain_id=6|store_id=1|store_type=suggested', '2015-08-15 13:39:34', 1),
(57, 82, 'Store data for &lt;b&gt;&lt;/b&gt; has been updated', 0, 'descriptor_store_update', 'suggested_store_id=4|store_type=suggested', '2015-08-17 16:59:30', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `change_flags`
--

CREATE TABLE IF NOT EXISTS `change_flags` (
  `id` bigint(20) NOT NULL,
  `_change_id` bigint(20) NOT NULL,
  `_flag_id` bigint(20) NOT NULL,
  `notes` varchar(300) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `change_flags`
--

INSERT INTO `change_flags` (`id`, `_change_id`, `_flag_id`, `notes`, `date_entered`, `_entered_by`) VALUES
(1, 1, 5, '', '2015-08-04 00:00:00', 1),
(2, 1, 6, '', '2015-08-04 00:00:00', 1),
(23, 10, 11, '', '2015-08-07 13:52:54', 1),
(31, 47, 11, '', '2015-08-11 09:25:01', 1),
(41, 93, 12, '', '2015-08-18 14:30:57', 1),
(42, 58, 11, '', '2015-08-18 19:19:20', 1),
(43, 94, 1, '', '2015-08-18 19:58:56', 1),
(44, 94, 2, '', '2015-08-18 19:58:56', 1),
(45, 105, 1, 'This is a note high.', '2015-08-19 22:35:43', 1),
(46, 105, 2, 'This is a note high.', '2015-08-19 22:35:43', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `change_log`
--

CREATE TABLE IF NOT EXISTS `change_log` (
  `id` bigint(20) NOT NULL,
  `_change_id` bigint(20) NOT NULL,
  `old_status` varchar(100) NOT NULL,
  `new_status` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `change_log`
--

INSERT INTO `change_log` (`id`, `_change_id`, `old_status`, `new_status`, `date_entered`, `_entered_by`) VALUES
(1, 2, '', 'pending', '2015-08-05 14:13:26', 0),
(2, 3, '', 'pending', '2015-08-05 14:18:10', 1),
(3, 4, '', 'pending', '2015-08-05 14:49:08', 1),
(4, 5, '', 'pending', '2015-08-05 14:49:33', 1),
(5, 6, '', 'pending', '2015-08-05 20:21:42', 1),
(6, 7, '', 'pending', '2015-08-05 20:24:44', 1),
(7, 8, '', 'pending', '2015-08-05 20:24:55', 1),
(8, 9, '', 'pending', '2015-08-05 20:25:29', 1),
(10, 31, '', 'verified', '2015-08-09 11:10:09', 1),
(11, 45, '', 'verified', '2015-08-11 08:57:16', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `cities`
--

CREATE TABLE IF NOT EXISTS `cities` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `district` varchar(300) NOT NULL,
  `population` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cities`
--

INSERT INTO `cities` (`id`, `name`, `_country_code`, `district`, `population`) VALUES
(1, 'New York', 'USA', 'New York', 8008278),
(2, 'Los Angeles', 'USA', 'California', 3694820),
(3, 'Chicago', 'USA', 'Illinois', 2896016),
(4, 'Houston', 'USA', 'Texas', 1953631),
(5, 'Philadelphia', 'USA', 'Pennsylvania', 1517550),
(6, 'Phoenix', 'USA', 'Arizona', 1321045),
(7, 'San Diego', 'USA', 'California', 1223400),
(8, 'Dallas', 'USA', 'Texas', 1188580),
(9, 'San Antonio', 'USA', 'Texas', 1144646),
(10, 'Detroit', 'USA', 'Michigan', 951270);

-- --------------------------------------------------------

--
-- Структура таблицы `cities_new`
--

CREATE TABLE IF NOT EXISTS `cities_new` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `district` varchar(300) NOT NULL,
  `population` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `cities_new`
--

INSERT INTO `cities_new` (`id`, `name`, `_country_code`, `district`, `population`) VALUES
(1, 'New York', 'USA', 'New York', 8008278),
(2, 'Los Angeles', 'USA', 'California', 3694820),
(3, 'Chicago', 'USA', 'Illinois', 2896016),
(4, 'Houston', 'USA', 'Texas', 1953631),
(5, 'Philadelphia', 'USA', 'Pennsylvania', 1517550),
(6, 'Phoenix', 'USA', 'Arizona', 1321045),
(7, 'San Diego', 'USA', 'California', 1223400),
(8, 'Dallas', 'USA', 'Texas', 1188580),
(9, 'San Antonio', 'USA', 'Texas', 1144646),
(10, 'Detroit', 'USA', 'Michigan', 951270);

-- --------------------------------------------------------

--
-- Структура таблицы `commissions_status_track`
--

CREATE TABLE IF NOT EXISTS `commissions_status_track` (
  `id` bigint(20) NOT NULL,
  `commission_id` bigint(20) NOT NULL,
  `commission_type` enum('other','transaction','network') NOT NULL DEFAULT 'other',
  `old_status` varchar(100) NOT NULL,
  `new_status` varchar(100) NOT NULL,
  `made_by` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `common_words`
--

CREATE TABLE IF NOT EXISTS `common_words` (
  `id` bigint(20) NOT NULL,
  `word` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `common_words`
--

INSERT INTO `common_words` (`id`, `word`) VALUES
(1, 'city'),
(2, 'happy'),
(3, 'service'),
(4, 'fresh'),
(5, 'public'),
(6, 'party'),
(7, 'the'),
(8, 'an'),
(9, 'of'),
(10, 'ltd');

-- --------------------------------------------------------

--
-- Структура таблицы `contacts`
--

CREATE TABLE IF NOT EXISTS `contacts` (
  `id` bigint(20) NOT NULL,
  `_owner_id` bigint(20) DEFAULT NULL,
  `first_name` varchar(300) NOT NULL,
  `last_name` varchar(300) NOT NULL,
  `title` varchar(300) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `email` varchar(100) NOT NULL,
  `source` varchar(300) NOT NULL,
  `source_link` varchar(300) NOT NULL,
  `photo_url` varchar(300) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `contacts`
--

INSERT INTO `contacts` (`id`, `_owner_id`, `first_name`, `last_name`, `title`, `phone`, `email`, `source`, `source_link`, `photo_url`, `date_entered`) VALUES
(1, 1, 'U.S.', 'Postal Service', '', '', 'addresschange@usps.gov', 'GMAIL.COM', '', '', '2015-10-02 19:58:04'),
(2, 1, 'Yofesi', '', '', '', 'muweereza@yahoo.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:04'),
(3, 1, 'GitHub', '', '', '', 'noreply@github.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:04'),
(4, 1, 'Facebook', '', '', '', 'notification+mhdku7hm@facebookmail.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:04'),
(5, 1, 'Gallup', '', '', '', 'customerengagement@gallup4.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:04'),
(6, 1, 'AT&amp;amp;T', 'Customer Care for Wireless', '', '', 'att-services.cn.155833030@emaildl.att-mail.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:05'),
(7, 1, 'U.S.', 'Postal Service', '', '', 'no-reply@usps.gov', 'GMAIL.COM', '', '', '2015-10-02 19:58:05'),
(8, 1, 'Netflix', '', '', '', 'info@mailer.netflix.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:05'),
(9, 1, 'Teller', '', '', '', 'tellernet@pfcu.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:05'),
(10, 1, 'LinkedIn', '', '', '', 'linkedin@e.linkedin.com', 'GMAIL.COM', '', '', '2015-10-02 19:58:05');

-- --------------------------------------------------------

--
-- Структура таблицы `contact_addresses`
--

CREATE TABLE IF NOT EXISTS `contact_addresses` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(100) NOT NULL,
  `country` varchar(100) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `is_primary` enum('Y','N') NOT NULL DEFAULT 'N',
  `address_type` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `contact_addresses`
--

INSERT INTO `contact_addresses` (`id`, `_user_id`, `address_line_1`, `address_line_2`, `city`, `state`, `country`, `zipcode`, `is_primary`, `address_type`, `date_entered`, `is_active`) VALUES
(4, 1, '890 Darlen Dr', '', 'Los Angeles', 'California', 'USA', '90023', 'N', 'work', '2015-10-06 21:39:41', 'N'),
(5, 1, '328 N Orange Dr Los Angeles CA', '', '', '', '', '', 'N', 'other', '2015-10-21 14:22:51', 'Y'),
(19, 1, 'new york', '', '', '', '', '', 'N', 'other', '2015-10-21 17:56:38', 'Y'),
(31, 1, 'las vegas', '', '', '', '', '', 'N', 'other', '2015-12-07 11:52:12', 'N'),
(35, 12, 'san francisco', '', '', '', '', '', 'N', 'other', '2015-12-07 13:05:03', 'Y'),
(36, 12, 'new york', '', '', '', '', '', 'N', 'other', '2015-12-07 13:06:24', 'Y'),
(54, 1, 'los angeles', '', '', '', '', '', 'N', 'other', '2016-03-04 16:54:00', 'Y'),
(55, 0, 'hollywood', '', '', '', '', '', 'N', 'other', '2016-03-31 20:30:45', 'Y'),
(56, 13, 'long beach', '', '', '', '', '', 'N', 'other', '2016-04-15 17:41:36', 'N');

--
-- Триггеры `contact_addresses`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__contact_addresses` AFTER INSERT ON `contact_addresses`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET total_imported_contacts=(total_imported_contacts+1) WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `contact_subscribe_list`
--

CREATE TABLE IF NOT EXISTS `contact_subscribe_list` (
  `id` bigint(20) NOT NULL,
  `_contact_id` bigint(20) DEFAULT NULL,
  `_contacted_by_user_id` bigint(20) DEFAULT NULL,
  `date_entered` datetime NOT NULL,
  `expiry_date` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `countries`
--

CREATE TABLE IF NOT EXISTS `countries` (
  `id` bigint(20) NOT NULL,
  `code` varchar(10) DEFAULT NULL,
  `name` varchar(300) NOT NULL,
  `continent` varchar(100) NOT NULL,
  `region` varchar(100) NOT NULL,
  `surface_area` bigint(20) NOT NULL,
  `population` bigint(20) NOT NULL,
  `capital` varchar(300) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `countries`
--

INSERT INTO `countries` (`id`, `code`, `name`, `continent`, `region`, `surface_area`, `population`, `capital`) VALUES
(1, 'ABW', 'Aruba', 'North America', 'Caribbean', 193, 103000, ''),
(2, 'AFG', 'Afghanistan', 'Asia', 'Southern and Central Asia', 652090, 22720000, ''),
(3, 'AGO', 'Angola', 'Africa', 'Central Africa', 1246700, 12878000, ''),
(4, 'AIA', 'Anguilla', 'North America', 'Caribbean', 96, 8000, ''),
(5, 'ALB', 'Albania', 'Europe', 'Southern Europe', 28748, 3401200, ''),
(6, 'AND', 'Andorra', 'Europe', 'Southern Europe', 468, 78000, ''),
(7, 'ANT', 'Netherlands Antilles', 'North America', 'Caribbean', 800, 217000, ''),
(8, 'ARE', 'United Arab Emirates', 'Asia', 'Middle East', 83600, 2441000, ''),
(9, 'ARG', 'Argentina', 'South America', 'South America', 2780400, 37032000, ''),
(10, 'ARM', 'Armenia', 'Asia', 'Middle East', 29800, 3520000, ''),
(11, 'USA', 'USA', 'North America', '', 0, 0, '');

-- --------------------------------------------------------

--
-- Структура таблицы `currencies`
--

CREATE TABLE IF NOT EXISTS `currencies` (
  `id` bigint(20) NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `buy_rate` float NOT NULL,
  `sell_rate` float NOT NULL,
  `premium` float NOT NULL,
  `valid_date` date NOT NULL,
  `is_latest` enum('Y','N') NOT NULL DEFAULT 'Y',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `currencies`
--

INSERT INTO `currencies` (`id`, `code`, `name`, `_country_code`, `buy_rate`, `sell_rate`, `premium`, `valid_date`, `is_latest`, `date_entered`) VALUES
(1, 'USD', 'U.S. Dollar', 'USA', 1, 1, 0, '2015-07-02', 'Y', '2015-07-02 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `flags`
--

CREATE TABLE IF NOT EXISTS `flags` (
  `id` bigint(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` enum('problem','user_defined') NOT NULL DEFAULT 'user_defined'
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `flags`
--

INSERT INTO `flags` (`id`, `name`, `type`) VALUES
(10, 'A New Flag Dah', 'user_defined'),
(1, 'Can not match descriptor', 'problem'),
(4, 'Duplicates and mis-matches', 'problem'),
(11, 'Great Catch', 'user_defined'),
(7, 'Insufficient API Data', 'user_defined'),
(5, 'Multiple roll-backs', 'user_defined'),
(2, 'Needs data entry', 'problem'),
(14, 'New Flag', 'user_defined'),
(15, 'new new flag', 'user_defined'),
(12, 'Requires Admin Attention', 'user_defined');

-- --------------------------------------------------------

--
-- Структура таблицы `help`
--

CREATE TABLE IF NOT EXISTS `help` (
  `id` bigint(20) NOT NULL,
  `help_code` varchar(100) NOT NULL,
  `title` varchar(300) NOT NULL,
  `details` text NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `keys`
--

CREATE TABLE IF NOT EXISTS `keys` (
  `id` int(11) NOT NULL,
  `key` varchar(40) NOT NULL,
  `level` int(2) NOT NULL,
  `ignore_limits` tinyint(1) NOT NULL DEFAULT '0',
  `date_created` int(11) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `keys`
--

INSERT INTO `keys` (`id`, `key`, `level`, `ignore_limits`, `date_created`) VALUES
(1, 'xt9487593-234u78i345345k-rt845k45p234', 1, 1, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `languages`
--

CREATE TABLE IF NOT EXISTS `languages` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `language` varchar(300) NOT NULL,
  `proficiency_level` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `list_actions`
--

CREATE TABLE IF NOT EXISTS `list_actions` (
  `id` bigint(20) NOT NULL,
  `list_type` varchar(100) NOT NULL,
  `content_type` varchar(100) NOT NULL,
  `display` varchar(300) NOT NULL,
  `action_code` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `list_actions`
--

INSERT INTO `list_actions` (`id`, `list_type`, `content_type`, `display`, `action_code`) VALUES
(1, 'users', 'tags', 'Possible Fraud', 'possible_fraud'),
(2, 'users', 'tags', 'Multiple Complaints', 'multiple_complaints'),
(3, 'users', 'tags', 'Insufficient Information', 'insufficient_information'),
(4, 'users', 'actions', 'Send Email', 'send_email'),
(5, 'users', 'actions', 'Block User', 'block_user'),
(6, 'users', 'actions', 'Purge User', 'purge_user'),
(7, 'users', 'actions', 'Change Group', 'change_group');

-- --------------------------------------------------------

--
-- Структура таблицы `naics_codes`
--

CREATE TABLE IF NOT EXISTS `naics_codes` (
  `id` bigint(20) NOT NULL,
  `code` varchar(100) NOT NULL,
  `main_category_code` varchar(100) NOT NULL,
  `sub_category_code` varchar(100) NOT NULL,
  `code_details` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `naics_codes`
--

INSERT INTO `naics_codes` (`id`, `code`, `main_category_code`, `sub_category_code`, `code_details`) VALUES
(1, '11', '', '', 'Agriculture, Forestry, Fishing and Hunting'),
(2, '111', '11', '', 'Crop Production'),
(3, '1111', '11', '111', 'Oilseed and Grain Farming'),
(4, '11111', '11', '111', 'Soybean Farming'),
(5, '111110', '11', '111', 'Soybean Farming'),
(6, '11112', '11', '111', 'Oilseed (except Soybean) Farming'),
(7, '111120', '11', '111', 'Oilseed (except Soybean) Farming '),
(8, '11113', '11', '111', 'Dry Pea and Bean Farming'),
(9, '111130', '11', '111', 'Dry Pea and Bean Farming '),
(10, '11114', '11', '111', 'Wheat Farming');

-- --------------------------------------------------------

--
-- Структура таблицы `payment_accepted`
--

CREATE TABLE IF NOT EXISTS `payment_accepted` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `payment_type` varchar(100) NOT NULL,
  `conditions` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
-- Структура таблицы `plaid_categories_web`
--

CREATE TABLE IF NOT EXISTS `plaid_categories_web` (
  `0` varchar(100) NOT NULL,
  `1` varchar(100) NOT NULL,
  `2` varchar(100) NOT NULL,
  `ID` varchar(100) NOT NULL,
  `type` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `plaid_categories_web`
--

INSERT INTO `plaid_categories_web` (`0`, `1`, `2`, `ID`, `type`) VALUES
('Bank Fees', '', '', '10000000', 'special'),
('Bank Fees', 'Overdraft', '', '10001000', 'special'),
('Bank Fees', 'ATM', '', '10002000', 'special'),
('Bank Fees', 'Late Payment', '', '10003000', 'special'),
('Bank Fees', 'Fraud Dispute', '', '10004000', 'special'),
('Bank Fees', 'Foreign Transaction', '', '10005000', 'special'),
('Bank Fees', 'Wire Transfer', '', '10006000', 'special'),
('Bank Fees', 'Insufficient Funds', '', '10007000', 'special'),
('Bank Fees', 'Cash Advance', '', '10008000', 'special'),
('Bank Fees', 'Excess Activity', '', '10009000', 'special');

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
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL,
  `custom_category_id` bigint(20) unsigned zerofill DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `promotions`
--

INSERT INTO `promotions` (`id`, `owner_id`, `owner_type`, `promotion_type`, `start_score`, `end_score`, `number_viewed`, `number_redeemed`, `new_customers`, `gross_sales`, `is_boosted`, `boost_budget`, `boost_start_date`, `boost_end_date`, `boost_remaining`, `name`, `amount`, `description`, `status`, `start_date`, `end_date`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`, `custom_category_id`) VALUES
(35, 5, 'person', 'cashback', 5, 10, 45, 45, 785, 502, 'N', 0, '2016-08-10 00:00:00', '2016-08-17 00:00:00', 52, 'qweqwe', 858, 'asdas', 'inactive', '2016-08-10 00:00:00', '2016-08-22 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, 00000000000000000102),
(36, 5, 'person', 'perk', 150, 203, 5, 45, 785, 45, 'Y', 0, '2016-08-25 00:00:00', '2016-08-17 00:00:00', 0, 'asdas', 505, 'asdasdwq', 'inactive', '2016-08-10 00:00:00', '2016-08-16 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, 00000000000000000226),
(37, 5, 'person', 'perk', 1020, 1085, 36, 780, 785, 52, 'N', 0, '2016-07-05 00:00:00', '2016-08-25 11:00:00', 5, 'asdasa', 4104, 'qwrqw', 'inactive', '2016-08-09 00:00:00', '2016-08-16 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, NULL),
(38, 5, 'person', 'cashback', 525, 555, 452, 452, 524, 5254, 'Y', 0, '2016-07-13 00:00:00', '2016-08-31 13:00:00', 0, 'qwegqwegqweg', 452, 'qwrqwr', 'active', '2016-08-09 00:00:00', '2016-08-23 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, NULL),
(39, 5, 'person', 'perk', 20, 50, 0, 0, 0, 0, 'N', 0, '2016-08-10 00:00:00', '2041-08-17 20:00:00', 0, '', 5, 'asdasd', 'deleted', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, NULL),
(40, 5, 'person', 'perk', 20, 50, 0, 0, 0, 0, 'N', 0, '2016-08-10 00:00:00', '2041-08-17 20:00:00', 0, '', 5, 'asdasd', 'deleted', '0000-00-00 00:00:00', '0000-00-00 00:00:00', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL, 00000000000000000102),
(41, 4, 'person', 'perk', 0, 0, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, '', 5, '', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(42, 4, 'person', 'perk', 0, 0, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, '', 5, '', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(43, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, '', 5, '', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(44, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(45, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'hgiulyilyu', 5, 'asdqwdqwgvqweqwh', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(46, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(47, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(48, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(49, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(50, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL),
(51, 4, 'person', 'perk', 100, 200, 0, 0, 0, 0, 'N', 0, '0000-00-00 00:00:00', '0000-00-00 00:00:00', 0, 'asdasdas', 5, '_DESCRIPTION_', 'pending', '2016-12-23 00:00:00', '2016-12-23 00:00:00', '0000-00-00 00:00:00', 2, '0000-00-00 00:00:00', NULL, NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `promotions_categories_levels`
--

CREATE TABLE IF NOT EXISTS `promotions_categories_levels` (
  `id` bigint(20) NOT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `level_id` bigint(20) DEFAULT NULL,
  `amount` bigint(20) NOT NULL DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=522 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `promotions_categories_levels`
--

INSERT INTO `promotions_categories_levels` (`id`, `category_id`, `level_id`, `amount`) VALUES
(498, 299, 97, 0),
(499, 300, 97, 0),
(508, 309, 97, 0),
(509, 310, 97, 0),
(510, 313, 97, 0),
(512, 299, 98, 0),
(513, 300, 98, 0),
(514, 309, 98, 0),
(515, 310, 98, 0),
(516, 313, 98, 0),
(517, 299, 99, 0),
(518, 300, 99, 0),
(519, 309, 99, 0),
(520, 310, 99, 0),
(521, 313, 99, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `promotions_custom_categories`
--

CREATE TABLE IF NOT EXISTS `promotions_custom_categories` (
  `id` bigint(20) NOT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `sub_category_id` bigint(20) DEFAULT NULL,
  `store_owner_id` bigint(20) DEFAULT NULL,
  `category_type` enum('category','sub_category','competitor') NOT NULL DEFAULT 'category',
  `category_label` varchar(50) NOT NULL DEFAULT '',
  `status` enum('active','deleted') NOT NULL DEFAULT 'active',
  `user_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=315 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `promotions_custom_categories`
--

INSERT INTO `promotions_custom_categories` (`id`, `category_id`, `sub_category_id`, `store_owner_id`, `category_type`, `category_label`, `status`, `user_id`) VALUES
(237, 1, 0, 3, 'category', 'Arts & Entertainment', 'active', 1),
(238, 1, 8, 4, 'sub_category', 'ARTS ORGANIZATIONS & INFORMATION', 'active', 5),
(239, 1, 9, 4, 'sub_category', 'BALLROOMS', 'active', 5),
(240, 2, 0, 4, 'category', 'Automotive', 'active', 5),
(241, 4, 0, 4, 'category', 'Clothing & Accessories', 'active', 5),
(242, 5, 0, 4, 'category', 'Community & Government', 'active', 5),
(243, 8, 0, 4, 'category', 'Education', 'active', 5),
(244, 9, 0, 4, 'category', 'Food & Dining', 'active', 5),
(245, 10, 0, 4, 'category', 'Health & Medicine', 'active', 5),
(246, 7, 0, 4, 'category', 'Construction & Contractors', 'active', 5),
(247, 1, 10, 4, 'sub_category', 'CULTURAL ATTRACTIONS EVENTS & FACILITIES', 'active', 5),
(248, 1, 1, 4, 'sub_category', 'AMUSEMENT & THEME PARKS', 'active', 5),
(299, 1, 0, 4, 'category', 'Arts & Entertainment', 'active', 4),
(300, 2, 0, 4, 'category', 'Automotive', 'active', 4),
(309, 10, 0, 4, 'category', 'Health & Medicine', 'active', 4),
(310, 9, 0, 4, 'category', 'Food & Dining', 'active', 4),
(311, 8, 0, 4, 'category', 'Education', 'deleted', 4),
(312, 7, 0, 4, 'category', 'Construction & Contractors', 'deleted', 4),
(313, 1, 7, 4, 'sub_category', 'ARTISTS & ART STUDIOS', 'active', 4),
(314, 0, 0, 4, 'category', '', 'deleted', 4);

-- --------------------------------------------------------

--
-- Структура таблицы `promotions_custom_levels`
--

CREATE TABLE IF NOT EXISTS `promotions_custom_levels` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL DEFAULT '',
  `level_id` int(11) DEFAULT '0',
  `category_id` bigint(20) DEFAULT '0',
  `status` enum('active','deleted') NOT NULL DEFAULT 'active',
  `user_id` bigint(20) DEFAULT NULL,
  `store_owner_id` bigint(20) DEFAULT NULL,
  `amount` bigint(20) DEFAULT '0'
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `promotions_custom_levels`
--

INSERT INTO `promotions_custom_levels` (`id`, `name`, `level_id`, `category_id`, `status`, `user_id`, `store_owner_id`, `amount`) VALUES
(92, 'test', 5, 0, 'active', 5, 4, 0),
(93, 'oppo[o', 5, 0, 'active', 5, 4, 0),
(94, 'asd', 5, 0, 'active', 5, 4, 0),
(95, 'te', 5, 0, 'deleted', 4, 4, 0),
(96, 'test', 5, 0, 'deleted', 4, 4, 0),
(97, 'level', 5, 0, 'active', 4, 4, 0),
(98, 'dfasdf', 5, 0, 'active', 4, 4, 0),
(99, 'dfghdg', 5, 0, 'active', 4, 4, 0);

-- --------------------------------------------------------

--
-- Структура таблицы `queries`
--

CREATE TABLE IF NOT EXISTS `queries` (
  `id` bigint(20) NOT NULL,
  `code` varchar(400) NOT NULL,
  `details` text NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=407 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `queries`
--

INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(1, 'get_user_by_id', 'SELECT U.*, \n\nIF((SELECT id FROM clout_v1_3cron.bank_accounts WHERE _user_id=''_USER_ID_'' AND status=''active'' LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS has_linked_accounts, \n\nIFNULL((SELECT _referred_by FROM referrals WHERE _user_id=''_USER_ID_'' AND referrer_type=''user'' LIMIT 1), '''') AS referrer \n\nFROM users U WHERE id =''_USER_ID_'' '),
(2, 'get_provider_list', 'SELECT * FROM contact_phone_providers WHERE full_carrier_name LIKE ''_SEARCH_PHRASE_'' _LIMIT_TEXT_'),
(4, 'get_store_details_by_id', 'SELECT A.* FROM \n(SELECT id, \ncap_first_letter_in_words(name) AS storeName, \ncap_first_letter_in_words(CONCAT(address_line_1, '' '', address_line_2, '' '', city,'' '', state, '', '', zipcode, '' '', _country_code)) AS address, \naddress_line_2, latitude, longitude, city, state, zipcode, description, \n_country_code AS country, \n(SELECT COUNT(id) FROM reviews WHERE _store_id=S.id) AS reviewCount, \n(SELECT AVG(review_score) FROM reviews WHERE _store_id=S.id) AS averageReviewScore, \nget_distance(_LATITUDE_, _LONGITUDE_, S.latitude, S.longitude) AS distance,\nget_store_score(''_USER_ID_'', S.id) AS storeScore,\nhas_perk(''_USER_ID_'', S.id) AS hasPerk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS minCashBack,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS maxCashBack,\n(SELECT COUNT(id) FROM store_photos WHERE _store_id=S.id) AS photoCount, \nLOWER(S.website) AS website, \nS.phone_number AS telephone, \n(SELECT C1.name FROM categories_level_1 C1 WHERE C1.id IN (SELECT SC._category_id FROM store_sub_categories SC WHERE SC._store_id=S.id) LIMIT 1) AS category,\nIF((SELECT id FROM store_favorites WHERE _user_id=''_USER_ID_'' AND _store_id=S.id LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS isFavorite,\nIF((SELECT id FROM store_offer_requests WHERE _user_id=''_USER_ID_'' AND _store_id=S.id LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS isOnVip\n \nFROM stores S WHERE S.id=''_STORE_ID_'') A'),
(5, 'get_clout_score', 'SELECT *, total_score AS clout_score FROM clout_v1_3cron.cacheview__clout_score WHERE user_id=''_USER_ID_'''),
(6, 'get_store_score', 'SELECT get_store_score(''_USER_ID_'', ''_STORE_ID_'') AS store_score'),
(7, 'get_score_level', 'SELECT A.level AS level, \nIF((SELECT id FROM clout_v1_3cron.score_levels WHERE level > A.level LIMIT 1) IS NULL, 0, \n(SELECT (high_end_score - _SCORE_)+1 FROM clout_v1_3cron.score_levels WHERE level=A.level LIMIT 1)) AS points_to_next_level\nFROM \n(SELECT MAX(level+0) AS level FROM clout_v1_3cron.score_levels WHERE low_end_score <= _SCORE_) A'),
(8, 'get_a_store_score_cache', 'SELECT * FROM clout_v1_3cron.cacheview__store_score_by_store LIMIT 1'),
(9, 'get_a_clout_score_cache', 'SELECT * FROM clout_v1_3cron.cacheview__clout_score LIMIT 1'),
(10, 'get_content_explanation', 'SELECT * FROM system_content WHERE content_code IN(_CODE_LIST_) AND is_active=''Y'''),
(11, 'get_score_criteria_description', 'SELECT * FROM clout_v1_3cron.score_criteria WHERE code IN (_CRITERIA_LIST_) _QUERY_PART_'),
(13, 'get_store_score_details', 'SELECT A.* FROM (\n(SELECT * FROM clout_v1_3cron.cacheview__store_score_by_store WHERE store_id=''_STORE_ID_'' AND user_id=''_USER_ID_'' LIMIT 1)\nUNION\n(SELECT *, ''N'' AS is_reported FROM clout_v1_3cron.cacheview__store_score_by_category WHERE user_id=''_USER_ID_'' AND sub_category_id IN\n        (SELECT B1.id FROM categories_level_2 B1 LEFT JOIN store_sub_categories C ON (B1.id=C._sub_category_id) WHERE C._store_id=''_STORE_ID_'')\nORDER BY total_score DESC LIMIT 1)\nUNION\n(SELECT *, ''N'' AS is_reported FROM clout_v1_3cron.cacheview__store_score_by_default WHERE user_id=''_USER_ID_'' LIMIT 1)) A LIMIT 1;'),
(14, 'get_score_level_data', 'SELECT * FROM clout_v1_3cron.score_levels WHERE 1=1 _CONDITION_ _ORDER_BY_'),
(15, 'get_promotions_within_score_range', 'SELECT *, id AS promotion_id FROM clout_v1_3cron.cacheview__promotions_summary WHERE owner_id=''_STORE_ID_'' AND promotion_type IN (_PROMOTION_TYPES_) AND (_SCORE_ BETWEEN start_score AND end_score OR (_SCORE_ >= 1000 AND end_score = 1000)) _ADDITIONAL_CONDITIONS_  _ORDER_CONDITION_ _LIMIT_TEXT_'),
(17, 'get_rule_for_promotion', 'SELECT * FROM promotion_rules WHERE _promotion_id=''_PROMOTION_ID_'' AND rule_type=''_RULE_TYPE_'''),
(18, 'get_promotion_rules', 'SELECT * FROM promotion_rules WHERE _promotion_id=''_PROMOTION_ID_'''),
(19, 'get_store_locations_by_id', 'SELECT S.*, \nIF((SELECT id FROM store_favorites WHERE _store_id=S.id AND _user_id=''_USER_ID_'' LIMIT 1) IS NULL, ''N'', ''Y'') AS is_favorite, \nCONCAT(address_line_1, '', '', city, '' '', state, '', '', zipcode, '' '', _country_code) AS full_address\n\nFROM stores S \nWHERE S.id IN (SELECT S2.id FROM stores S1 LEFT JOIN stores S2 ON (S1._store_owner_id=S2._store_owner_id) \n	WHERE S1.id=''_STORE_ID_'' AND S1._store_owner_id <> ''3'')'),
(20, 'add_user_checkin', 'INSERT INTO user_geo_tracking (_user_id, tracking_time, longitude, latitude, address, city, zipcode, state, _checkin_store_id, _checkin_offer_id, details, source ) VALUES (''_USER_ID_'', NOW(), ''_LONGITUDE_'', ''_LATITUDE_'', ''_ADDRESS_'', ''_CITY_'', ''_ZIPCODE_'', ''_STATE_'', ''_STORE_ID_'', ''_OFFER_ID_'', ''_DETAILS_'', ''_SOURCE_'' )'),
(21, 'add_store_schedule', 'INSERT INTO store_schedule (_store_id, _promotion_id, _user_id, scheduler_name, scheduler_email, scheduler_phone, telephone_provider_id, schedule_date, number_in_party, special_request, date_entered, _entered_by, last_updated, _last_updated_by) \n\n(SELECT owner_id AS _store_id, ''_PROMOTION_ID_'' AS _promotion_id, ''_USER_ID_'' AS _user_id, ''_SCHEDULER_NAME_'' AS scheduler_name, ''_SCHEDULER_EMAIL_'' AS scheduler_email, ''_SCHEDULER_PHONE_'' AS scheduler_phone, ''_PHONE_PROVIDER_ID_'' AS telephone_provider_id, ''_SCHEDULE_DATE_'' AS schedule_date, ''_NUMBER_IN_PARTY_'' AS number_in_party, ''_SPECIAL_REQUEST_'' AS special_request, NOW() AS date_entered, ''_USER_ID_'' AS _entered_by, NOW() AS last_updated, ''_USER_ID_'' AS _last_updated_by FROM clout_v1_3cron.promotions WHERE id=''_PROMOTION_ID_'' LIMIT 1)\n\n'),
(22, 'get_sending_format', 'SELECT * FROM user_preferred_communication WHERE _user_id=''_USER_ID_'' AND message_type=''_MESSAGE_TYPE_'' AND message_format=''_MESSAGE_FORMAT_'''),
(23, 'get_store_staff', 'SELECT * FROM store_staff WHERE _store_id=''_STORE_ID_'''),
(24, 'get_cron_schedules', 'SELECT * FROM cron_schedule WHERE is_done=''_IS_DONE_'' _EXTRA_CONDITIONS_ _LIMIT_TEXT_'),
(25, 'add_event_log', 'INSERT INTO activity_log (user_id, activity_code, result, uri, log_details, ip_address, event_time)\nVALUES (''_USER_ID_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_IP_ADDRESS_'', NOW())'),
(26, 'get_message_template', 'SELECT *, copy_admin AS copyadmin FROM message_templates WHERE message_type=''_MESSAGE_TYPE_'''),
(27, 'get_provider_email_domain', 'SELECT IF(P.mms_email_domain <>'''',P.mms_email_domain,P.sms_email_domain) AS email_domain FROM contact_phones C LEFT JOIN contact_phone_providers P ON (C._provider_id=P.id AND C._user_id=''_USER_ID_'') WHERE telephone=''_TELEPHONE_''  HAVING email_domain IS NOT NULL LIMIT 1'),
(28, 'record_message_exchange', 'INSERT INTO message_exchange (template_id, template_type, details, `subject`, attachment_url, _sender_id, _recipient_id, send_system, send_system_result, date_entered, _entered_by)\n\n(SELECT T.id AS template_id, ''system'' AS template_type, ''_DETAILS_'' AS details, ''_SUBJECT_'' AS `subject`, ''_ATTACHMENT_URL_'' AS attachment_url, \n''_SENDER_ID_'' AS _sender_id, \nU.id AS _recipient_id, ''Y'' AS send_system, ''success'' AS send_system_result, NOW() AS date_entered, \n''_SENDER_ID_'' AS _entered_by\nFROM message_templates T LEFT JOIN users U ON (U.id IN (''_RECIPIENT_ID_'')) WHERE T.message_type=''_TEMPLATE_CODE_'')\n\nON DUPLICATE KEY UPDATE `subject`=VALUES(`subject`), details=VALUES(details), attachment_url=VALUES(attachment_url), date_entered=VALUES(date_entered);'),
(29, 'get_users_in_id_list', 'SELECT first_name, last_name, gender, email_address, telephone, id AS user_id, CONCAT(first_name, '' '', last_name) AS user_name FROM users WHERE id IN (''_ID_LIST_'')'),
(30, 'get_schedule_details', 'SELECT P.owner_id AS store_id, S.name AS store_name, CONCAT(S.address_line_1,'' '', S.address_line_2, '', '', S.city, '' '', S.state, '' '', S.zipcode) AS store_address, P.date_entered AS offer_date, P.description AS offer_description, \n(SELECT GROUP_CONCAT(rule_details SEPARATOR '', '') FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=P.id) AS  offer_conditions \nFROM clout_v1_3cron.promotions P LEFT JOIN stores S ON (P.owner_id=S.id) WHERE P.id=''_PROMOTION_ID_'''),
(31, 'get_bank_list', 'SELECT id AS bank_id, institution_name AS bank_name, logo_url, institution_code AS bank_code, \n\nIF(institution_name = ''_PHRASE_'', 1,\nIF(institution_name LIKE CONCAT(''_PHRASE_'',''%''), 2, \nIF(institution_name LIKE CONCAT(''%'',''_PHRASE_'',''%''), 3, \nIF(institution_name LIKE CONCAT(''%'',''_PHRASE_''), 4, \n5)))) AS priority\n\nFROM clout_v1_3cron.banks \nWHERE is_featured IN (_FEATURED_STATUS_) \nAND ((''_PHRASE_'' <> '''' AND MATCH(institution_name) AGAINST (''_PHRASE_'')) OR ''_PHRASE_'' = '''') \n\n_CODE_CONDITION_\n\nORDER BY priority, institution_name \n_LIMIT_TEXT_'),
(33, 'get_transaction_scope_list', 'SELECT id AS scope_id, scope_name, IF(''_DESCRIPTOR_ID_'' <> '''' AND (SELECT _scope_id FROM transaction_descriptors WHERE id=''_DESCRIPTOR_ID_'' LIMIT 1) = id, ''Y'', ''N'') AS is_selected FROM transaction_descriptor_scopes'),
(34, 'get_transaction_problem_flags', 'SELECT F.id, F.name\n FROM flags F WHERE F.`type`=''problem'' ORDER BY F.`name` '),
(35, 'get_category_level_1_list', 'SELECT C1.id, C1.name,''N'' AS is_selected\n\nFROM `categories_level_1` C1 WHERE C1.is_active=''Y'' ORDER BY C1.name ASC'),
(36, 'get_category_level_2_list', 'SELECT C2.id, C2.name, C2._category_id AS level_1_id,\nIF((SELECT CS.id FROM transaction_descriptor_sub_categories CS WHERE CS._sub_category_id=C2.id AND CS._descriptor_id=''_DESCRIPTOR_ID_'' ) IS NOT NULL, ''Y'',''N'') AS is_selected\n\n FROM categories_level_2 C2 WHERE C2.is_active = ''Y'' ORDER BY name'),
(37, 'get_match_attempts_by_descriptor', 'SELECT M._matched_chain_id AS id, \nC.name AS location_name, \n\nCONCAT(C.address_line_1, '' '', C.city, '' '', C.state, '', '', C.zipcode) AS location_address, \n\n(SELECT CT.name FROM categories_level_1 CT LEFT JOIN chain_categories CC ON (CC._category_id=CT.id) WHERE CC._chain_id=M._matched_chain_id LIMIT 1) AS chain_category,\n\nIF((SELECT id FROM transaction_descriptor_chains WHERE _chain_id=M._matched_chain_id LIMIT 1), ''Y'', ''N'') AS is_selected,\n\nIF(C.is_live=''Y'',''N'',''Y'') AS is_new_chain, \n\n(SELECT COUNT(DISTINCT CR.id) FROM chain_references CR\nLEFT JOIN transaction_descriptor_chains TC ON (CR._chain_id=TC._chain_id) WHERE TC._transaction_descriptor_id=T._descriptor_id) AS link_count, \n\nC.name AS chain_name \n\nFROM transaction_descriptor_transactions T \nLEFT JOIN match_history_chains M ON (M._raw_transaction_id=T._transactions_raw_id) \nLEFT JOIN chains C ON (C.id=M._matched_chain_id)\nWHERE T._descriptor_id=''_DESCRIPTOR_ID_'''),
(38, 'get_descriptor_change_flags', 'SELECT C.id AS flag_id, C._change_id AS change_id, F.name AS flag_name \nFROM change_flags C \nLEFT JOIN flags F ON (C._flag_id=F.id) \nWHERE C._change_id=''_CHANGE_ID_'' AND F.name LIKE ''_PHRASE_'' _LIMIT_TEXT_'),
(39, 'get_flag_by_descriptor_change', 'SELECT F.name AS flag_name, C._transaction_descriptor_id AS descriptor_id, CF._change_id AS change_id, C.description AS change_name \nFROM change_flags CF \nLEFT JOIN flags F ON (F.id=CF._flag_id) \nLEFT JOIN changes C ON (CF._change_id=C.id)\n\nWHERE CF.id=''_CHANGE_FLAG_ID_'''),
(40, 'add_change_record', 'INSERT INTO changes (_transaction_descriptor_id, description, change_code, change_value, date_entered, _entered_by) VALUES \n\n(''_DESCRIPTOR_ID_'', ''_DESCRIPTION_'', ''_CHANGE_CODE_'', ''_CHANGE_VALUE_'', NOW(), ''_USER_ID_'')'),
(41, 'add_change_log', 'INSERT INTO change_log (_change_id, old_status, new_status, date_entered, _entered_by) VALUES \n\n(''_CHANGE_ID_'', ''_OLD_STATUS_'', ''_NEW_STATUS_'', NOW(), ''_USER_ID_'')'),
(42, 'get_all_change_flags', 'SELECT id AS flag_id, name AS flag_name FROM flags WHERE type=''user_defined'' AND name LIKE ''_PHRASE_'' _LIMIT_TEXT_'),
(43, 'add_new_flag', 'INSERT IGNORE INTO flags (`name`, `type`) VALUES \n(''_NAME_'', ''_TYPE_'')'),
(44, 'add_change_flags', 'INSERT IGNORE INTO change_flags (_change_id, _flag_id, notes, date_entered, _entered_by) \n\n(SELECT DISTINCT ''_CHANGE_ID_'' AS _change_id, F.id AS _flag_id, ''_NOTES_'' AS notes, NOW(), ''_USER_ID_'' AS _entered_by FROM flags F WHERE F.id IN (_FLAG_IDS_)) '),
(45, 'delete_change_flag', 'DELETE FROM change_flags WHERE id=''_CHANGE_FLAG_ID_'''),
(46, 'get_descriptor_list', 'SELECT D.id AS descriptor_id, \nD.description, \n(SELECT scope_name FROM `transaction_descriptor_scopes` WHERE id=D._scope_id) AS scope, \nD.possible_location_matches AS possible_locations, \nD.affected_transaction_amount AS affected_amount, \nD.affected_transaction_number AS affected_number, \nD.status, \n(SELECT C1.`name` FROM `transaction_descriptor_sub_categories` SC2 \n	LEFT JOIN categories_level_2 C2 ON (C2.id=SC2._sub_category_id) \n	LEFT JOIN categories_level_1 C1 ON (C2._category_id=C1.id) WHERE SC2._descriptor_id=D.id AND C1.`name` IS NOT NULL LIMIT 1) AS category, \n(SELECT C.`name` FROM transactions_raw R LEFT JOIN transactions T ON (T._raw_id=R.id) \n	LEFT JOIN store_chains SC ON (SC._store_id=T._store_id) LEFT JOIN chains C ON (C.id=SC._chain_id)\n	WHERE R.payee_name = D.description AND C.`name` IS NOT NULL LIMIT 1) AS sample_chain, \n\nIF((SELECT _chain_id FROM transaction_descriptor_chains WHERE _transaction_descriptor_id=D.id ORDER BY is_selected DESC LIMIT 1) IS NOT NULL, \n	IF((SELECT id FROM transaction_descriptors_suggested_stores WHERE _transaction_descriptor_id=D.id LIMIT 1) IS NOT NULL, \n		(SELECT COUNT(DS.id) FROM transaction_descriptors_suggested_stores DS \n		LEFT JOIN transaction_descriptor_chains DC ON (DS._chain_id=DC._chain_id AND DS._transaction_descriptor_id=DC._transaction_descriptor_id AND DC.is_selected=''Y'')\n		WHERE DC._transaction_descriptor_id=D.id), 1)\n, 0) AS store_match_count, \n\n(SELECT COUNT(DISTINCT H._matched_store_id) FROM match_history_stores H \n	LEFT JOIN transactions_raw R ON (H._raw_transaction_id=R.id) WHERE R.payee_name = D.description AND H._matched_store_id IS NOT NULL) AS possible_matches, \n\nIF(''_PHRASE_'' <> '''', \nIF(D.description = ''_PHRASE_'', 1, \nIF(D.description LIKE CONCAT(''%'',''_PHRASE_'',''%''), 2,\nIF(D.description LIKE CONCAT(''_PHRASE_'',''%''), 3,\nIF(D.description LIKE CONCAT(''%'',''_PHRASE_''), 4,\nIF(D.description LIKE CONCAT(LEFT(''_PHRASE_'',LOCATE('' '',''_PHRASE_'') - 1),''%''), 5, 6\n))))), 7) AS list_order\n\n\nFROM `transaction_descriptors` D \nLEFT JOIN transactions_raw R ON (R.payee_name = D.description) \nLEFT JOIN changes CH ON (CH._transaction_descriptor_id = D.id AND CH._entered_by <> ''0'' AND CH._entered_by IS NOT NULL)\nWHERE \n(''_PHRASE_'' = '''' || (''_PHRASE_'' <> '''' AND MATCH D.description AGAINST (''_PHRASE_'')))\n _BANK_FILTER_\n _STATUS_FILTER_BEFORE_\n _ADMIN_FILTER_\nGROUP BY D.description \n _STATUS_FILTER_AFTER_\nORDER BY list_order ASC, D.affected_transaction_amount DESC \n  _LIMIT_TEXT_'),
(47, 'update_descriptor_field', 'UPDATE transaction_descriptors SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_DESCRIPTOR_ID_'''),
(50, 'add_matching_rule_due_to_scope', 'INSERT INTO store_match_rules (rule_type, confidence, match_store_id, details, is_active, descriptor_id) \n(SELECT ''reject'' AS rule_type, ''100'' AS confidence, '''' AS match_store_id, \nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\nFROM transaction_descriptors D \nWHERE D.id = ''_DESCRIPTOR_ID_'' AND status=''unqualified'')\n\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(51, 'get_descriptor_change_list', 'SELECT A.*, \nIF(A.last_admin_id=''_USER_ID_'' \n	OR (SELECT id FROM `user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL AND A.latest_status <> ''verified'', \n''Y'', ''N'') AS can_rollback FROM\n\n(SELECT C.id, \n(SELECT UNIX_TIMESTAMP(date_entered) FROM change_log WHERE _change_id=C.id ORDER BY date_entered DESC LIMIT 1) AS last_update, \nC.`contributors`, \nC.description, \n(SELECT COUNT(id) FROM change_flags WHERE _change_id=C.id) AS flag_count, \nIF((SELECT id FROM `user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS can_approve, \nIF((SELECT id FROM `user_security_settings` WHERE _user_id=''_USER_ID_'' AND user_type IN (''clout_owner'',''clout_admin_user'') LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS can_reject, \n(SELECT CONCAT(U.first_name, '' '', U.last_name) \n	FROM users U  \n	LEFT JOIN change_log CL ON (U.id=CL._entered_by) \n	LEFT JOIN `user_security_settings` S ON (U.id=S._user_id AND S.user_type IN (''clout_owner'',''clout_admin_user''))\n	WHERE CL._change_id=C.id\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_name, \n\n(SELECT S.user_type_level \n	FROM change_log CL\n	LEFT JOIN `user_security_settings` S ON (CL._entered_by=S._user_id AND S.user_type IN (''clout_owner'',''clout_admin_user''))\n	WHERE CL._change_id=C.id\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_level, \n\n\n(SELECT CL._entered_by \n	FROM change_log CL \n	WHERE CL._change_id=C.id\n	ORDER BY CL.date_entered DESC LIMIT 1) AS last_admin_id, \n\n(SELECT new_status FROM change_log WHERE _change_id=C.id ORDER BY date_entered DESC LIMIT 1) AS latest_status\n\nFROM changes C \nWHERE C._transaction_descriptor_id = ''_DESCRIPTOR_ID_'' AND C.description LIKE ''_PHRASE_'' \nORDER BY C.date_entered DESC \n _LIMIT_TEXT_\n) A'),
(52, 'get_category_details', 'SELECT * FROM `categories_level_1` WHERE id=''_CATEGORY_ID_'''),
(53, 'add_sub_category_suggestion', 'INSERT IGNORE INTO `categories_level_2_suggestions` (	suggestion, _categories_level_1_id, _transaction_descriptor_id, date_entered, _entered_by) VALUES \n\n(''_SUGGESTION_'', ''_CATEGORY_ID_'', ''_DESCRIPTOR_ID_'', NOW(), ''_USER_ID_'')'),
(55, 'get_category_level_2_suggestion_list', 'SELECT CONCAT(C2.id,''__'',C2._categories_level_1_id) AS id, C2.suggestion AS name, C2._categories_level_1_id AS level_1_id,\nIF((SELECT CS.id FROM transaction_descriptor_sub_categories_suggestions CS WHERE CS._sub_category_id=C2.id AND CS._descriptor_id=''_DESCRIPTOR_ID_'' ) IS NOT NULL, ''Y'',''N'') AS is_selected\n\n FROM `categories_level_2_suggestions` C2 WHERE C2.status = ''pending'' ORDER BY C2.suggestion'),
(56, 'get_sub_category_name_list', 'SELECT GROUP_CONCAT(cap_first_letter_in_words(name) SEPARATOR '', '') AS list FROM `categories_level_2` WHERE id IN (''_ID_LIST_'')'),
(57, 'get_suggested_sub_category_name_list', 'SELECT GROUP_CONCAT(cap_first_letter_in_words(suggestion) SEPARATOR '', '') AS list FROM `categories_level_2_suggestions` WHERE id IN (''_ID_LIST_'')'),
(60, 'add_suggested_descriptor_categories', 'INSERT INTO `transaction_descriptor_sub_categories_suggestions` (_descriptor_id, _sub_category_id, suggestion_count) \n\n(SELECT DISTINCT ''_DESCRIPTOR_ID_'' AS _descriptor_id, C.id AS _sub_category_id, ''1'' AS suggestion_count FROM categories_level_2 C \nWHERE C.id IN (''_ID_LIST_'')) \n\nON DUPLICATE KEY UPDATE suggestion_count=(suggestion_count+1)'),
(61, 'get_sample_descriptor_category', 'SELECT C1.name AS sample_category FROM transaction_descriptor_sub_categories DC \nLEFT JOIN categories_level_2 C2 ON (C2.id=DC._sub_category_id) \nLEFT JOIN categories_level_1 C1 ON (C1.id=C2._category_id) \nWHERE DC._descriptor_id=''_DESCRIPTOR_ID_'' LIMIT 1'),
(62, 'get_level_1_categories', 'SELECT id AS category_id, name AS category_name FROM categories_level_1 WHERE is_active=''Y'''),
(63, 'search_stores_by_fields', 'SELECT *, cap_first_letter_in_words(`address_line_1`) AS address_line_1, cap_first_letter_in_words(`name`) AS store_name, \nIF(`name` = ''_NAME_'', 1, \nIF(`name` LIKE CONCAT(''_NAME_'', ''%''), 2, \nIF(`name` LIKE CONCAT(''%'', ''_NAME_'', ''%''), 3, \n4))) AS list_order\n\nFROM stores \nWHERE MATCH(`name`) AGAINST(CONCAT(''+"'', SUBSTRING_INDEX(''_NAME_'', '' '', 1), ''"'')) \n	AND LENGTH(SUBSTRING_INDEX(''_NAME_'', '' '', 1)) > 3 \n	AND `name` LIKE CONCAT(''%'', SUBSTRING_INDEX(''_NAME_'', '' '', 1), ''%'') \n	AND `address_line_1` LIKE ''_ADDRESS_''\n\nORDER BY list_order ASC \n_LIMIT_TEXT_;'),
(64, 'add_new_store', 'INSERT IGNORE INTO `store_suggestions` (name, website, address, zipcode, store_id, date_entered, _entered_by, last_updated, _last_updated_by) VALUES \n(''_NAME_'', ''_WEBSITE_'', ''_ADDRESS_'', ''_ZIPCODE_'', ''_STORE_ID_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'')'),
(67, 'get_list_of_stores', 'SELECT S.id AS store_id, cap_first_letter_in_words(S.`name`) AS store_name, address_line_1, cap_first_letter_in_words(address_line_1) AS address, address_line_2, \ncity, state, zipcode, _country_code AS country, website, \nIF(S.`name` = ''_PHRASE_'', 1, \nIF(S.`name` LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.`name` LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3, \nIF(''_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 4, \nIF((''_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_PHRASE_''),''%'')), 5, \nIF(''_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%''), 6, \n7)))))) AS list_order\nFROM stores S\nLEFT JOIN store_sub_categories C ON (C._store_id = S.id)\n\nWHERE MATCH(S.`name`) AGAINST(CONCAT(''+"'', SUBSTRING_INDEX(''_PHRASE_'', '' '', 1), ''"'')) \n	AND LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1)) > 3 \n	AND S.`name` LIKE CONCAT(''%'', SUBSTRING_INDEX(''_PHRASE_'', '' '', 1), ''%'') \n	AND ((''_ZIPCODE_'' <> '''' AND S.`zipcode` = ''_ZIPCODE_'') OR ''_ZIPCODE_'' = '''')\n	AND ((''_WEBSITE_'' <> '''' AND S.`website` LIKE CONCAT(''%'',''_WEBSITE_'',''%'')) OR ''_WEBSITE_'' = '''')\n	AND ((''_CATEGORY_IDS_'' <> '''' AND C.`_category_id` IN (''_CATEGORY_IDS_'')) OR ''_CATEGORY_IDS_'' = '''')\nGROUP BY S.id \nORDER BY list_order ASC \n_LIMIT_TEXT_;'),
(68, 'add_reference_link', 'INSERT INTO `chain_references` (details, reference_link, date_entered, _chain_id, _entered_by) VALUES \n\n(''_LINK_TEXT_'', ''_LINK_'', NOW(), ''_CHAIN_ID_'', ''_USER_ID_'')'),
(69, 'get_chain_links', 'SELECT id AS link_id, details AS link_text, reference_link AS link FROM chain_references WHERE _chain_id=''_CHAIN_ID_'''),
(70, 'get_chains_for_suggested', 'SELECT C.id AS chain_id, C.name AS chain_name, C.is_live, \nIF(''_STORE_ID_'' <> '''' AND (SELECT id FROM store_suggestions WHERE id=''_STORE_ID_'' AND chain_id=C.id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS is_selected \nFROM `chains` C \nWHERE C.name LIKE ''%_PHRASE_%'' \n\nORDER BY is_selected DESC, C.is_live DESC  \n_LIMIT_TEXT_'),
(71, 'get_chains_for_store', 'SELECT C.id AS chain_id, C.name AS chain_name, C.is_live, \nIF(''_STORE_ID_'' <> '''' AND \n((SELECT S.id FROM store_chains S WHERE S._store_id=''_STORE_ID_'' AND S._chain_id=C.id LIMIT 1) IS NOT NULL\nOR (SELECT S.id FROM store_suggestions S WHERE S.store_id=''_STORE_ID_'' AND chain_id=C.id LIMIT 1) IS NOT NULL), ''Y'',''N'') AS is_selected \nFROM `chains` C \nWHERE C.name LIKE ''%_PHRASE_%'' \n\nORDER BY is_selected DESC, C.is_live DESC  \n_LIMIT_TEXT_'),
(72, 'get_chain_by_id', 'SELECT * FROM chains WHERE id=''_CHAIN_ID_'''),
(73, 'update_chain_field', 'UPDATE chains SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_CHAIN_ID_'''),
(74, 'add_new_chain', 'INSERT IGNORE INTO chains (name, is_live, date_entered, _entered_by) VALUES \n\n(''_CHAIN_NAME_'', ''Y'', NOW(), ''_USER_ID_'')'),
(75, 'link_store_to_chain', 'INSERT IGNORE INTO store_chains (	_chain_id, _store_id, date_entered, _entered_by) VALUES \n\n(''_CHAIN_ID_'', ''_STORE_ID_'', NOW(), ''_USER_ID_'')'),
(76, 'link_suggested_to_chain', 'UPDATE store_suggestions SET chain_id=''_CHAIN_ID_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' WHERE id=''_STORE_ID_'''),
(77, 'get_edit_chain_details_by_id', 'SELECT C.id AS chain_id, C.name AS chain_name, C.address_line_1 AS address, C.zipcode, C.website, CAT._category_id AS category_id, (SELECT name FROM categories_level_1 WHERE id=CAT._category_id LIMIT 1) AS category FROM chains C LEFT JOIN chain_categories CAT ON (C.id=CAT._chain_id) WHERE C.id=''_CHAIN_ID_'' LIMIT 1'),
(78, 'get_edit_suggested_details_by_id', 'SELECT id AS store_id, `name` AS store_name,  address,\nchain_id,\n(SELECT C.name FROM chains C WHERE C.id=chain_id AND chain_id <> ''0'' LIMIT 1) AS chain_name,  \n(SELECT _category_id FROM transaction_descriptors_suggested_stores WHERE _suggested_store_id=S.id LIMIT 1) AS store_category, \nzipcode, country, website, store_id AS actual_store_id \nFROM store_suggestions S WHERE id=''_STORE_ID_'''),
(79, 'update_store_details', 'UPDATE stores SET name=''_NAME_'', address_line_1=''_ADDRESS_'', website=''_WEBSITE_'', zipcode=''_ZIPCODE_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' WHERE id=''_STORE_ID_'''),
(80, 'get_suggested_by_store_id', 'SELECT * FROM store_suggestions WHERE store_id=''_STORE_ID_'''),
(81, 'remove_reference_links', 'DELETE FROM chain_references WHERE _chain_id=''_CHAIN_ID_'''),
(82, 'update_suggested_details', 'UPDATE store_suggestions SET name=''_NAME_'', website=''_WEBSITE_'', address=''_ADDRESS_'', zipcode=''_ZIPCODE_'' WHERE id=''_STORE_ID_'''),
(83, 'get_descriptor_location_ids', 'SELECT DISTINCT _suggested_store_id AS location_id FROM transaction_descriptors_suggested_stores WHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'''),
(84, 'remove_descriptor_attachment', 'DELETE FROM transaction_descriptors_suggested_stores WHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'' AND _suggested_store_id IN (''_STORE_IDS_'')'),
(85, 'get_descriptor_real_store_ids', 'SELECT DISTINCT store_id FROM transaction_descriptors_suggested_stores WHERE store_id <> ''0'' AND _transaction_descriptor_id=''_DESCRIPTOR_ID_'''),
(86, 'add_matching_rule_due_to_location', 'INSERT INTO store_match_rules (rule_type, confidence, match_store_id, details, is_active, descriptor_id) \n(SELECT ''match'' AS rule_type, ''100'' AS confidence, ''_STORE_ID_'' AS match_store_id, \nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\nFROM transaction_descriptors D \nWHERE D.id = ''_DESCRIPTOR_ID_'')\n\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(87, 'get_store_chain_names', 'SELECT DISTINCT C.name AS chain_name \r\nFROM store_suggestions S \r\nLEFT JOIN chains C ON (S.chain_id=C.id AND S.chain_id <> ''0'') \r\nWHERE C.name IS NOT NULL AND S.id IN (SELECT _suggested_store_id FROM transaction_descriptors_suggested_stores WHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'')'),
(88, 'remove_matching_rules_due_to_location', 'DELETE FROM store_match_rules WHERE rule_type=''match'' AND descriptor_id=''_DESCRIPTOR_ID_'' AND match_store_id <> '''''),
(89, 'add_matching_rule_due_to_chain', 'INSERT INTO chain_match_rules (rule_type, confidence, match_chain_id, details, is_active, descriptor_id) \n(SELECT ''match'' AS rule_type, ''100'' AS confidence, C.id AS match_chain_id, \nCONCAT("''_PAYEE_NAME_'' LIKE ''%",D.description,"%'' OR ''_EXTENDED_PAYEE_NAME_'' LIKE ''%",D.description,"%''") AS details, \n''Y'' AS is_active, ''_DESCRIPTOR_ID_'' AS descriptor_id\nFROM transaction_descriptors D LEFT JOIN clout_v1_3.chains C ON (C.name=''_CHAIN_NAME_'')\nWHERE D.id = ''_DESCRIPTOR_ID_'')\n\nON DUPLICATE KEY UPDATE confidence=VALUES(confidence), is_active=VALUES(is_active)'),
(90, 'remove_matching_rules_due_to_chain', 'DELETE FROM `chain_match_rules` WHERE descriptor_id=''_DESCRIPTOR_ID_'' AND rule_type=''match'''),
(93, 'remove_match_rule', 'DELETE FROM _CATEGORY__match_rules WHERE id=''_RULE_ID_'''),
(94, 'get_content_list', 'SELECT * FROM list_actions WHERE list_type=''_LIST_TYPE_'' AND content_type=''_CONTENT_TYPE_'''),
(95, 'get_user_details_list', 'SELECT _FIELDS_ FROM view__user_details WHERE 1=1 _ID_CONDITION_ _PHRASE_CONDITION_ _TYPE_CONDITION_ \n_LIMIT_TEXT_'),
(96, 'get_permission_group_list', 'SELECT A.*, CONCAT(IF(A.permission_string <> '''', CONCAT(''PERMISSIONS: '', A.permission_string), ''''),'' '', IF(A.rule_string <> '''', CONCAT(''RULES: '', A.rule_string), '''')) AS permission_summary \nFROM \n(SELECT G.id AS group_id, G.is_removable, \nG.name AS group_name, \n\n(SELECT GROUP_CONCAT(DISTINCT CONCAT(REPLACE(P.category, ''_'', '' ''), '' ('',\n	(SELECT COUNT(_permission_id) FROM clout_v1_3iam.permission_group_mapping_permissions PM1 \n		LEFT JOIN clout_v1_3iam.permissions P1 ON (PM1._permission_id=P1.id) WHERE PM1._group_id=PM._group_id AND P1.category=P.category),\n	'' permissions)'') SEPARATOR '', '')\nFROM clout_v1_3iam.permission_group_mapping_permissions PM LEFT JOIN clout_v1_3iam.permissions P ON (PM._permission_id=P.id)\nWHERE PM._group_id=G.id) AS permission_string, \n\n(SELECT GROUP_CONCAT(DISTINCT CONCAT(REPLACE(R.category, ''_'', '' ''), '' ('',\n	(SELECT COUNT(_rule_id) FROM clout_v1_3iam.permission_group_mapping_rules RM1 \n		LEFT JOIN clout_v1_3iam.rules R1 ON (RM1._rule_id=R1.id) WHERE RM1._group_id=RM._group_id AND R1.category=R.category),\n	'' rules)'') SEPARATOR '', '')\nFROM clout_v1_3iam.permission_group_mapping_rules RM LEFT JOIN clout_v1_3iam.rules R ON (RM._rule_id=R.id)\nWHERE RM._group_id=G.id) AS rule_string, \n\n(SELECT COUNT(DISTINCT user_id) FROM clout_v1_3iam.user_access WHERE permission_group_id=G.id) AS user_count, \n\nG.`status`\nFROM clout_v1_3iam.permission_groups G\nWHERE 1=1 _PHRASE_CONDITION_ _CATEGORY_CONDITION_ \n_LIMIT_TEXT_) A\n'),
(97, 'get_permission_list', 'SELECT P.id AS permission_id, P.code, P.display AS name, P.details AS description, P.category, P.url, P.status FROM clout_v1_3iam.permissions P \nWHERE 1=1 _PHRASE_CONDITION_ \n_LIMIT_TEXT_ '),
(98, 'get_rule_category_list', 'SELECT * FROM (\nSELECT DISTINCT category, cap_first_letter_in_words(REPLACE(category, ''_'', '' '')) AS category_display FROM clout_v1_3iam.rules WHERE user_type <> ''system'') A WHERE 1=1 _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(99, 'get_rule_name_list', 'SELECT id, code, display AS name, category, cap_first_letter_in_words(REPLACE(category, ''_'', '' '')) AS category_display, status FROM clout_v1_3iam.rules WHERE user_type <> ''system'' _CATEGORY_CONDITION_ _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(100, 'get_group_by_id', 'SELECT id, name, group_type, group_category, is_removable FROM clout_v1_3iam.`permission_groups` WHERE id=''_GROUP_ID_'''),
(101, 'get_group_rules', 'SELECT R.id, R.code, R.display AS name, R.category, cap_first_letter_in_words(REPLACE(R.category, ''_'', '' '')) AS category_display, R.status FROM clout_v1_3iam.permission_group_mapping_rules M LEFT JOIN clout_v1_3iam.rules R ON (M._rule_id=R.id) WHERE M._group_id=''_GROUP_ID_'''),
(102, 'get_group_permissions', 'SELECT P.id AS permission_id, P.code, P.display AS name, P.details AS description, P.category, P.url, P.status FROM \r\nclout_v1_3iam.permission_group_mapping_permissions M \r\nLEFT JOIN clout_v1_3iam.permissions P ON (M._permission_id=P.id)\r\nWHERE M._group_id=''_GROUP_ID_'''),
(103, 'add_permission_group', 'INSERT IGNORE INTO clout_v1_3iam.permission_groups (name, notes, group_type, group_category, _default_permission, is_removable, status, date_entered, entered_by, last_updated, last_updated_by) VALUES \n\n(''_NAME_'', ''_NAME_'', ''_GROUP_TYPE_'', ''_GROUP_CATEGORY_'', ''1'', ''_IS_REMOVABLE_'', ''_STATUS_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'')'),
(104, 'update_permission_group', 'UPDATE clout_v1_3iam.permission_groups SET name=''_NAME_'', group_type=''_GROUP_TYPE_'', last_updated_by=''_USER_ID_'', last_updated=NOW() WHERE id=''_GROUP_ID_'''),
(105, 'delete_group_permissions', 'DELETE FROM clout_v1_3iam.`permission_group_mapping_permissions` WHERE _group_id=''_GROUP_ID_'''),
(106, 'add_group_permissions', 'INSERT IGNORE INTO clout_v1_3iam.`permission_group_mapping_permissions` (_group_id, _permission_id, entered_by, date_entered) \r\n\r\n(SELECT ''_GROUP_ID_'' AS _group_id, P.id AS _permission_id, ''_USER_ID_'' AS entered_by, NOW() AS date_entered FROM clout_v1_3iam.permissions P WHERE P.id IN (''_PERMISSION_IDS_''))'),
(107, 'delete_group_rules', 'DELETE FROM clout_v1_3iam.`permission_group_mapping_rules` WHERE _group_id=''_GROUP_ID_'''),
(108, 'add_group_rules', 'INSERT IGNORE INTO clout_v1_3iam.`permission_group_mapping_rules` (_group_id, _rule_id, entered_by, date_entered) \r\n\r\n(SELECT ''_GROUP_ID_'' AS _group_id, R.id AS _rule_id, ''_USER_ID_'' AS entered_by, NOW() AS date_entered FROM clout_v1_3iam.rules R WHERE R.id IN (''_RULE_IDS_''))'),
(109, 'update_permission_group_status', 'UPDATE clout_v1_3iam.`permission_groups` SET status=''_STATUS_'', last_updated_by=''_USER_ID_'', last_updated=NOW() WHERE id=''_GROUP_ID_'''),
(110, 'get_cron_job_list', 'SELECT S.id, S.job_type, S.activity_code, cap_first_letter_in_words(REPLACE(S.activity_code, ''_'', '' '')) AS cron_display, S.cron_value AS cron_details, UNIX_TIMESTAMP(L.event_time) AS start_time, UNIX_TIMESTAMP(S.run_time) AS end_time, S.last_result AS result, L.record_count AS total_records, S.repeat_code, S.is_done\nFROM cron_schedule S \nLEFT JOIN cron_log L ON (S.id=L._cron_job_id)\nWHERE 1=1 _PHRASE_CONDITION_ \nGROUP BY S.id \nORDER BY L.event_time DESC \n_LIMIT_TEXT_'),
(111, 'update_cron_job_status', 'UPDATE cron_schedule SET is_done=''_IS_DONE_'' WHERE id=''_JOB_ID_'''),
(112, 'get_score_settings_list', 'SELECT id,  cap_first_letter_in_words(REPLACE(code, ''_'', '' '')) AS name, description, code, UPPER(REPLACE(criteria, ''_'', '' '')) AS criteria, low_range AS min_score, high_range AS max_score\nFROM clout_v1_3cron.score_criteria C \nWHERE 1=1 _TYPE_CONDITION_ _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(113, 'update_score_value', 'UPDATE clout_v1_3cron.`score_criteria` SET _SCORE_FIELD_=''_SCORE_VALUE_'' WHERE id=''_SETTING_ID_'''),
(114, 'get_rule_settings_list', 'SELECT R.id AS rule_id, R.user_type, R.code, R.display AS name, R.details AS description, R.category,  R.status, \n\n(SELECT COUNT(DISTINCT UA.user_id) FROM clout_v1_3iam.permission_group_mapping_rules MR \nLEFT JOIN clout_v1_3iam.user_access UA ON (MR._group_id=UA.permission_group_id)\nWHERE MR._rule_id=R.id) AS user_count, \n\n(SELECT cap_first_letter_in_words(REPLACE(GROUP_CONCAT(DISTINCT group_type SEPARATOR '', ''), ''_'', '' '')) FROM clout_v1_3iam.permission_group_mapping_rules MR \nLEFT JOIN clout_v1_3iam.permission_groups G ON (MR._group_id=G.id)\nWHERE MR._rule_id=R.id) AS user_groups\n\nFROM clout_v1_3iam.rules R \nWHERE 1=1 _PHRASE_CONDITION_ _LIMIT_TEXT_ '),
(115, 'update_rule_setting_status', 'UPDATE clout_v1_3iam.rules SET status=''_STATUS_'' WHERE id=''_RULE_ID_'''),
(116, 'get_rule_setting', 'SELECT * FROM clout_v1_3iam.rules WHERE id=''_RULE_ID_'''),
(117, 'update_setting_value', 'UPDATE clout_v1_3iam.rules SET details=REPLACE(details, ''_PREVIOUS_VALUE_STRING_'', ''_NEW_VALUE_STRING_'') WHERE id=''_SETTING_ID_'''),
(118, 'add_sub_category', 'INSERT IGNORE INTO `categories_level_2` (name, _category_id, is_active) \nVALUES (''_NAME_'', ''_CATEGORY_ID_'', ''Y'')'),
(119, 'get_chain_match_attempts_by_descriptor', 'SELECT A.* FROM \n((SELECT _chain_id AS id, C.name, \n(SELECT CAT.name FROM categories_level_1 CAT LEFT JOIN chain_categories CC ON (CC._category_id=CAT.id) WHERE CC._chain_id=DC._chain_id LIMIT 1) AS category, \nC.website, ''Y'' AS is_selected\nFROM `transaction_descriptor_chains` DC \nLEFT JOIN chains C ON (DC._chain_id=C.id) \nWHERE DC._transaction_descriptor_id = ''_DESCRIPTOR_ID_'')\n\nUNION \n\n(SELECT MC._matched_chain_id AS id, C.name, \n(SELECT CAT.name FROM categories_level_1 CAT LEFT JOIN chain_categories CC ON (CC._category_id=CAT.id) WHERE CC._chain_id=MC._matched_chain_id LIMIT 1) AS category, \nC.website, ''N'' AS is_selected \nFROM match_history_chains MC\nLEFT JOIN chains C ON (MC._matched_chain_id=C.id) \nWHERE MC._raw_transaction_id IN (SELECT _transactions_raw_id FROM `transaction_descriptor_transactions` WHERE _descriptor_id=''_DESCRIPTOR_ID_''))\n) A \n_LIMIT_TEXT_'),
(120, 'get_store_match_attempts_by_descriptor', 'SELECT A.* FROM (\n(SELECT DS.store_id AS id, \n(SELECT cap_first_letter_in_words(CONCAT(address_line_1, '' '', address_line_2)) FROM stores WHERE id=DS.store_id LIMIT 1) AS address, \n(SELECT zipcode FROM stores WHERE id=DS.store_id LIMIT 1) AS zipcode, DS.is_selected \nFROM transaction_descriptors_suggested_stores DS \nWHERE DS.store_id != ''0'' AND DS._transaction_descriptor_id=''_DESCRIPTOR_ID_'' AND DS._chain_id = ''_CHAIN_ID_'')\n\nUNION\n\n(SELECT MC._matched_store_id AS id, \n(SELECT cap_first_letter_in_words(CONCAT(address_line_1, '' '', address_line_2)) FROM stores WHERE id=MC._matched_store_id LIMIT 1) AS address, \n(SELECT zipcode FROM stores WHERE id=MC._matched_store_id LIMIT 1) AS zipcode,\n ''N'' AS is_selected \nFROM match_history_stores MC\nWHERE MC._raw_transaction_id IN (SELECT _transactions_raw_id FROM `transaction_descriptor_transactions` WHERE _descriptor_id=''_DESCRIPTOR_ID_'') \nAND MC._matched_store_id IN (SELECT _store_id FROM store_chains WHERE _chain_id=''_CHAIN_ID_''))\n) A\n\n _LIMIT_TEXT_'),
(121, 'add_basic_store', 'INSERT IGNORE INTO stores (name, status, address_line_1, website, date_entered, _entered_by, last_updated, _last_updated_by) VALUES \n\n(''_NAME_'', ''_STATUS_'', ''_ADDRESS_LINE_1_'', ''_WEBSITE_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'')'),
(122, 'add_chain_to_descriptor', 'INSERT IGNORE INTO clout_v1_3cron.transaction_descriptor_chains (_transaction_descriptor_id, _chain_id, status, date_entered, _entered_by) VALUES (''_DESCRIPTOR_ID_'', ''_CHAIN_ID_'', ''_STATUS_'', NOW(), ''_USER_ID_'')'),
(123, 'add_chain_categories', 'INSERT IGNORE INTO chain_categories (_chain_id, _category_id) \n\n(SELECT ''_CHAIN_ID_'' AS _chain_id, id AS _category_id FROM categories_level_1 WHERE id IN (''_CATEGORY_IDS_''))'),
(124, 'remove_chain_categories', 'DELETE FROM `chain_categories` WHERE _chain_id=''_CHAIN_ID_'''),
(125, 'mark_store_as_selected', 'UPDATE transaction_descriptors_suggested_stores \nSET is_selected=(SELECT IF(store_id=''_STORE_ID_'', ''Y'', ''N'')) \nWHERE _chain_id=''_CHAIN_ID_'''),
(126, 'update_chain_parts', 'UPDATE chains SET _UPDATE_STRING_ WHERE id=''_CHAIN_ID_'''),
(127, 'get_edit_store_details_by_id', 'SELECT id AS store_id, address_line_1 AS address, zipcode,  name, logo_url, small_cover_image, large_cover_image FROM stores WHERE id=''_STORE_ID_'''),
(128, 'update_store_parts', 'UPDATE stores SET _UPDATE_STRING_ WHERE id=''_STORE_ID_'''),
(129, 'get_store_chain_details', 'SELECT (SELECT name FROM stores WHERE id=''_STORE_ID_'') AS store_name, (SELECT name FROM chains WHERE id=''_CHAIN_ID_'') AS chain_name, (SELECT COUNT(DISTINCT _store_id) FROM store_chains WHERE _chain_id=''_CHAIN_ID_'') AS location_count'),
(130, 'remove_chains_from_descriptor', 'DELETE FROM transaction_descriptor_chains WHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'''),
(131, 'mark_chain_as_selected', 'UPDATE `transaction_descriptor_chains` \nSET is_selected=(SELECT IF(_chain_id=''_CHAIN_ID_'', ''Y'', ''N'')) \nWHERE _transaction_descriptor_id=''_DESCRIPTOR_ID_'''),
(132, 'add_new_user', 'INSERT IGNORE INTO users (first_name, last_name, email_address, email_verified, telephone, gender, zipcode, birthday, date_entered) VALUES \n\n(''_FIRST_NAME_'', ''_LAST_NAME_'', ''_EMAIL_ADDRESS_'', ''_EMAIL_VERIFIED_'', ''_TELEPHONE_'', ''_GENDER_'', ''_ZIPCODE_'', ''_BIRTHDAY_'', NOW())'),
(133, 'add_user_contact', 'INSERT IGNORE INTO contact_phones (_user_id, _provider_id, telephone)  \nVALUES (''_USER_ID_'', ''_PROVIDER_ID_'', ''_TELEPHONE_'')'),
(134, 'update_user_field', 'UPDATE users SET _FIELD_NAME_=''_FIELD_VALUE_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' WHERE id=''_USER_ID_'''),
(135, 'add_message_settings', 'INSERT INTO user_preferred_communication (_user_id, 	message_format, message_type)\n(SELECT ''_USER_ID_'' AS _user_id, M.word AS message_format, ''_MESSAGE_TYPES_'' AS message_type FROM\n \n(SELECT IF(''email'' IN (_MESSAGE_FORMATS_), ''email'','''') AS word \nUNION SELECT IF(''sms'' IN (_MESSAGE_FORMATS_), ''sms'','''') AS word \nUNION SELECT IF(''system'' IN (_MESSAGE_FORMATS_), ''system'','''') AS word) M \n\nWHERE M.word <> '''')\n\nON DUPLICATE KEY UPDATE message_type=VALUES(message_type);'),
(136, 'get_bank_details', 'SELECT _FIELD_LIST_ FROM clout_v1_3cron.banks WHERE id=''_BANK_ID_'''),
(137, 'get_user_banks', 'SELECT DISTINCT B.institution_name AS bank_name, B.id AS bank_id, SUBSTRING_INDEX(B.home_url, ''/'', 3) AS website, B.logo_url, B.phone_number AS telephone \nFROM clout_v1_3cron.bank_accounts UB \nLEFT JOIN clout_v1_3cron.banks B ON (UB._bank_id=B.id) \nWHERE UB._user_id=''_USER_ID_'''),
(139, 'get_access_token', 'SELECT access_token, third_party_user_name AS user_name, third_party_user_password AS user_password FROM plaid_access_token WHERE user_email=''_USER_EMAIL_'' AND bank_code=''_BANK_CODE_'' AND is_active=''Y'' LIMIT 1'),
(140, 'add_to_cron_schedule', 'INSERT INTO cron_schedule (job_type, activity_code, cron_value, is_done, last_result, repeat_code) \n\nVALUES (''_JOB_TYPE_'', ''_ACTIVITY_CODE_'', ''_CRON_VALUE_'', ''N'', ''none'', ''_REPEAT_CODE_'')'),
(142, 'update_cron_schedule_field', 'UPDATE cron_schedule SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_ID_'''),
(143, 'add_cron_log', 'INSERT INTO cron_log (_cron_job_id, user_id, job_type, activity_code, result, uri, log_details, record_count, ip_address, event_time) VALUES \n(''_JOB_ID_'', ''_USER_ID_'', ''_JOB_TYPE_'', ''_ACTIVITY_CODE_'', ''_RESULT_'', ''_URI_'', ''_LOG_DETAILS_'', ''_RECORD_COUNT_'', ''_IP_ADDRESS_'', NOW())'),
(144, 'get_user_by_email', 'SELECT id AS user_id, first_name, last_name FROM users \nWHERE email_address=''_EMAIL_ADDRESS_'''),
(145, 'remove_clout_transactions_by_api_ids', 'DELETE FROM transactions WHERE _raw_id IN (SELECT id FROM transactions_raw WHERE transaction_id IN (_API_IDS_))'),
(146, 'remove_raw_transactions_by_api_ids', 'DELETE FROM transactions_raw WHERE transaction_id IN (_API_IDS_)'),
(147, 'disable_plaid_access_token', 'UPDATE plaid_access_token SET is_active=''N'' WHERE access_token=''_ACCESS_TOKEN_'''),
(149, 'get_last_transaction_date', 'SELECT MAX(posted_date) AS last_transaction_date, MIN(posted_date) AS earliest_transaction_date FROM transactions_raw WHERE _user_id=''_USER_ID_'' AND _bank_id=''_BANK_ID_'''),
(150, 'get_raw_account', 'SELECT * FROM _RAW_TABLE_NAME_ WHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(151, 'update_raw_bank_account', 'UPDATE bank_accounts_other_raw \r\n\r\nSET status=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', balance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', aggr_success_date=''_AGGR_SUCCESS_DATE_'', aggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', institution_login_id=''_INSTITUTION_LOGIN_ID_'', banking_account_type=''_BANKING_ACCOUNT_TYPE_'', posted_date=''_POSTED_DATE_'', available_balance_amount=''_AVAILABLE_BALANCE_AMOUNT_'', interest_type=''_INTEREST_TYPE_'', origination_date=''_ORIGINATION_DATE_'', open_date=''_OPEN_DATE_'', period_interest_rate=''_PERIOD_INTEREST_RATE_'', period_deposit_amount=''_PERIOD_DEPOSIT_AMOUNT_'', period_interest_amount=''_PERIOD_INTEREST_AMOUNT_'', interest_amount_ytd=''_INTEREST_AMOUNT_YTD_'', interest_prior_amount_ytd=''_INTEREST_PRIOR_AMOUNT_YTD_'', maturity_date=''_MATURITY_DATE_'', maturity_amount=''_MATURITY_AMOUNT_'', last_updated=NOW()\r\n\r\nWHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(152, 'save_raw_bank_account', 'INSERT IGNORE INTO bank_accounts_other_raw (\naccount_id, _user_id, status, account_number, account_number_real, account_nickname, display_position, _institution_id, description, registered_user_name, balance_amount, balance_date, balance_previous_amount, last_transaction_date, aggr_success_date, aggr_attempt_date, aggr_status_code, currency_code, bank_id, institution_login_id, banking_account_type, posted_date, available_balance_amount, interest_type, origination_date, open_date, period_interest_rate, period_deposit_amount, period_interest_amount, interest_amount_ytd, interest_prior_amount_ytd, maturity_date, maturity_amount, last_updated\n) VALUES \n(\n''_ACCOUNT_ID_'', ''_USER_ID_'', ''_STATUS_'', ''_ACCOUNT_NUMBER_'', ''_ACCOUNT_NUMBER_REAL_'', ''_ACCOUNT_NICKNAME_'', ''_DISPLAY_POSITION_'', ''_INSTITUTION_ID_'', ''_DESCRIPTION_'', ''_REGISTERED_USER_NAME_'', ''_BALANCE_AMOUNT_'', ''_BALANCE_DATE_'', ''_BALANCE_PREVIOUS_AMOUNT_'', ''_LAST_TRANSACTION_DATE_'', ''_AGGR_SUCCESS_DATE_'', ''_AGGR_ATTEMPT_DATE_'', ''_AGGR_STATUS_CODE_'', ''_CURRENCY_CODE_'', ''_BANK_ID_'', ''_INSTITUTION_LOGIN_ID_'', ''_BANKING_ACCOUNT_TYPE_'', ''_POSTED_DATE_'', ''_AVAILABLE_BALANCE_AMOUNT_'', ''_INTEREST_TYPE_'', ''_ORIGINATION_DATE_'', ''_OPEN_DATE_'', ''_PERIOD_INTEREST_RATE_'', ''_PERIOD_DEPOSIT_AMOUNT_'', ''_PERIOD_INTEREST_AMOUNT_'', ''_INTEREST_AMOUNT_YTD_'', ''_INTEREST_PRIOR_AMOUNT_YTD_'', ''_MATURITY_DATE_'', ''_MATURITY_AMOUNT_'', NOW()\n)'),
(153, 'update_raw_credit_account', 'UPDATE bank_accounts_credit_raw \r\n\r\nSET status=''_STATUS_'', account_nickname=''_ACCOUNT_NICKNAME_'', display_position=''_DISPLAY_POSITION_'', description=''_DESCRIPTION_'', registered_user_name=''_REGISTERED_USER_NAME_'', balance_amount=''_BALANCE_AMOUNT_'', balance_date=''_BALANCE_DATE_'', balance_previous_amount=''_BALANCE_PREVIOUS_AMOUNT_'', last_transaction_date=''_LAST_TRANSACTION_DATE_'', aggr_success_date=''_AGGR_SUCCESS_DATE_'', aggr_attempt_date=''_AGGR_ATTEMPT_DATE_'', aggr_status_code=''_AGGR_STATUS_CODE_'', currency_code=''_CURRENCY_CODE_'', bank_id=''_BANK_ID_'', institution_login_id=''_INSTITUTION_LOGIN_ID_'', credit_account_type=''_CREDIT_ACCOUNT_TYPE_'', detailed_description=''_DETAILED_DESCRIPTION_'', interest_rate=''_INTEREST_RATE_'', credit_available_amount=''_CREDIT_AVAILABLE_AMOUNT_'', credit_max_amount=''_CREDIT_MAX_AMOUNT_'', cash_advance_available_amount=''_CASH_ADVANCE_AVAILABLE_AMOUNT_'', cash_advance_max_amount=''_CASH_ADVANCE_MAX_AMOUNT_'', cash_advance_balance=''_CASH_ADVANCE_BALANCE_'', cash_advance_interest_rate=''_CASH_ADVANCE_INTEREST_RATE_'', current_balance=''_CURRENT_BALANCE_'', payment_min_amount=''_PAYMENT_MIN_AMOUNT_'', payment_due_date=''_PAYMENT_DUE_DATE_'', previous_balance=''_PREVIOUS_BALANCE_'', statement_end_date=''_STATEMENT_END_DATE_'', statement_purchase_amount=''_STATEMENT_PURCHASE_AMOUNT_'', statement_finance_amount=''_STATEMENT_FINANCE_AMOUNT_'', past_due_amount=''_PAST_DUE_AMOUNT_'', last_payment_amount=''_LAST_PAYMENT_AMOUNT_'', last_payment_date=''_LAST_PAYMENT_DATE_'', statement_close_balance=''_STATEMENT_CLOSE_BALANCE_'', statement_late_fee_amount=''_STATEMENT_LATE_FEE_AMOUNT_'', last_updated=NOW()\r\n\r\nWHERE account_id=''_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'' AND _institution_id=''_INSTITUTION_ID_'''),
(154, 'save_raw_credit_account', 'INSERT IGNORE INTO bank_accounts_credit_raw (\naccount_id, _user_id, status, account_number, account_number_real, account_nickname, display_position, _institution_id, description, registered_user_name, balance_amount, balance_date, balance_previous_amount, last_transaction_date, aggr_success_date, aggr_attempt_date, aggr_status_code, currency_code, bank_id, institution_login_id, credit_account_type, detailed_description, interest_rate, credit_available_amount, credit_max_amount, cash_advance_available_amount, cash_advance_max_amount, cash_advance_balance, cash_advance_interest_rate, current_balance, payment_min_amount, payment_due_date, previous_balance, statement_end_date, statement_purchase_amount, statement_finance_amount, past_due_amount, last_payment_amount, last_payment_date, statement_close_balance, statement_late_fee_amount, last_updated\n) VALUES (\n''_ACCOUNT_ID_'', ''_USER_ID_'', ''_STATUS_'', ''_ACCOUNT_NUMBER_'', ''_ACCOUNT_NUMBER_REAL_'', ''_ACCOUNT_NICKNAME_'', ''_DISPLAY_POSITION_'', ''_INSTITUTION_ID_'', ''_DESCRIPTION_'', ''_REGISTERED_USER_NAME_'', ''_BALANCE_AMOUNT_'', ''_BALANCE_DATE_'', ''_BALANCE_PREVIOUS_AMOUNT_'', ''_LAST_TRANSACTION_DATE_'', ''_AGGR_SUCCESS_DATE_'', ''_AGGR_ATTEMPT_DATE_'', ''_AGGR_STATUS_CODE_'', ''_CURRENCY_CODE_'', ''_BANK_ID_'', ''_INSTITUTION_LOGIN_ID_'', ''_CREDIT_ACCOUNT_TYPE_'', ''_DETAILED_DESCRIPTION_'', ''_INTEREST_RATE_'', ''_CREDIT_AVAILABLE_AMOUNT_'', ''_CREDIT_MAX_AMOUNT_'', ''_CASH_ADVANCE_AVAILABLE_AMOUNT_'', ''_CASH_ADVANCE_MAX_AMOUNT_'', ''_CASH_ADVANCE_BALANCE_'', ''_CASH_ADVANCE_INTEREST_RATE_'', ''_CURRENT_BALANCE_'', ''_PAYMENT_MIN_AMOUNT_'', ''_PAYMENT_DUE_DATE_'', ''_PREVIOUS_BALANCE_'', ''_STATEMENT_END_DATE_'', ''_STATEMENT_PURCHASE_AMOUNT_'', ''_STATEMENT_FINANCE_AMOUNT_'', ''_PAST_DUE_AMOUNT_'', ''_LAST_PAYMENT_AMOUNT_'', ''_LAST_PAYMENT_DATE_'', ''_STATEMENT_CLOSE_BALANCE_'', ''_STATEMENT_LATE_FEE_AMOUNT_'', NOW()\n)'),
(155, 'get_raw_transaction_by_field', 'SELECT * FROM transactions_raw WHERE _FIELD_NAME_=''_FIELD_VALUE_'' _LIMIT_TEXT_');
INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(156, 'update_raw_transaction', 'UPDATE transactions_raw SET transaction_type=''_TRANSACTION_TYPE_'', currency_type=''_CURRENCY_TYPE_'', institution_transaction_id=''_INSTITUTION_TRANSACTION_ID_'', correct_institution_transaction_id=''_CORRECT_INSTITUTION_TRANSACTION_ID_'', correct_action=''_CORRECT_ACTION_'', server_transaction_id=''_SERVER_TRANSACTION_ID_'', check_number=''_CHECK_NUMBER_'', reference_number=''_REF_NUMBER_'', confirmation_number=''_CONFIRMATION_NUMBER_'', payee_id=''_PAYEE_ID_'', payee_name=''_PAYEE_NAME_'', extended_payee_name=''_EXTENDED_PAYEE_NAME_'', memo=''_MEMO_'', type=''_TYPE_'', value_type=''_VALUE_TYPE_'', currency_rate=''_CURRENCY_RATE_'', original_currency=''_ORIGINAL_CURRENCY_'', posted_date=''_POSTED_DATE_'', user_date=''_USER_DATE_'', available_date=''_AVAILABLE_DATE_'', amount=''_AMOUNT_'', running_balance_amount=''_RUNNING_BALANCE_AMOUNT_'', pending=''_PENDING_'', normalized_payee_name=''_NORMALIZED_PAYEE_NAME_'', merchant=''_MERCHANT_'', sic=''_SIC_'', source=''_SOURCE_'', category_name=''_CATEGORY_NAME_'', context_type=''_CONTEXT_TYPE_'', schedule_c=''_SCHEDULE_C_'', banking_transaction_type=''_BANKING_TRANSACTION_TYPE_'', subaccount_fund_type=''_SUBACCOUNT_FUND_TYPE_'', banking_401k_source_type=''_BANKING_401K_SOURCE_TYPE_'', principal_amount=''_PRINCIPAL_AMOUNT_'', interest_amount=''_INTEREST_AMOUNT_'', escrow_total_amount=''_ESCROW_TOTAL_AMOUNT_'', escrow_tax_amount=''_ESCROW_TAX_AMOUNT_'', escrow_insurance_amount=''_ESCROW_INSURANCE_AMOUNT_'', escrow_pmi_amount=''_ESCROW_PMI_AMOUNT_'', escrow_fees_amount=''_ESCROW_FEES_AMOUNT_'', escrow_other_amount=''_ESCROW_OTHER_AMOUNT_'', last_update_date=NOW(), latitude=''_LATITUDE_'', longitude=''_LONGITUDE_'', zipcode=''_ZIPCODE_'', state=''_STATE_'', city=''_CITY_'', address=''_ADDRESS_'', sub_category_id=''_SUB_CATEGORY_ID_'', contact_telephone=''_CONTACT_TELEPHONE_'', website=''_WEBSITE_'', confidence_level=''_CONFIDENCE_LEVEL_'', place_type=''_PLACE_TYPE_'', _user_id=''_USER_ID_'', _bank_id=''_BANK_ID_'', api_account=''_API_ACCOUNT_'' WHERE transaction_id=''_TRANSACTION_ID_'''),
(157, 'save_raw_transaction', 'INSERT INTO transactions_raw (transaction_id, transaction_type, currency_type,  institution_transaction_id, correct_institution_transaction_id, correct_action, server_transaction_id, check_number, reference_number, confirmation_number, payee_id, payee_name, extended_payee_name, memo, type, value_type, currency_rate, original_currency, posted_date, user_date, available_date, amount, running_balance_amount, pending, normalized_payee_name, merchant, sic, source, category_name, context_type, schedule_c, banking_transaction_type, subaccount_fund_type, banking_401k_source_type, principal_amount, interest_amount, escrow_total_amount, escrow_tax_amount, escrow_insurance_amount, escrow_pmi_amount, escrow_fees_amount, escrow_other_amount, last_update_date, latitude, longitude, zipcode, state, city, address, sub_category_id, contact_telephone, website, confidence_level, place_type, _user_id, _bank_id, api_account) \nVALUES \n(''_TRANSACTION_ID_'', ''_TRANSACTION_TYPE_'', ''_CURRENCY_TYPE_'', ''_INSTITUTION_TRANSACTION_ID_'', ''_CORRECT_INSTITUTION_TRANSACTION_ID_'', ''_CORRECT_ACTION_'', ''_SERVER_TRANSACTION_ID_'', ''_CHECK_NUMBER_'', ''_REF_NUMBER_'', ''_CONFIRMATION_NUMBER_'', ''_PAYEE_ID_'', ''_PAYEE_NAME_'', ''_EXTENDED_PAYEE_NAME_'', ''_MEMO_'', ''_TYPE_'', ''_VALUE_TYPE_'', ''_CURRENCY_RATE_'', ''_ORIGINAL_CURRENCY_'', ''_POSTED_DATE_'', ''_USER_DATE_'', ''_AVAILABLE_DATE_'', ''_AMOUNT_'', ''_RUNNING_BALANCE_AMOUNT_'', ''_PENDING_'', ''_NORMALIZED_PAYEE_NAME_'', ''_MERCHANT_'', ''_SIC_'', ''_SOURCE_'', ''_CATEGORY_NAME_'', ''_CONTEXT_TYPE_'', ''_SCHEDULE_C_'', ''_BANKING_TRANSACTION_TYPE_'', ''_SUBACCOUNT_FUND_TYPE_'', ''_BANKING_401K_SOURCE_TYPE_'', ''_PRINCIPAL_AMOUNT_'', ''_INTEREST_AMOUNT_'', ''_ESCROW_TOTAL_AMOUNT_'', ''_ESCROW_TAX_AMOUNT_'', ''_ESCROW_INSURANCE_AMOUNT_'', ''_ESCROW_PMI_AMOUNT_'', ''_ESCROW_FEES_AMOUNT_'', ''_ESCROW_OTHER_AMOUNT_'', NOW(), ''_LATITUDE_'', ''_LONGITUDE_'', ''_ZIPCODE_'', ''_STATE_'', ''_CITY_'', ''_ADDRESS_'', ''_SUB_CATEGORY_ID_'', ''_CONTACT_TELEPHONE_'', ''_WEBSITE_'', ''_CONFIDENCE_LEVEL_'', ''_PLACE_TYPE_'', ''_USER_ID_'', ''_BANK_ID_'', ''_API_ACCOUNT_'')'),
(158, 'get_un_saved_raw_transaction_ids', 'SELECT id FROM transactions_raw WHERE is_saved=''N'' AND _user_id=''_USER_ID_'' AND _bank_id=''_BANK_ID_'' '),
(159, 'get_transaction_ids_with_stores', 'SELECT id FROM transactions WHERE _store_id <> '''' AND _store_id IS NOT NULL AND _raw_id IN (_RAW_ID_LIST_)'),
(161, 'get_unprocessed_accounts', 'SELECT A.* FROM _TABLE_NAME_ A WHERE A.is_saved=''N'' _MORE_CONDITIONS_ _LIMIT_TEXT_'),
(162, 'add_bank_account', 'INSERT IGNORE INTO clout_v1_3cron.bank_accounts (_user_id, account_type, account_id, account_number, _bank_id, issue_bank_name, card_holder_full_name, account_nickname, currency_code, is_verified, status) \n\n(SELECT ''_USER_ID_'' AS _user_id, ''_ACCOUNT_TYPE_'' AS account_type, ''_ACCOUNT_ID_'' AS account_id, ''_ACCOUNT_NUMBER_'' AS account_number, ''_BANK_ID_'' AS _bank_id, institution_name AS issue_bank_name, ''_CARD_HOLDER_FULL_NAME_'' AS card_holder_full_name, ''_ACCOUNT_NICKNAME_'' AS account_nickname, ''_CURRENCY_CODE_'' AS currency_code, ''_IS_VERIFIED_'' AS is_verified, ''active'' AS status \nFROM clout_v1_3cron.banks \nWHERE id=''_BANK_ID_'')'),
(163, 'update_account_as_saved', 'UPDATE _ACCOUNT_TABLE_NAME_ SET is_saved=''_IS_SAVED_'' WHERE id=''_ID_'''),
(164, 'update_user_value', 'UPDATE users SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_USER_ID_'''),
(165, 'mark_previous_tracking_as_not_active', 'UPDATE _TABLE_NAME_ SET is_latest=''N'' WHERE _bank_account_id=''_BANK_ACCOUNT_ID_'' AND _user_id=''_USER_ID_'''),
(166, 'add_user_account_tracking', 'INSERT INTO _TABLE_NAME_ ( _bank_account_id, _user_id, _BALANCE_FIELD_, read_date, is_latest) VALUES (''_BANK_ACCOUNT_ID_'', ''_USER_ID_'', ''_BALANCE_VALUE_'', NOW(), ''Y'')'),
(167, 'update_user_balance', 'UPDATE clout_v1_3.users \nSET _TYPE__balance=(SELECT SUM(B._TYPE__amount) FROM clout_v1_3cron.user__TYPE__tracking B WHERE B.is_latest=''Y'' AND _user_id=''_USER_ID_'') \n\nWHERE id=''_USER_ID_'''),
(168, 'get_bank_account', 'SELECT * FROM bank_accounts WHERE _user_id=''_USER_ID_'' AND account_id=''_ACCOUNT_ID_'' AND _bank_id=''_BANK_ID_'''),
(169, 'update_user_default_score', 'UPDATE users \nSET default_store_score=(SELECT IF((SELECT total_score \n	FROM clout_v1_3cron.cacheview__store_score_by_default \n	WHERE user_id=''_USER_ID_'' LIMIT 1) IS NOT NULL, total_score, 0) \nFROM clout_v1_3cron.cacheview__store_score_by_default WHERE user_id=''_USER_ID_'' LIMIT 1) \nWHERE id=''_USER_ID_'''),
(170, 'get_new_store_scores', 'SELECT S._store_id AS store_id, \n(SELECT cap_first_letter_in_words(name) FROM stores WHERE id=S._store_id LIMIT 1) AS store_name, \nget_store_score(''_USER_ID_'', S._store_id) AS store_score \nFROM \n(SELECT DISTINCT _store_id FROM transactions T \n	WHERE _user_id=''_USER_ID_'' AND _bank_id=''_BANK_ID_'' AND DATE(start_date) > DATE(''_START_DATE_'')\n	ORDER BY start_date DESC _LIMIT_TEXT_\n) S \n\nWHERE S._store_id IS NOT NULL'),
(171, 'get_user_group_types', 'SELECT DISTINCT G.group_type FROM clout_v1_3iam.user_access A LEFT JOIN clout_v1_3iam.permission_groups G ON (A.permission_group_id=G.id) WHERE A.user_id=''_USER_ID_'''),
(172, 'get_user_permissions', 'SELECT P.code AS permission_code, P.category FROM clout_v1_3iam.user_access A \nLEFT JOIN clout_v1_3iam.permission_group_mapping_permissions PM ON (A.permission_group_id=PM._group_id) \nLEFT JOIN clout_v1_3iam.permissions P ON (PM._permission_id=P.id) \n\nWHERE A.user_id=''_USER_ID_'''),
(173, 'get_user_rules', 'SELECT R.code AS rule_code FROM clout_v1_3iam.user_access A \r\nLEFT JOIN clout_v1_3iam.permission_group_mapping_rules RM ON (A.permission_group_id=RM._group_id) \r\nLEFT JOIN clout_v1_3iam.rules R ON (RM._rule_id=R.id) \r\n\r\nWHERE A.user_id=''_USER_ID_'''),
(174, 'get_rule_by_code', 'SELECT id AS rule_id, user_type, details FROM clout_v1_3iam.rules WHERE code=''_CODE_'' AND status=''active'''),
(175, 'add_user_permission_group', 'INSERT INTO clout_v1_3iam.user_access (user_id, permission_group_id, user_name, password, last_updated) \n(SELECT ''_USER_ID_'' AS user_id, G.id AS permission_group_id, ''_USER_NAME_'' AS user_name, ''_PASSWORD_'' AS password, NOW() AS last_updated FROM clout_v1_3iam.permission_groups G WHERE LOWER(G.name)=LOWER(''_GROUP_NAME_''))\n\nON DUPLICATE KEY UPDATE password=VALUES(password), last_updated=VALUES(last_updated)'),
(176, 'get_store_categories', 'SELECT *, name AS suggestion FROM categories_level_1 WHERE is_active=''Y'' ORDER BY preferred_rank, name'),
(177, 'get_search_suggestions', 'SELECT S.suggestion AS suggestion, \nIF(S.suggestion = ''_PHRASE_'', 1, \nIF(S.suggestion LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.suggestion LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3,\n4))) AS list_order\n\nFROM (\n(SELECT cap_first_letter_in_words(name) AS suggestion FROM cacheview__default_search_suggestions \nWHERE MATCH(`name`) AGAINST(CONCAT(''+"'', SUBSTRING_INDEX(''_PHRASE_'', '' '', 1), ''"'')) \n_LIMIT_TEXT_1_)\n\nUNION \n\n(SELECT user_phrase AS suggestion FROM cacheview__search_tracking_summary \nWHERE MATCH(user_phrase) AGAINST(CONCAT(''+"'', SUBSTRING_INDEX(''_PHRASE_'', '' '', 1), ''"'')) \n_LIMIT_TEXT_1_)\n) S\n\nWHERE LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1)) > 2 AND S.suggestion LIKE CONCAT(''%'', SUBSTRING_INDEX(''_PHRASE_'', '' '', 1), ''%'') \nORDER BY list_order ASC \n_LIMIT_TEXT_1_;'),
(178, 'get_location_zipcodes', 'SELECT DISTINCT zipcode AS suggestion FROM zipcodes WHERE zipcode LIKE ''_PHRASE_%'' _LIMIT_TEXT_'),
(179, 'get_transaction_categories', 'SELECT DISTINCT C._sub_category_id AS sub_category_id FROM transaction_sub_categories C LEFT JOIN transactions T ON (C._transaction_id=T.id) WHERE T._raw_id IN (_RAW_ID_LIST_) '),
(180, 'get_search_suggestions_details_level3', 'SELECT S.id AS store_id, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nS.distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \n(SELECT C1.name FROM categories_level_1 C1 WHERE  _INNER_CATEGORY_CONDITION_  LIMIT 1) AS search_category, \nIF(S.id IN (SELECT store_id FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_''), ''Y'',''N'') AS has_shopped_here, \nS.list_order\n\nFROM \n(SELECT S.*, \nget_distance(_LATITUDE_, _LONGITUDE_, S.latitude, S.longitude) AS distance,\n_CATEGORY_FIELD_\nIF(S.`name` = ''_PHRASE_'', 1, \nIF(S.`name` LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.`name` LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3, \nIF(''_PHRASE_'' LIKE ''% %'' AND LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 )) > 3 AND S.`name` LIKE CONCAT(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 ), ''%'') AND ''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 4, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 5, \nIF((''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_PHRASE_''),''%'')), 6, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 7, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%''), 8, \n9)))))))) AS list_order\n\nFROM stores S \n_PROMOTION_JOIN_ \nWHERE MATCH(S.name) AGAINST(CONCAT(''+'', ''_PHRASE_''))\n\n_CUSTOM_FILTER_1_ \n_DISTANCE_CONDITION_ _OUTER_CATEGORY_CONDITION_\n_LIMIT_TEXT_1_ \n) S \n\nORDER BY S.list_order ASC, _CUSTOM_ORDER_'),
(181, 'get_ids_of_stores_where_user_shopped', 'SELECT GROUP_CONCAT(store_id SEPARATOR "'',''") AS store_list FROM `cacheview__store_score_by_store` WHERE user_id=''_USER_ID_'' _LIMIT_TEXT_'),
(182, 'add_store_chain', 'INSERT INTO store_chains (_chain_id, _store_id, date_entered, _entered_by) \r\nVALUES (''_CHAIN_ID_'', ''_STORE_ID_'', NOW(), ''_USER_ID_'') \r\nON DUPLICATE KEY UPDATE _chain_id=VALUES(_chain_id)'),
(183, 'add_new_chain_or_update_banner', 'INSERT INTO chains (name, address_line_1, address_line_2, city, state, zipcode, country, website, small_banner, is_live, date_entered, _entered_by) \r\n\r\nVALUES (''_NAME_'', ''_ADDRESS_LINE_1_'', ''_ADDRESS_LINE_2_'', ''_CITY_'', ''_STATE_'', ''_ZIPCODE_'', ''_COUNTRY_'', ''_WEBSITE_'', ''_SMALL_BANNER_'', ''Y'', NOW(), ''_USER_ID_'')\r\n\r\nON DUPLICATE KEY UPDATE small_banner=VALUES(small_banner)'),
(184, 'get_store_hours', 'SELECT * FROM store_hours WHERE _store_id=''_STORE_ID_'' \nORDER BY FIELD(week_day, ''monday'', ''tuesday'', ''wednesday'', ''thursday'', ''friday'', ''saturday'', ''sunday'');'),
(185, 'get_store_features', 'SELECT id, feature FROM store_features WHERE _store_id=''_STORE_ID_'''),
(186, 'get_store_transaction_statistics', 'SELECT \n(SELECT COUNT(transaction_id) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'') AS lifeTimeSpendingTransactions, \n(SELECT SUM(amount) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'') AS lifeTimeSpendingAmount, \n(SELECT DATEDIFF(NOW(), start_date) FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'' ORDER BY start_date DESC LIMIT 1) AS daysSinceLastTransaction, \n(SELECT amount FROM view__user_spending_summary WHERE user_id=''_USER_ID_'' AND store_id=''_STORE_ID_'' ORDER BY start_date DESC LIMIT 1) AS lastTransactionAmount, \n(SELECT COUNT(id) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''approved'') AS availableRewards, \n(SELECT SUM(pay_out) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''approved'') AS availableRewardAmount, \n(SELECT COUNT(id) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''pending'') AS pendingRewards, \n(SELECT SUM(pay_out) FROM commissions_transactions WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'' AND status=''pending'') AS pendingRewardAmount\n'),
(187, 'add_favorite_store', 'INSERT IGNORE INTO store_favorites (_user_id, _store_id, date_entered) \r\nVALUES (''_USER_ID_'', ''_STORE_ID_'', NOW())'),
(188, 'get_search_suggestions_details_level1', 'SELECT S.id AS store_id, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nS.distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \n(SELECT C1.name FROM categories_level_1 C1 WHERE  _INNER_CATEGORY_CONDITION_  LIMIT 1) AS search_category, \nIF(S.id IN (SELECT store_id FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_''), ''Y'',''N'') AS has_shopped_here, \nS.list_order\n\nFROM \n(SELECT S.*, \nget_distance(_LATITUDE_, _LONGITUDE_, S.latitude, S.longitude) AS distance,\n_CATEGORY_FIELD_\nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 1, \nIF((''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_PHRASE_''),''%'')), 2, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 3, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%''), 4, \n5)))) AS list_order\n\nFROM stores S \n_PROMOTION_JOIN_ \n_CUSTOM_FILTER_2_ \n_DISTANCE_CONDITION_ _OUTER_CATEGORY_CONDITION_\n_LIMIT_TEXT_1_ \n) S \n\nORDER BY S.list_order ASC, FIELD(has_shopped_here, ''Y'',''N''), _CUSTOM_ORDER_'),
(189, 'get_search_suggestions_details_level2', 'SELECT DATA1.* FROM \n(\n\n(SELECT S.id AS store_id, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \nC.id AS chain_id, C.small_banner AS chain_banner,\nget_distance(_LATITUDE_, _LONGITUDE_, S.latitude, S.longitude) AS distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \n''Y'' AS has_shopped_here, \n\n_CATEGORY_FIELD_\n(SELECT C1.name FROM categories_level_1 C1 WHERE _INNER_CATEGORY_CONDITION_ LIMIT 1) AS search_category, \n\nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 1, \nIF((''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''''),''%'')), 2, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 3, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%''), 4, \n5)))) AS list_order\n\nFROM stores S \nLEFT JOIN store_chains CS ON (CS._store_id=S.id) \nLEFT JOIN chains C ON (C.id=CS._chain_id) \n_PROMOTION_JOIN_ \nWHERE S.id IN (SELECT store_id FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_'')\n_CUSTOM_FILTER_1_ \n_DISTANCE_CONDITION_ _OUTER_CATEGORY_CONDITION_ \nORDER BY list_order ASC \n_LIMIT_TEXT_1_ \n) \n\nUNION \n\n(SELECT S.id AS store_id, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner, \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nget_distance(_LATITUDE_, _LONGITUDE_, S.latitude, S.longitude) AS distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \n''N'' AS has_shopped_here, \n\n_CATEGORY_FIELD_  \n(SELECT C1.name FROM categories_level_1 C1 WHERE  _INNER_CATEGORY_CONDITION_  LIMIT 1) AS search_category, \nS.list_order \n\nFROM (SELECT S.*,\n_CATEGORY_FIELD_  \nget_distance(34.070436, -118.35048, S.latitude, S.longitude) AS distance,\nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 1, \nIF((''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_PHRASE_''),''%'')), 2, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 3, \nIF(''_LOCATION_PHRASE_'' LIKE CONCAT(''%'', S.`city`, ''%''), 4, \n5)))) AS list_order\n\nFROM stores S \n_PROMOTION_JOIN_ \n_CUSTOM_FILTER_2_ \n_DISTANCE_CONDITION_ _OUTER_CATEGORY_CONDITION_  \n_LIMIT_TEXT_2_) S \nORDER BY S.list_order ASC\n) \n\n) DATA1\nORDER BY  FIELD(has_shopped_here, ''Y'',''N''), _CUSTOM_ORDER_'),
(190, 'add_user_security_settings', 'INSERT INTO `user_security_settings` (_user_id, user_type, user_type_level, last_updated, _last_updated_by) \n\nVALUES (''_USER_ID_'', ''_USER_TYPE_'', ''_USER_TYPE_LEVEL_'', NOW(), ''_USER_ID_'')'),
(191, 'count_stores_where_user_shopped', 'SELECT COUNT(store_id) AS shopCount FROM cacheview__store_score_by_store WHERE user_id=''_USER_ID_'''),
(192, 'get_list_of_store_reviews', 'SELECT review_score AS score, comment AS details, \n(SELECT CONCAT(U.first_name, '' '', SUBSTR(U.last_name,1,1),''.'')) AS user_name,\n(SELECT CONCAT(L.city, '' '', L.state) FROM user_geo_tracking L \nWHERE L._user_id=R._user_id ORDER BY L.tracking_time DESC LIMIT 1) AS user_location,\nU.photo_url AS user_photo\n\nFROM reviews R \nLEFT JOIN users U ON (R._user_id=U.id) \nWHERE R.status=''active'' AND U.id IS NOT NULL AND R._store_id=''_STORE_ID_'' \nORDER BY R.last_updated DESC\n_LIMIT_TEXT_ '),
(193, 'add_store_review', 'INSERT INTO reviews (_user_id, _store_id, comment, review_score, status, date_entered, last_updated, _last_updated_by) \nVALUES (''_USER_ID_'', ''_STORE_ID_'', ''_COMMENT_'', ''_SCORE_'', ''active'', NOW(), NOW(), ''_USER_ID_'')\n\nON DUPLICATE KEY UPDATE review_score=VALUES(review_score), comment=VALUES(comment), last_updated=NOW();'),
(194, 'get_list_of_store_photos', 'SELECT *, CONCAT(''_BASE_IMAGE_URL_'',photo_url) AS photo FROM store_photos WHERE _store_id=''_STORE_ID_''\nORDER BY display_order ASC, date_entered DESC \n_LIMIT_TEXT_'),
(195, 'add_store_photo', 'INSERT INTO store_photos (photo_url, photo_note, photo_category, status, _store_id, date_entered, _entered_by) \nVALUES (''_PHOTO_URL_'', ''_PHOTO_NOTE_'', ''_PHOTO_CATEGORY_'', ''_STATUS_'', ''_STORE_ID_'', NOW(), ''_USER_ID_'')'),
(196, 'get_referral_count', 'SELECT COUNT(DISTINCT R._user_id) AS referral_count FROM referrals R WHERE R._referred_by=''_USER_ID_'' AND referrer_type=''user'' _QUERY_PART_'),
(197, 'get_referral_ids', 'SELECT R._user_id AS user_id FROM referrals R WHERE R._referred_by=''_USER_ID_'' AND referrer_type=''user'' _QUERY_PART_'),
(198, 'get_user_referrals', 'SELECT R.*, U.first_name, U.last_name, U.email_address \nFROM referrals R \nLEFT JOIN users U ON (R._user_id=U.id) \nWHERE R._referred_by=''_USER_ID_'' AND referrer_type=''user'' _QUERY_PART_ \nORDER BY R.activation_date DESC'),
(199, 'get_user_network_referrals', 'SELECT R.*, U.first_name, U.last_name, U.email_address \nFROM referrals R \nLEFT JOIN users U ON (R._user_id=U.id AND R.referrer_type=''user'') \nWHERE R._user_id IN (_USER_ID_LIST_) \nORDER BY U.first_name _LIMIT_TEXT_ '),
(200, 'get_number_of_invites', 'SELECT COUNT(id) AS invite_count FROM message_invites WHERE _user_id = ''_USER_ID_'' AND number_of_invitations > 0'),
(201, 'get_user_earnings', 'SELECT SUM(amount) AS amount FROM clout_v1_3cron.user_payment_tracking WHERE _user_id=''_USER_ID_'' AND status NOT IN (''declined'',''closed'') _DATE_CONDITION_'),
(202, 'get_clout_score_details_by_key', 'SELECT \n(SELECT MAX(activation_date) FROM referrals WHERE _referred_by = ''_USER_ID_'' AND referrer_type=''user'') AS last_time_user_joined_my_direct_network, \n(SELECT MAX(pay_date) FROM clout_v1_3cron.user_payment_tracking WHERE `status`=''approved'' AND _user_id=''_USER_ID_'') AS last_time_commission_was_earned,  \n(SELECT total_score FROM clout_v1_3cron.cacheview__clout_score WHERE user_id=''_USER_ID_'' LIMIT 1) AS clout_score, \n(SELECT L.commission FROM clout_v1_3cron.score_levels L \nLEFT JOIN clout_v1_3cron.cacheview__clout_score C ON ((C.total_score BETWEEN L.low_end_score AND L.high_end_score) OR (C.total_score > 999 AND L.high_end_score='''')) \nWHERE C.user_id=''_USER_ID_'' LIMIT 1) AS my_current_commission,\n(SELECT MAX(L.level+0) FROM clout_v1_3cron.score_levels L WHERE L.low_end_score <= (SELECT total_score FROM clout_v1_3cron.cacheview__clout_score WHERE user_id=''_USER_ID_'')) AS clout_score_level'),
(203, 'get_searchable_referral_list', 'SELECT R._user_id AS referral_id, R.activation_date AS last_activity_date, U.photo_url, U.first_name, U.last_name, CONCAT(U.first_name, '' '', U.last_name) AS name, U.email_address, U.telephone, \n(SELECT COUNT(_user_id) FROM referrals WHERE _referred_by = U.id AND referrer_type=''user'') AS total_network,\nIF((SELECT id FROM clout_v1_3cron.bank_accounts WHERE _user_id=U.id LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS has_linked_card \n\nFROM referrals R \nLEFT JOIN users U ON (R._user_id=U.id AND R.referrer_type=''user'') \nWHERE R._referred_by=''_USER_ID_'' AND R.referrer_type=''user'' _PHRASE_CONDITION_\nORDER BY R.activation_date DESC \n_LIMIT_TEXT_'),
(205, 'check_if_user_unsubscribed_by_email', 'SELECT * FROM unsubscribe_list WHERE email_address=''_EMAIL_ADDRESS_'' AND DATEDIFF(DATE(expiry_date), NOW()) > 0 LIMIT 1'),
(206, 'add_new_invitation_contact', 'INSERT IGNORE INTO contacts (_owner_id, first_name, last_name, phone, email, source, photo_url, date_entered) VALUES (''_OWNER_USER_ID_'', ''_FIRST_NAME_'', ''_LAST_NAME_'', ''_PHONE_NUMBER_'', ''_EMAIL_ADDRESS_'', ''_SOURCE_'', ''_PHOTO_URL_'', NOW())'),
(207, 'get_users_invited_emails', 'SELECT email AS email_address FROM contacts WHERE _owner_id=''_USER_ID_'''),
(209, 'add_message_invite', 'INSERT INTO message_invites (_user_id, first_name , last_name, invite_message, join_link, email_address, phone_number, method_used, invitation_time, referral_status, message_status, number_of_invitations, last_invitation_sent_on, sent_at_ip_address, _invitation_sent_by, message_status_date, referral_status_date) \n\nVALUES (''_USER_ID_'', ''_FIRST_NAME_'' , ''_LAST_NAME_'', ''_INVITE_MESSAGE_'', ''_JOIN_LINK_'', ''_EMAIL_ADDRESS_'', ''_PHONE_NUMBER_'', ''_METHOD_USED_'', NOW(), ''pending'', ''_MESSAGE_STATUS_'', ''1'', NOW(), ''_SENT_AT_IP_ADDRESS_'', ''_USER_ID_'', NOW(), NOW())\n\nON DUPLICATE KEY UPDATE first_name=''_FIRST_NAME_'' , last_name=''_LAST_NAME_'', invite_message=''_INVITE_MESSAGE_'', phone_number=''_PHONE_NUMBER_'', message_status=''_MESSAGE_STATUS_'', sent_at_ip_address=''_SENT_AT_IP_ADDRESS_'', message_status_date=NOW();'),
(210, 'get_user_links', 'SELECT CONCAT(''_BASE_URL_'',url_id) AS link FROM `referral_url_ids` WHERE _user_id=''_USER_ID_'' AND is_active=''Y'''),
(211, 'add_share_link', 'INSERT IGNORE INTO referral_url_ids (_user_id, url_id, is_active, is_primary, date_entered) \nVALUES (''_USER_ID_'', ''_URL_ID_'', ''Y'', ''_IS_PRIMARY_'', NOW())'),
(212, 'get_share_links', 'SELECT url_id AS link_id FROM referral_url_ids WHERE _user_id=''_USER_ID_'' AND is_active=''Y'''),
(213, 'get_message_statistics', 'SELECT \n(SELECT COUNT(_exchange_id) FROM message_status MS WHERE \n	(SELECT status FROM message_status WHERE _exchange_id=MS._exchange_id AND _user_id=MS._user_id ORDER BY date_entered DESC LIMIT 1) IN (''received'', NULL) \n	AND MS._user_id=''_USER_ID_''\n) AS unread, \n\n(SELECT COUNT(DISTINCT _promotion_id) FROM promotion_notices WHERE status=''received'' AND _user_id=''_USER_ID_'') AS events,\n\n(SELECT COUNT(S._exchange_id) FROM message_status S \nLEFT JOIN message_exchange X ON (X.id=S._exchange_id) \nLEFT JOIN message_templates T ON (T.id=X.template_id AND X.template_type=''system'' AND T.message_type=''send_store_schedule'') \nWHERE T.id IS NOT NULL AND S.status=''received'' AND S._user_id=''_USER_ID_'') AS reservations'),
(214, 'get_user_messages', 'SELECT A.*,\nIF(A.status <> ''received'', ''Y'', ''N'') AS is_read\n\nFROM \n(SELECT X.id AS message_id, X.subject, X.attachment_url, UNIX_TIMESTAMP(X.date_entered) AS date_received, \n\nIF(X.sender_type=''user'', (SELECT CONCAT(U.first_name,'' '',U.last_name) FROM users U WHERE U.id=X._recipient_id), \nIF(X.sender_type=''store'', (SELECT S.name FROM stores S WHERE S.id=X._recipient_id LIMIT 1), \n(SELECT C.name FROM chains C WHERE C.id=X._recipient_id LIMIT 1))) AS sender, \n\nIF(X.sender_type=''user'', (SELECT CONCAT(U.address_line_1,'' '',U.address_line_2, '' '', U.city, '' '', U.state, '' '', U.country_code, '' '', U.zipcode) FROM users U WHERE U.id=X._recipient_id), \nIF(X.sender_type=''store'', (SELECT CONCAT(S.address_line_1,'' '',S.address_line_2, '' '', S.city, '' '', S.state, '' '', S._country_code, '' '', S.zipcode) FROM stores S WHERE S.id=X._recipient_id LIMIT 1), \n(SELECT  CONCAT(C.address_line_1,'' '',C.address_line_2, '' '', C.city, '' '', C.state, '' '', C.country, '' '', C.zipcode) FROM chains C WHERE C.id=X._recipient_id LIMIT 1))) AS location,\n\n\nIF((SELECT message_type FROM message_templates WHERE id=X.template_id AND X.template_type=''system'' LIMIT 1) = ''system_alert_notification'', ''Y'', ''N'') AS is_alert,\n(SELECT status FROM message_status WHERE _user_id= ''_USER_ID_'' AND _exchange_id=X.id ORDER BY date_entered DESC LIMIT 1) AS status\n\nFROM message_exchange X \nWHERE X._recipient_id = ''_USER_ID_'' \n_PHRASE_CONDITION_ \n) A \n\nWHERE A.status <> ''archived'' \n_SENDER_CONDITION_ \nGROUP BY A.message_id\nORDER BY FIELD(is_read, ''N'',''Y''), A.date_received DESC  \n_LIMIT_TEXT_'),
(215, 'get_message_details', 'SELECT X.subject, X.details, X.sms, X.sender_type, X._recipient_id AS recipient_id, \nIF(X.attachment_url <> '''', CONCAT(''_DOWNLOAD_URL_'',X.attachment_url), '''') AS attachment_url, \nUNIX_TIMESTAMP(X.date_entered) AS date_received, \n\nIF(X.sender_type=''user'', (SELECT CONCAT(U.first_name,'' '',U.last_name) FROM users U WHERE U.id=X._recipient_id), \nIF(X.sender_type=''store'', (SELECT S.name FROM stores S WHERE S.id=X._recipient_id LIMIT 1), \n(SELECT C.name FROM chains C WHERE C.id=X._recipient_id LIMIT 1))) AS sender\n\nFROM message_exchange X \nWHERE X.id = ''_MESSAGE_ID_''\n\n'),
(216, 'add_message_status', 'INSERT INTO message_status (_exchange_id, _user_id, status, date_entered) \nVALUES (''_MESSAGE_ID_'', ''_USER_ID_'', ''_STATUS_'', NOW()) \n\nON DUPLICATE KEY UPDATE date_entered = NOW();'),
(217, 'get_user_store_review', 'SELECT review_score AS score, comment AS details\nFROM reviews R \nWHERE R._user_id =''_USER_ID_'' AND R._store_id=''_STORE_ID_'' '),
(218, 'add_user_referral', 'INSERT IGNORE INTO referrals (_user_id, _referred_by, referrer_type, sent_referral_by, activation_date) \n(SELECT ''_USER_ID_'' AS _user_id, ''_REFERRED_BY_'' AS _referred_by, ''_REFERRER_TYPE_'' AS referrer_type, ''_SENT_REFERRAL_BY_'' AS sent_referral_by, NOW() AS activation_date \nFROM users \nWHERE ''_USER_ID_'' <> ''_REFERRED_BY_'' OR ''_REFERRER_TYPE_'' <> ''_REFERRED_BY_TYPE_'' LIMIT 1)'),
(219, 'get_user_settings', 'SELECT _FIELDS_ FROM (\nSELECT U.id AS userId, U.email_address AS emailAddress, \nU.address_line_1 AS addressLine1, U.address_line_2 AS addressLine2, U.city, U.state, U.country_code AS country, U.zipcode, \nU.gender, \nIF(U.photo_url <>'''', CONCAT(''_BASE_PHOTO_URL_'',U.photo_url), '''') AS photo, \n\nCONCAT(first_name,'' '', last_name) AS name, UNIX_TIMESTAMP(birthday) AS birthday, telephone, UNIX_TIMESTAMP(date_entered) AS dateJoined\n\nFROM users U WHERE U.id=''_USER_ID_''\n) A '),
(220, 'get_saved_addresses', 'SELECT id AS contact_id, address_line_1, address_line_2, city, state, country, zipcode, is_primary, address_type, UNIX_TIMESTAMP(date_entered) AS date_entered FROM contact_addresses WHERE _user_id=''_USER_ID_'' AND is_active IN (''_IS_ACTIVE_'') ORDER BY date_entered DESC'),
(221, 'get_saved_emails', 'SELECT id AS contact_id, email_address, is_primary, UNIX_TIMESTAMP(date_entered) AS date_entered, is_active \nFROM contact_emails WHERE _user_id=''_USER_ID_'' AND is_active IN (''_IS_ACTIVE_'') ORDER BY date_entered DESC'),
(222, 'get_saved_phones', 'SELECT C.id AS contact_id, C._provider_id AS provider_id, C.telephone, C.is_active, \nIF(C._provider_id <> '''', (SELECT full_carrier_name FROM contact_phone_providers WHERE id=C._provider_id LIMIT 1), '''') AS provider_name, \nC.is_primary, UNIX_TIMESTAMP(C.date_entered) AS date_entered \nFROM contact_phones C \nWHERE C._user_id=''_USER_ID_'' AND C.is_active IN (''_IS_ACTIVE_'') \nORDER BY C.date_entered DESC'),
(223, 'add_user_photo', 'UPDATE users SET photo_url=''_PHOTO_URL_'' WHERE id=''_USER_ID_'''),
(224, 'get_system_states', 'SELECT state_code, state_name AS state FROM states WHERE ''_PHRASE_''='''' OR (''_PHRASE_'' <> '''' AND state_name LIKE ''%_PHRASE_%'') ORDER BY state_name _LIMIT_TEXT_'),
(225, 'get_system_countries', 'SELECT code AS country_code, name AS country FROM countries ORDER BY name'),
(226, 'add_user_address', 'INSERT INTO contact_addresses (_user_id, address_line_1, address_line_2, city, state, country, zipcode, address_type, date_entered) \nVALUES (''_USER_ID_'', ''_ADDRESS_LINE_1_'', ''_ADDRESS_LINE_2_'', ''_CITY_'', ''_STATE_'', ''_COUNTRY_'', ''_ZIPCODE_'', ''_ADDRESS_TYPE_'', NOW()) \nON DUPLICATE KEY UPDATE address_line_2=VALUES(address_line_2), state=VALUES(state), country=VALUES(country), is_active=''Y'''),
(227, 'update_address_type', 'UPDATE contact_addresses SET address_type=''_ADDRESS_TYPE_'' WHERE id=''_CONTACT_ID_'''),
(228, 'deactivate_user_address', 'UPDATE contact_addresses SET is_active=''N'' WHERE id=''_CONTACT_ID_'''),
(229, 'add_offer_request', 'INSERT INTO store_offer_requests (_user_id, _store_id, wants_cashback, wants_perks, wants_vip, date_entered, _entered_by, last_updated, _last_updated_by) \n\nVALUES (''_USER_ID_'', ''_STORE_ID_'', ''_WANTS_CASHBACK_'', ''_WANTS_PERKS_'', ''_WANTS_VIP_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'') \nON DUPLICATE KEY UPDATE wants_cashback=VALUES(wants_cashback), wants_perks=VALUES(wants_perks), wants_vip=VALUES(wants_vip), last_updated=NOW(), _last_updated_by=''_USER_ID_'''),
(230, 'update_offer_request', 'UPDATE store_offer_requests SET per_visit_spend=''_PER_VISIT_SPEND_'', per_month_spend=''_PER_MONTH_SPEND_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' \nWHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'''),
(231, 'add_communication_privacy', 'INSERT IGNORE INTO user_preferred_communication (_user_id, message_format) VALUES (''_USER_ID_'', ''_MESSAGE_FORMAT_'')'),
(232, 'delete_communication_privacy', 'DELETE FROM user_preferred_communication WHERE _user_id=''_USER_ID_'' AND message_format=''_MESSAGE_FORMAT_'''),
(233, 'add_user_email_address', 'INSERT IGNORE INTO contact_emails (_user_id, email_address, date_entered, is_active) \nVALUES (''_USER_ID_'', ''_EMAIL_ADDRESS_'', NOW(), ''N'')'),
(234, 'add_email_activation_code', 'UPDATE contact_emails SET activation_code=''_ACTIVATION_CODE_'' WHERE id=''_CONTACT_ID_'''),
(235, 'add_user_telephone', 'INSERT IGNORE INTO contact_phones (_user_id, _provider_id, telephone, is_primary, date_entered, is_active ) \nVALUES \n(''_USER_ID_'', ''_PROVIDER_ID_'', ''_TELEPHONE_'', ''_IS_PRIMARY_'', NOW(), ''N'')'),
(236, 'add_telephone_activation_code', 'UPDATE contact_phones SET activation_code=''_ACTIVATION_CODE_'' WHERE id=''_CONTACT_ID_'''),
(238, 'activate_telephone_by_code', 'UPDATE contact_phones SET is_active=''Y'' WHERE id=''_CONTACT_ID_'' AND activation_code=''_ACTIVATION_CODE_'''),
(239, 'get_communication_preferences', 'SELECT message_format FROM user_preferred_communication WHERE _user_id=''_USER_ID_'''),
(240, 'record_like_messages', 'INSERT INTO message_likes (_exchange_id, _user_id, user_like, user_dislike, date_entered, last_updated)\n\n(SELECT X.id AS _exchange_id, ''_USER_ID_'' AS _user_id, ''_LIKE_'' AS user_like, ''_DISLIKE_'' AS user_dislike, NOW() AS date_entered, NOW() AS last_updated FROM message_exchange X WHERE X.id IN (''_MESSAGES_''))\n\nON DUPLICATE KEY UPDATE user_like=VALUES(user_like), user_dislike=VALUES(user_dislike), last_updated=NOW()'),
(241, 'add_favorites_from_messages', 'INSERT IGNORE INTO store_favorites (_user_id, _store_id, date_entered) \nVALUES (''_USER_ID_'', ''_STORE_ID_'', ''_DATE_ENTERED_'')'),
(242, 'get_promotion_stores', 'SELECT S.id AS store_id, ''_IS_FEATURED_'' AS is_featured, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nS.distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \nIF((SELECT id FROM categories_level_1 WHERE name LIKE '''' LIMIT 1) IS NOT NULL, \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  name LIKE '''' LIMIT 1), \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  C1.id IN (SELECT SC._category_id FROM store_sub_categories SC WHERE SC._store_id=S.id)  LIMIT 1)\n) AS search_category, \nIF((SELECT _store_id FROM transactions WHERE _user_id=''_USER_ID_'' AND _store_id=S.id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS has_shopped_here, \nS.list_order\n\nFROM \n(\nSELECT S.*, get_distance(''_LATITUDE_'',''_LONGITUDE_'',S.latitude, S.longitude) AS distance, \n\nIF(S.`name` = ''_PHRASE_'', 1, \nIF(S.`name` LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.`name` LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3, \nIF(''_PHRASE_'' LIKE ''% %'' AND LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 )) > 3 AND S.`name` LIKE CONCAT(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 ), ''%'') AND ''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 4, \n\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._sub_category_id IN (_SUB_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 5,\n\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._category_id IN (_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 6,\n\nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 7, \nIF((''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_''),''%'')), 8, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 9, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%''), 10, \n11)))))))))) AS list_order\n\nFROM promotions P \nLEFT JOIN stores S ON (P.owner_id=S.id)\nWHERE P.status=''active'' \n	AND P.owner_type=''store'' \n	AND ((''_IS_FEATURED_''=''Y'' AND (NOW() BETWEEN P.boost_start_date AND P.boost_end_date) AND P.boost_remaining > 0)\n		OR (''_IS_FEATURED_''=''N'' AND (NOW() BETWEEN P.start_date AND P.end_date))\n		)\n	AND P.owner_id NOT IN (_EXCLUDE_ID_LIST_)\n	AND (''_PHRASE_''='''' OR (''_PHRASE_'' <> '''' AND (MATCH(S.name) AGAINST (''_PHRASE_'' IN BOOLEAN MODE) \n		OR (SELECT _store_id FROM store_sub_categories C WHERE C._sub_category_id IN (_SUB_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL\n		OR (SELECT _store_id FROM store_sub_categories C WHERE C._category_id IN (_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL\n	)))\nGROUP BY P.owner_id \n_DISTANCE_CONDITION_ \nORDER BY distance ASC \n_LIMIT_TEXT_\n) S \n\nORDER BY _ORDER_'),
(243, 'get_intersecting_common_words', 'SELECT word FROM common_words WHERE word IN (_PHRASE_WORDS_)'),
(244, 'search_stores', 'SELECT S.id AS store_id, ''_IS_FEATURED_'' AS is_featured, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nS.distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \nIF((SELECT id FROM categories_level_1 WHERE name LIKE '''' LIMIT 1) IS NOT NULL, \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  name LIKE '''' LIMIT 1), \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  C1.id IN (SELECT SC._category_id FROM store_sub_categories SC WHERE SC._store_id=S.id)  LIMIT 1)\n) AS search_category, \nIF((SELECT _store_id FROM transactions WHERE _user_id=''_USER_ID_'' AND _store_id=S.id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS has_shopped_here, \nS.list_order\n\nFROM \n(\nSELECT S.*, get_distance(''_LATITUDE_'',''_LONGITUDE_'',S.latitude, S.longitude) AS distance, \n\nIF(S.`name` = ''_PHRASE_'', 1, \nIF(S.`name` LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.`name` LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3, \nIF(''_PHRASE_'' LIKE ''% %'' AND LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 )) > 3 AND S.`name` LIKE CONCAT(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 ), ''%'') AND ''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 4, \n\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._sub_category_id IN (_SUB_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 5,\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._category_id IN (_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 6,\n\nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 7, \nIF((''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_''),''%'')), 8, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 9, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%''), 10, \n11)))))))))) AS list_order\n\nFROM stores S \nWHERE S.id NOT IN (_EXCLUDE_ID_LIST_) \n	AND S.zipcode IN (_ZIPCODE_LIST_) \n	AND (''_PHRASE_''='''' OR (''_PHRASE_'' <> '''' AND (MATCH(S.name) AGAINST (''_PHRASE_'' IN BOOLEAN MODE) \n	)))\n\n_DISTANCE_CONDITION_ \nORDER BY distance ASC\n_LIMIT_TEXT_\n) S \n\nORDER BY _ORDER_'),
(245, 'get_shopped_stores', 'SELECT S.id AS store_id, ''_IS_FEATURED_'' AS is_featured, \ncap_first_letter_in_words(S.name) AS name, \ncap_first_letter_in_words(S.address_line_1) AS address_line_1, \ncap_first_letter_in_words(S.address_line_2) AS address_line_2, \nS.city, S.state, S._country_code AS country, S.zipcode, S.latitude, S.longitude, LOWER(S.website) AS website, S.small_cover_image AS store_banner,  \n(SELECT _chain_id FROM store_chains WHERE _store_id=S.id LIMIT 1) AS chain_id, \n(SELECT C.small_banner FROM chains C LEFT JOIN store_chains CS ON (CS._chain_id=C.id) WHERE CS._store_id=S.id LIMIT 1) AS chain_banner,\nS.distance,\nget_store_score(''_USER_ID_'', S.id) AS store_score,\nhas_perk(''_USER_ID_'', S.id) AS has_perk,\nget_cashback_range(''_USER_ID_'', S.id, ''min'') AS min_cashback,\nget_cashback_range(''_USER_ID_'', S.id, ''max'') AS max_cashback,\nget_store_earnings(''_USER_ID_'', S.id,'''') AS store_earnings, \nIF((SELECT id FROM categories_level_1 WHERE name LIKE '''' LIMIT 1) IS NOT NULL, \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  name LIKE '''' LIMIT 1), \n	(SELECT C1.name FROM categories_level_1 C1 WHERE  C1.id IN (SELECT SC._category_id FROM store_sub_categories SC WHERE SC._store_id=S.id)  LIMIT 1)\n) AS search_category, \nIF((SELECT _store_id FROM transactions WHERE _user_id=''_USER_ID_'' AND _store_id=S.id LIMIT 1) IS NOT NULL, ''Y'',''N'') AS has_shopped_here, \nS.list_order\n\nFROM \n(\nSELECT S.*, get_distance(''_LATITUDE_'',''_LONGITUDE_'',S.latitude, S.longitude) AS distance, \n\nIF(S.`name` = ''_PHRASE_'', 1, \nIF(S.`name` LIKE CONCAT(''_PHRASE_'', ''%''), 2, \nIF(S.`name` LIKE CONCAT(''%'', ''_PHRASE_'', ''%''), 3, \nIF(''_PHRASE_'' LIKE ''% %'' AND LENGTH(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 )) > 3 AND S.`name` LIKE CONCAT(SUBSTRING_INDEX(''_PHRASE_'', '' '', 1 ), ''%'') AND ''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 4, \n\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._sub_category_id IN (_SUB_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 5,\n\nIF((SELECT _store_id FROM store_sub_categories C WHERE C._category_id IN (_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL, 6,\n\nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`address_line_1`, ''%''), 7, \nIF((''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%'') AND S.`address_line_1` LIKE CONCAT(''%'',REPLACE('' '', ''% '', ''_LOCATION_''),''%'')), 8, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`zipcode`, ''%''), 9, \nIF(''_LOCATION_'' LIKE CONCAT(''%'', S.`city`, ''%''), 10, \n11)))))))))) AS list_order,\n\nIF((SELECT P.owner_id FROM promotions P \n    WHERE P.owner_id=C.store_id AND P.status=''active'' AND P.owner_type=''store'' \n       AND (NOW() BETWEEN P.start_date AND P.end_date) LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS has_deals\nFROM cacheview__store_score_by_store C \nLEFT JOIN stores S ON (C.store_id=S.id)\nWHERE C.user_id=''_USER_ID_'' \n	AND C.store_id NOT IN (_EXCLUDE_ID_LIST_)\n	AND (''_PHRASE_''='''' OR (''_PHRASE_'' <> '''' AND (MATCH(S.name) AGAINST (''_PHRASE_'' IN BOOLEAN MODE) \n		OR (SELECT _store_id FROM store_sub_categories C WHERE C._sub_category_id IN (_SUB_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL\n		OR (SELECT _store_id FROM store_sub_categories C WHERE C._category_id IN (_CATEGORIES_) AND _store_id=S.id LIMIT 1) IS NOT NULL\n	)))\n\n_DISTANCE_CONDITION_ AND has_deals = ''_HAS_DEALS_''\nORDER BY distance ASC\n_LIMIT_TEXT_\n) S \n\nORDER BY _ORDER_'),
(246, 'get_location_phrases', 'SELECT CONCAT(address_line_1, '' '', address_line_2, '' '', city, '' '', state, '' '', country, '' '', zipcode) AS suggestion, id \nFROM contact_addresses \nWHERE is_active=''Y'' AND _user_id=''_USER_ID_'' AND (''''=''_PHRASE_'' OR ('''' <> ''_PHRASE_'' AND MATCH(address_line_1) AGAINST (''_PHRASE_''))) \n_LIMIT_TEXT_ '),
(247, 'get_zipcodes_near_this_zipcode', 'SELECT DISTINCT zipcode, latitude, longitude, \n(SELECT latitude FROM zipcodes WHERE zipcode=''_ZIPCODE_'' LIMIT 1) AS this_latitude,\n(SELECT longitude FROM zipcodes WHERE zipcode=''_ZIPCODE_'' LIMIT 1) AS this_longitude\nFROM zipcodes \nWHERE zipcode <> ''_ZIPCODE_''\nHAVING get_distance(this_latitude,this_longitude, latitude, longitude) <= ''_DISTANCE_'''),
(248, 'get_category_matches_for_search', 'SELECT id FROM categories_level_1 WHERE name LIKE CONCAT(''%'',''_PHRASE_'',''%'')'),
(249, 'get_sub_category_matches_for_search', 'SELECT id FROM categories_level_2 WHERE MATCH(name) AGAINST (REPLACE(''_PHRASE_'','' '','' +'') IN BOOLEAN MODE)'),
(250, 'get_zipcode_details', 'SELECT * FROM zipcodes WHERE zipcode=''_ZIPCODE_'' LIMIT 1'),
(251, 'remove_favorite_store', 'DELETE FROM store_favorites WHERE _user_id=''_USER_ID_'' AND _store_id=''_STORE_ID_'''),
(252, 'get_user_access_tokens', 'SELECT DISTINCT access_token FROM plaid_access_token WHERE _user_id IN (''_USER_IDS_'')'),
(253, 'add_user_social_media', 'INSERT IGNORE INTO user_social_media (_user_id, social_media_name, social_media_id, user_name, status, last_ip_address, date_entered, last_updated, _last_updated_by )\n\nVALUES (''_USER_ID_'', ''_SOCIAL_MEDIA_NAME_'', ''_SOCIAL_MEDIA_ID_'', ''_USER_NAME_'', ''_STATUS_'', ''_LAST_IP_ADDRESS_'', NOW(), NOW(), ''_USER_ID_'')'),
(254, 'is_rule_applied_to_user', 'SELECT \nIF((SELECT PR._rule_id FROM clout_v1_3iam.permission_group_mapping_rules PR \nLEFT JOIN clout_v1_3iam.user_access UA ON (UA.permission_group_id=PR._group_id)\nWHERE PR._rule_id=''_RULE_ID_'' AND UA.user_id=''_USER_ID_''\n) IS NOT NULL, ''Y'', ''N'') AS is_applied'),
(256, 'get_transaction_payees_for_search', 'SELECT DISTINCT zipcode, LOWER(state) AS state, LOWER(city) AS city, LOWER(SUBSTRING_INDEX(address, '' '', 3)) AS address, \nLOWER(IF(LENGTH(SUBSTRING_INDEX(payee_name, '' '', 1)) > 5, SUBSTRING_INDEX(payee_name, '' '', 1), \n   IF(LENGTH(SUBSTRING_INDEX(payee_name, '' '', 2)) > 8, \n   SUBSTRING_INDEX(payee_name, '' '', 2),\n   SUBSTRING_INDEX(payee_name, '' '', 3)\n))) AS name\n\nFROM transactions_raw R \nWHERE R._user_id=''_USER_ID_'' AND R.is_saved=''N''\n'),
(257, 'mongodb__search_stores', 'SELECT store_id, name, address FROM bname WHERE name LIKE ''_NAME_%'' AND zipcode=''_ZIPCODE_'' AND address LIKE ''_ADDRESS_%'' _LIMIT_TEXT_'),
(258, 'remove_temp_table', 'DROP TABLE IF EXISTS temp___TABLE_STUB_'),
(259, 'add_temp_table', 'CREATE TABLE temp___TABLE_STUB_ (_DEFINITION_)'),
(260, 'add_top_searches_for_user_stores', 'INSERT INTO temp___TABLE_STUB_ (store_id, real_name, search_name, real_address, search_address, zipcode, confidence) \n(SELECT ''_STORE_ID_'' AS store_id, ''_REAL_NAME_'' AS real_name, ''_SEARCH_NAME_'' AS search_name, ''_REAL_ADDRESS_'' AS real_address, ''_SEARCH_ADDRESS_'' AS search_address, ''_ZIPCODE_'' AS zipcode, IF(''_REAL_NAME_'' = ''_SEARCH_NAME_'', 90, 70) AS confidence)'),
(261, 'get_user_in_cron_schedule', 'SELECT * FROM cron_schedule WHERE activity_code = ''pull_all_user_transactions'' AND cron_value LIKE CONCAT(''user=_USER_ID_,%'')'),
(262, 'mongodb__search_stores_without_zipcode', 'SELECT store_id, name, address FROM bname WHERE name LIKE ''_NAME_%'' AND address LIKE ''_ADDRESS_%'' _LIMIT_TEXT_');
INSERT INTO `queries` (`id`, `code`, `details`) VALUES
(263, 'store_phrase_suggestions', 'SELECT SUGGESTIONS.* FROM (\n(SELECT id AS suggestion_id, cap_first_letter_in_words(name) AS suggestion, ''sub_category'' AS type,\nIF(name = ''_PHRASE_'', 100,\nIF(name LIKE ''_PHRASE_%'', 90,\n80)) AS score\n \nFROM categories_level_2 WHERE name LIKE ''%_PHRASE_%'' )\n\nUNION \n\n(SELECT id AS suggestion_id, cap_first_letter_in_words(name) AS suggestion, ''category'' AS type,\nIF(name = ''_PHRASE_'', 70,\nIF(name LIKE ''_PHRASE_%'', 60,\n50)) AS score\n \nFROM categories_level_1 WHERE name LIKE ''%_PHRASE_%'' )\n) SUGGESTIONS\nORDER BY LENGTH(suggestion), score DESC\n_LIMIT_TEXT_\n'),
(264, 'mongodb__test_distance', 'SELECT name, address FROM bname WHERE store_id > 40 AND mongo_distance(''-76.00282'',''41.19579'',''loc'') < 5 LIMIT 10'),
(265, 'get_featured_stores', 'SELECT DISTINCT P.owner_id AS store_id, get_distance(S.latitude, S.longitude,''_LATITUDE_'',''_LONGITUDE_'') AS distance, \n(SELECT MAX(amount) FROM clout_v1_3cron.promotions WHERE owner_id=P.owner_id AND (NOW() BETWEEN P.start_date AND P.end_date)) AS max_cashback,\nIFNULL(get_store_score(''_USER_ID_'', S.id),''0'') AS store_score\n\nFROM clout_v1_3cron.promotions P\nLEFT JOIN stores S ON (P.owner_id=S.id) \n\nWHERE P.status=''active'' \nAND (NOW() BETWEEN P.start_date AND P.end_date) \nAND (NOW() BETWEEN P.boost_start_date AND P.boost_end_date) AND P.boost_remaining > 0 \nAND P.owner_id NOT IN (''_EXCLUDE_ID_LIST_'') \n\nAND (\n	(""<>"_SUB_CATEGORIES_" AND (SELECT id FROM store_sub_categories WHERE _store_id=P.owner_id AND _sub_category_id IN (''_SUB_CATEGORIES_'') LIMIT 1) IS NOT NULL) \n	OR (""="_SUB_CATEGORIES_" AND ""<>"_CATEGORIES_" AND (SELECT id FROM store_sub_categories WHERE _store_id=P.owner_id AND _category_id IN (''_CATEGORIES_'') LIMIT 1) IS NOT NULL) \n	OR (""="_SUB_CATEGORIES_" AND ""="_CATEGORIES_" AND ''''<>''_PHRASE_'' AND MATCH(S.name) AGAINST(''_PHRASE_'') )\n	OR (""="_SUB_CATEGORIES_" AND ""="_CATEGORIES_" AND ''''=''_PHRASE_'')\n)\nHAVING distance < _MAX_DISTANCE_\nORDER BY _ORDER_\n_LIMIT_TEXT_\n'),
(266, 'mongodb__test_in_condition', 'SELECT store_id, name FROM bname WHERE search_rank=1 AND mongo_distance(''34.0690282'',''-118.3504599'',''loc'') < 10 LIMIT 5'),
(267, 'get_store_search_details', 'SELECT A.* FROM (_SEARCH_STRING_) A _SORT_BY_\n'),
(268, 'get_stores_with_deals', 'SELECT DISTINCT P.owner_id AS store_id, get_distance(S.latitude, S.longitude,''_LATITUDE_'',''_LONGITUDE_'') AS distance, \n(SELECT MAX(amount) FROM clout_v1_3cron.promotions WHERE owner_id=P.owner_id AND (NOW() BETWEEN P.start_date AND P.end_date)) AS max_cashback,\nIFNULL(get_store_score(''_USER_ID_'', S.id),''0'') AS store_score\n\nFROM clout_v1_3cron.promotions P\nLEFT JOIN stores S ON (P.owner_id=S.id) \n\nWHERE P.status=''active'' \nAND (NOW() BETWEEN P.start_date AND P.end_date) \nAND P.owner_id NOT IN (''_EXCLUDE_ID_LIST_'') \nAND (\n	(''_HAS_SHOPPED_HERE_''=''Y'' AND (SELECT id FROM clout_v1_3cron.transactions WHERE _store_id =P.owner_id AND _user_id=''_USER_ID_'' LIMIT 1) IS NOT NULL)\n	OR (''_HAS_SHOPPED_HERE_''=''N'')\n)\n\nAND (\n	(""<>"_SUB_CATEGORIES_" AND (SELECT id FROM store_sub_categories WHERE _store_id=P.owner_id AND _sub_category_id IN (''_SUB_CATEGORIES_'') LIMIT 1) IS NOT NULL) \n	OR (""="_SUB_CATEGORIES_" AND ""<>"_CATEGORIES_" AND (SELECT id FROM store_sub_categories WHERE _store_id=P.owner_id AND _category_id IN (''_CATEGORIES_'') LIMIT 1) IS NOT NULL) \n	OR (""="_SUB_CATEGORIES_" AND ""="_CATEGORIES_" AND ''''<>''_PHRASE_'' AND MATCH(S.name) AGAINST(''_PHRASE_'') )\n	OR (""="_SUB_CATEGORIES_" AND ""="_CATEGORIES_" AND ''''=''_PHRASE_'')\n)\nHAVING distance < _MAX_DISTANCE_\nORDER BY _ORDER_\n_LIMIT_TEXT_'),
(269, 'get_stores_where_shopped', 'SELECT store_id FROM clout_v1_3cron.cacheview__store_score_by_store WHERE user_id=''_USER_ID_'' AND store_id NOT IN (''_EXCLUDE_ID_LIST_'') '),
(270, 'mongodb__stores_in_sub_categories', 'SELECT store_id FROM bname WHERE subcategories IN (''_SUB_CATEGORIES_'') _EXCLUDE_CONDITION_ AND mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ _LIMIT_TEXT_'),
(271, 'mongodb__stores_in_categories', 'SELECT store_id FROM bname WHERE categories IN (''_CATEGORIES_'') _EXCLUDE_CONDITION_ AND mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ _LIMIT_TEXT_'),
(272, 'mongodb__stores_with_phrase', 'SELECT store_id, chain_id, loc.coordinates, categories, subcategories, is_featured, name, has_perk, max_cashback, min_cashback, search_rank FROM bname WHERE store_id NOT IN (''_EXCLUDE_ID_LIST_'') AND mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ AND name LIKE ''_PHRASE_%'' ORDER BY search_rank  _LIMIT_TEXT_'),
(273, 'remove_user_by_id', 'DELETE FROM users WHERE id=''_USER_ID_'''),
(274, 'remove_user_contact', 'DELETE FROM contact_phones WHERE _user_id=''_USER_ID_'''),
(275, 'remove_user_security_settings', 'DELETE FROM user_security_settings WHERE _user_id=''_USER_ID_'''),
(276, 'remove_user_referral', 'DELETE FROM referrals WHERE _user_id=''_USER_ID_'' AND referrer_type=''user'''),
(277, 'remove_user_permission_group', 'DELETE FROM clout_v1_3iam.user_access WHERE user_id=''_USER_ID_'''),
(278, 'remove_user_message_settings', 'DELETE FROM user_preferred_communication WHERE _user_id=''_USER_ID_'''),
(279, 'remove_user_social_media', 'DELETE FROM user_social_media WHERE _user_id=''_USER_ID_'''),
(280, 'remove_user_sending_record', 'DELETE FROM message_exchange WHERE _sender_id=''_USER_ID_'''),
(281, 'remove_user_sending_status', 'DELETE FROM message_status WHERE _user_id=''_USER_ID_'''),
(282, 'get_list_of_inviters', 'SELECT DISTINCT I._user_id AS user_id \nFROM message_invites I \nLEFT JOIN users U ON (U.id=I._user_id) \nLEFT JOIN clout_v1_3iam.user_access A ON (U.id=A.user_id) \nLEFT JOIN clout_v1_3iam.permission_groups G ON (A.permission_group_id=G.id)\nWHERE I.email_address = ''_EMAIL_ADDRESS_'' _INVITER_CONDITION_ \n\nORDER BY I.invitation_time ASC'),
(283, 'update_user_access_by_group_name', 'UPDATE clout_v1_3iam.user_access SET \n\npermission_group_id = (SELECT id FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1), \n\nlast_updated=NOW()\n\nWHERE user_id = ''_USER_ID_'' \nAND (SELECT id FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1) IS NOT NULL'),
(284, 'get_raw_bank_account_record', 'SELECT A.* FROM \r\n((SELECT account_id, _user_id AS user_id, status, account_number, account_number_real, account_nickname, _institution_id AS bank_id FROM bank_accounts_credit_raw WHERE _user_id=''_USER_ID_'')\r\nUNION \r\n(SELECT account_id, _user_id AS user_id, status, account_number, account_number_real, account_nickname, _institution_id AS bank_id FROM bank_accounts_other_raw WHERE _user_id=''_USER_ID_'')\r\n) A'),
(285, 'get_user_permission_types', 'SELECT A.user_id, G.group_type AS type FROM clout_v1_3iam.user_access A LEFT JOIN clout_v1_3iam.permission_groups G ON (A.permission_group_id=G.id) WHERE user_id IN (''_USER_IDS_'') _ORDER_CONDITION_'),
(286, 'get_group_by_name', 'SELECT id, name, group_type, is_removable FROM clout_v1_3iam.`permission_groups` WHERE LOWER(name) = LOWER(''_GROUP_NAME_'')'),
(287, 'get_user_network_referral_ids', 'SELECT * FROM \n((SELECT _user_id AS user_id FROM referrals WHERE _referred_by=''_USER_ID_'' AND referrer_type=''user'')\n\nUNION \n\n(SELECT _user_id AS user_id FROM referrals R1 \nWHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by=''_USER_ID_'' AND referrer_type=''user'')  AND referrer_type=''user'')\n\nUNION \n\n(SELECT _user_id AS user_id FROM referrals R1 \nWHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by=''_USER_ID_'' AND referrer_type=''user'')) AND referrer_type=''user'' AND R1.referrer_type=''user'')\n\nUNION \n\n(SELECT _user_id AS user_id FROM referrals R1 \nWHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by IN (SELECT _user_id FROM referrals WHERE _referred_by=''_USER_ID_'' AND referrer_type=''user'') AND referrer_type=''user'') AND referrer_type=''user'') AND R1.referrer_type=''user'')\n) A'),
(288, 'update_invite_status_with_limit', 'UPDATE message_invites M, (SELECT id FROM message_invites WHERE _user_id=''_USER_ID_'' _STATUS_CONDITION_ ORDER BY invitation_time _LIMIT_TEXT_) A SET M.message_status = ''_NEW_STATUS_'', message_status_date=NOW() \nWHERE M.id = A.id'),
(289, 'get_user_invitations_by_status', 'SELECT * FROM message_invites WHERE message_status=''_STATUS_'' AND _user_id=''_USER_ID_'' '),
(290, 'get_invitation_list', 'SELECT id AS invite_id, _user_id AS user_id, email_address, join_link, invitation_time, invite_message\n\nFROM message_invites WHERE message_status=''_STATUS_'' ORDER BY invitation_time _LIMIT_TEXT_'),
(291, 'update_invite_status', 'UPDATE message_invites SET message_status=''_MESSAGE_STATUS_'', message_status_date=NOW() WHERE id=''_INVITE_ID_'''),
(292, 'get_invitation_list_users', 'SELECT DISTINCT _user_id AS user_id FROM message_invites WHERE message_status=''_STATUS_'' ORDER BY invitation_time _LIMIT_TEXT_'),
(293, 'get_non_responsive_invitations', 'SELECT id AS invite_id FROM message_invites I \nWHERE message_status IN (''sent'',''read'',''bounced'') \nAND DATEDIFF(NOW(),invitation_time) >= _DAYS_OLD_ \nAND referral_status=''pending'' \nAND invite_message=''_OLD_MESSAGE_CODE_'' \nAND (SELECT id FROM users WHERE email_address=I.email_address LIMIT 1) IS NULL\n\nORDER BY invitation_time \n\n_LIMIT_TEXT_'),
(294, 'resend_old_invite', 'UPDATE message_invites SET invite_message=''_NEW_CODE_'', message_status=''_NEW_STATUS_'', \nnumber_of_invitations = (number_of_invitations + 1), \nmessage_status_date=NOW() \n\nWHERE id=''_INVITE_ID_'''),
(295, 'get_provider_by_id', 'SELECT id AS provider_id, full_carrier_name FROM contact_phone_providers WHERE id=''_PROVIDER_ID_'''),
(296, 'cancel_invitation_message', 'UPDATE message_invites SET message_status=''cancelled'', number_of_invitations=''0'', message_status_date=NOW() WHERE id=''_INVITE_ID_'''),
(297, 'update_invite_details', 'UPDATE message_invites SET \nfirst_name=''_FIRST_NAME_'', \nlast_name=''_LAST_NAME_'', \nphone_number=''_PHONE_NUMBER_''\n\nWHERE email_address=''_EMAIL_ADDRESS_'''),
(298, 'link_new_user_to_invitation', 'UPDATE message_invites SET friend_id=''_NEW_USER_ID_'', referral_status=''_REFERRAL_STATUS_'',\nmessage_status=''_MESSAGE_STATUS_'', \nread_ip_address=''_READ_IP_ADDRESS_'', \nmessage_status_date=NOW(),\nreferral_status_date=NOW() \nWHERE email_address=''_EMAIL_ADDRESS_'' AND _user_id=''_REFERRER_ID_'''),
(299, 'update_user_security_settings', 'UPDATE user_security_settings SET user_type=''_USER_TYPE_'', _last_updated_by=''_UPDATED_BY_'', last_updated=NOW() WHERE _user_id=''_USER_ID_'''),
(300, 'update_user_type_by_group_name', 'UPDATE user_security_settings SET user_type = (SELECT group_type FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1), \n\nlast_updated=NOW()\n\nWHERE _user_id = ''_USER_ID_'' \nAND (SELECT group_type FROM clout_v1_3iam.permission_groups WHERE LOWER(name)=LOWER(''_GROUP_NAME_'') LIMIT 1) IS NOT NULL'),
(301, 'get_message_templates', 'SELECT id AS template_id, subject, name, body, sms, \nIF(attachment <> '''', CONCAT(''_BASE_URL_'',attachment), '''') AS attachment \nFROM message_user_templates WHERE owner_id IN (''_OWNER_ID_'') AND owner_type=''_OWNER_TYPE_'' _PHRASE_CONDITION_ _LIMIT_TEXT_'),
(304, 'get_message_exchange_list', 'SELECT * FROM message_exchange \nWHERE (send_system=''Y'' AND send_system_result=''_STATUS_'' \nOR send_email=''Y'' AND send_email_result=''_STATUS_'' \nOR send_sms=''Y'' AND send_sms_result=''_STATUS_'') \n\nAND DATE(send_date) <= NOW()\nORDER BY send_date ASC \n\n_LIMIT_TEXT_'),
(305, 'update_message_exchange_field', 'UPDATE message_exchange SET _FIELD_NAME_=''_FIELD_VALUE_'' WHERE id=''_EXCHANGE_ID_'''),
(307, 'get_users_without_bank_account', 'SELECT U.id AS user_id \nFROM users U \nWHERE U.user_status=''active'' \nAND (SELECT id FROM bank_accounts WHERE _user_id=U.id LIMIT 1) IS NULL \n'),
(308, 'get_users_without_network', 'SELECT U.id AS user_id \nFROM users U \nWHERE U.user_status=''active'' \nAND (SELECT id FROM referrals WHERE _referred_by=U.id AND referrer_type=''user'' LIMIT 1) IS NULL \n'),
(309, 'save_facebook_photo', 'INSERT INTO user_facebook_data (facebook_id, photo_url, is_silhoutte, date_entered, last_updated) \nVALUES \n(''_FACEBOOK_ID_'', ''_PHOTO_URL_'', ''_IS_SILHOUTTE_'', NOW(), NOW())\n\nON DUPLICATE KEY UPDATE \nphoto_url = IF(''_IS_SILHOUTTE_'' = ''N'' OR photo_url = '''', ''_PHOTO_URL_'', photo_url),\nis_silhoutte = IF(''_IS_SILHOUTTE_'' = ''N'' OR is_silhoutte = ''N'', ''_IS_SILHOUTTE_'', is_silhoutte), \nlast_updated=NOW()'),
(310, 'save_facebook_details', 'INSERT INTO user_facebook_data (facebook_id, email, name, first_name, last_name, age_range, gender, birthday, profile_link, timezone_offset, date_entered, last_updated) \r\nVALUES \r\n(''_FACEBOOK_ID_'', ''_EMAIL_'', ''_NAME_'', ''_FIRST_NAME_'', ''_LAST_NAME_'', ''_AGE_RANGE_'', ''_GENDER_'', ''_BIRTHDAY_'', ''_PROFILE_LINK_'', ''_TIMEZONE_OFFSET_'', NOW(), NOW())\r\n\r\nON DUPLICATE KEY UPDATE \r\nemail=''_EMAIL_'', name=''_NAME_'', first_name=''_FIRST_NAME_'', last_name=''_LAST_NAME_'', age_range=''_AGE_RANGE_'', gender=''_GENDER_'', birthday=''_BIRTHDAY_'', profile_link=''_PROFILE_LINK_'', timezone_offset=''_TIMEZONE_OFFSET_'', last_updated=NOW()'),
(311, 'update_user_facebook_field', 'UPDATE user_facebook_data SET owner_user_id=''_USER_ID_'' WHERE facebook_id=''_FACEBOOK_ID_'''),
(312, 'get_referral_code', 'SELECT * FROM referral_url_ids WHERE url_id=''_REFERRAL_CODE_'' LIMIT 1'),
(313, 'add_referral_code', 'INSERT INTO referral_url_ids ( _user_id, url_id, is_active, is_primary, date_entered)\r\n\r\n(SELECT ''_USER_ID_'' AS _user_id, ''_REFERRAL_CODE_'' AS url_id, ''Y'' AS is_active, \r\nIF((SELECT id FROM referral_url_ids WHERE is_active=''Y'' AND _user_id=''_USER_ID_'' LIMIT 1) IS NULL, ''Y'', ''N'') AS is_primary, \r\nNOW() AS date_entered)'),
(314, 'assign_user_new_clout_id', 'UPDATE users \nSET clout_id = CONCAT(UNIX_TIMESTAMP(),''-'',''_USER_ID_'') \nWHERE id = ''_USER_ID_'''),
(315, 'get_permission_group_types', 'SELECT DISTINCT group_type AS type_code, `clout_v1_3`.cap_first_letter_in_words(REPLACE(group_type,''_'','' '')) AS type_display\n\nFROM `clout_v1_3iam`.permission_groups WHERE 1=1 _CATEGORY_CONDITION_ \nORDER BY group_type '),
(316, 'delete_permission_group_rules', 'DELETE FROM `clout_v1_3iam`.permission_group_mapping_rules WHERE _group_id=''_GROUP_ID_'''),
(317, 'delete_permission_group_permissions', 'DELETE FROM `clout_v1_3iam`.permission_group_mapping_permissions WHERE _group_id=''_GROUP_ID_'''),
(318, 'delete_permission_group', 'DELETE FROM `clout_v1_3iam`.permission_groups WHERE id=''_GROUP_ID_'''),
(319, 'set_user_access_group_by_field', 'UPDATE `clout_v1_3iam`.user_access SET permission_group_id=''_GROUP_ID_'' WHERE _FIELD_NAME_=''_FIELD_VALUE_'''),
(320, 'add_raw_bank', 'INSERT INTO banks_raw (third_party_id, institution_name, institution_code, home_url, logo_url, phone_number, is_featured, address_line_1, address_line_2, city, state, _country_code, email_address, currency_code, username_placeholder, password_placeholder, has_mfa, mfa_details, status, date_entered, _entered_by, last_updated, _last_updated_by)\r\n\r\nVALUES (''_THIRD_PARTY_ID_'', ''_INSTITUTION_NAME_'', ''_INSTITUTION_CODE_'', ''_HOME_URL_'', ''_LOGO_URL_'', ''_PHONE_NUMBER_'', ''_IS_FEATURED_'', ''_ADDRESS_LINE_1_'', ''_ADDRESS_LINE_2_'', ''_CITY_'', ''_STATE_'', ''_COUNTRY_CODE_'', ''_EMAIL_ADDRESS_'', ''_CURRENCY_CODE_'', ''_USERNAME_PLACEHOLDER_'', ''_PASSWORD_PLACEHOLDER_'', ''_HAS_MFA_'', ''_MFA_DETAILS_'', ''_STATUS_'', NOW(), ''_USER_ID_'', NOW(), ''_USER_ID_'')\r\n\r\nON DUPLICATE KEY UPDATE institution_code=''_INSTITUTION_CODE_'', home_url=''_HOME_URL_'', logo_url=''_LOGO_URL_'', phone_number=''_PHONE_NUMBER_'', address_line_1=''_ADDRESS_LINE_1_'', address_line_2=''_ADDRESS_LINE_2_'', city=''_CITY_'', state=''_STATE_'', _country_code=''_COUNTRY_CODE_'', email_address=''_EMAIL_ADDRESS_'', currency_code=''_CURRENCY_CODE_'', username_placeholder=''_USERNAME_PLACEHOLDER_'', password_placeholder=''_PASSWORD_PLACEHOLDER_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'''),
(321, 'delete_activity_log', 'DELETE FROM activity_log WHERE user_id=''_USER_ID_'''),
(322, 'get_user_message_contact', 'SELECT \nIF(''_USER_TYPE_''=''user'', (SELECT CONCAT(U.first_name,'' '',U.last_name) FROM users U WHERE U.id=''_USER_ID_''), \nIF(''_USER_TYPE_''=''store'', (SELECT S.name FROM stores S WHERE S.id=''_USER_ID_'' LIMIT 1), \n(SELECT C.name FROM chains C WHERE C.id=''_USER_ID_'' LIMIT 1))) AS sender, \n\nIF(''_USER_TYPE_''=''user'', (SELECT CONCAT(U.address_line_1,'' '',U.address_line_2, '' '', U.city, '' '', U.state, '' '', U.country_code, '' '', U.zipcode) FROM users U WHERE U.id=''_USER_ID_''), \nIF(''_USER_TYPE_''=''store'', (SELECT CONCAT(S.address_line_1,'' '',S.address_line_2, '' '', S.city, '' '', S.state, '' '', S._country_code, '' '', S.zipcode) FROM stores S WHERE S.id=''_USER_ID_'' LIMIT 1), \n(SELECT  CONCAT(C.address_line_1,'' '',C.address_line_2, '' '', C.city, '' '', C.state, '' '', C.country, '' '', C.zipcode) FROM chains C WHERE C.id=''_USER_ID_'' LIMIT 1))) AS location'),
(323, 'get_user_photo', 'SELECT \r\nIFNULL(IFNULL(\r\n(SELECT photo_url FROM users WHERE id=''_USER_ID_'' LIMIT 1), \r\n(SELECT photo_url FROM user_facebook_data WHERE owner_user_id=''_USER_ID_'' LIMIT 1)\r\n), '''') AS photo_url'),
(324, 'mongodb__stores_within_distance', 'SELECT store_id FROM bname WHERE mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ _LIMIT_TEXT_'),
(325, 'get_network_referrer', 'SELECT _referred_by AS referrer_id FROM referrals WHERE _user_id=''_USER_ID_'''),
(326, 'share_button_details', 'SELECT id AS _button_id, public_id AS public_button_id, notes, _user_id AS third_party_user_id, referral_code, button_length, button_size, navigation, website, redirect_url, deactivation_reason_code, is_active, UNIX_TIMESTAMP(date_entered) AS date_entered\r\nFROM share_buttons \r\nWHERE public_id = ''_PUBLIC_BUTTON_ID_''\r\n'),
(327, 'save_share_action', 'INSERT INTO share_actions \r\n(_user_id, public_button_id, `action`, fields_shared, browser, ip_address, date_entered)\r\nVALUES\r\n(''_USER_ID_'', ''_PUBLIC_BUTTON_ID_'', ''_ACTION_'', ''_FIELDS_SHARED_'', ''_BROWSER_'', ''_IP_ADDRESS_'', NOW())'),
(328, 'save_share_button', 'INSERT INTO share_buttons (public_id, notes, _user_id, referral_code, length, size, navigation, website, redirect_url, deactivation_reason_code, is_active, date_entered)\r\nVALUES (''_PUBLIC_BUTTON_ID_'', ''_NOTES_'', ''_OWNER_USER_ID_'', ''_REFERRAL_CODE_'', ''_BUTTON_LENGTH_'', ''_BUTTON_SIZE_'', ''_NAVIGATION_'', ''_WEBSITE_'', ''_REDIRECT_URL_'', '''', ''Y'', NOW())'),
(329, 'get_user_for_third_party', 'SELECT B.*, \r\nIFNULL((SELECT level_name FROM vip_levels WHERE _store_id=B.store_id AND level_score < B.score ORDER BY level_score DESC LIMIT 1), \r\n''UNQUALIFIED'') AS vip_level\r\n\r\nFROM \r\n(SELECT A.*, \r\n	IF(A.store_id IS NULL, 0, get_store_score(A.user_id, A.store_id)) AS score, \r\n	IF(A.store_id IS NULL, '''', (SELECT name FROM stores WHERE id=A.store_id LIMIT 1)) AS store_name\r\n\r\n	FROM (SELECT U.id AS user_id, U.first_name, U.last_name, U.email_address, \r\n			(SELECT _store_id FROM share_buttons WHERE public_id=''_PUBLIC_BUTTON_ID_'' LIMIT 1) AS store_id\r\n			FROM users U \r\n			WHERE U.clout_id=''_PUBLIC_USER_ID_''\r\n		) A\r\n) B'),
(330, 'mongodb__get_public_store_mapping', 'SELECT store_id, name, address FROM bname WHERE public_store_key = ''_PUBLIC_STORE_KEY_'''),
(331, 'search_for_store_competitors', '(SELECT id AS store_id, cap_first_letter_in_words(name) AS store_name, clout_id, \r\nCONCAT(address_line_1, '' '', address_line_2, '', '', city, '' '', state, '', '', zipcode) AS address, \r\ncap_first_letter_in_words(city) AS city, state, zipcode, _country_code AS country, \r\nget_distance(''_LATITUDE_'',''_LONGITUDE_'',latitude, longitude) AS distance\r\n \r\nFROM stores \r\nWHERE id NOT IN (''_EXCLUDE_ID_LIST_'') \r\n	AND id IN (SELECT competitor_id FROM store_competitors WHERE _store_id=''38399'')\r\n)\r\n\r\nUNION \r\n\r\n(SELECT id AS store_id, cap_first_letter_in_words(name) AS store_name, clout_id, \r\nCONCAT(address_line_1, '' '', address_line_2, '', '', city, '' '', state, '', '', zipcode) AS address, \r\ncap_first_letter_in_words(city) AS city, state, zipcode, _country_code AS country, \r\nget_distance(''_LATITUDE_'',''_LONGITUDE_'',latitude,longitude) AS distance\r\n\r\nFROM stores S \r\nWHERE (''target'' <> '''' AND (MATCH(name) AGAINST (''_PHRASE_'' IN BOOLEAN MODE))) \r\n	AND is_store_competitor(id, ''_STORE_ID_'')\r\n 	AND id NOT IN (''_EXCLUDE_ID_LIST_'') \r\n)\r\nORDER BY distance, LENGTH(store_name)\r\n_LIMIT_TEXT_'),
(332, 'update_reservation_status', 'UPDATE store_schedule SET status=''_STATUS_'', reservation_status=''_RESERVATION_STATUS_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' WHERE id =\n(SELECT * FROM(SELECT id FROM store_schedule WHERE _user_id=''_USER_ID_'' AND _promotion_id=''_PROMOTION_ID_'' AND (reservation_status = ''active'' OR reservation_status = ''confirmed'')) tmp);\n'),
(333, 'update_reservation_details', 'UPDATE store_schedule SET \nscheduler_name=''_SCHEDULER_NAME_'', scheduler_email=''_SCHEDULER_EMAIL_'', scheduler_phone=''_SCHEDULER_PHONE_'', telephone_provider_id=''_TELEPHONE_PROVIDER_ID_'',\nphone_type=''_PHONE_TYPE_'', \nschedule_date=''_SCHEDULE_DATE_'', number_in_party=''_NUMBER_IN_PARTY_'', special_request=''_SPECIAL_REQUEST_'', last_updated=NOW(), _last_updated_by=''_USER_ID_'' \n\nWHERE id=''_RESERVATION_ID_'''),
(334, 'get_list_of_reservations', 'SELECT R.*, S.name AS store_name, S.phone_number AS contact_phone, S.email_address AS contact_email, P.name AS promotion_title, UNIX_TIMESTAMP(R.schedule_date) AS _schedule_date, \nP.description AS promotion_details,  \n(SELECT GROUP_CONCAT(rule_details SEPARATOR '', '') FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=R.promotion_id) AS promotion_rules, \nIF((SELECT id FROM clout_v1_3cron.promotion_rules WHERE _promotion_id=R.promotion_id AND rule_type=''requires_confirmation'' LIMIT 1) IS NOT NULL, ''Y'', ''N'') AS requires_confirmation,\n\nIF(is_date_this_week(R.schedule_date, ''Y'') = ''Y'', ''this_week'',\nIF(is_date_next_week(R.schedule_date) = ''Y'', ''next_week'',\n(SELECT MONTHNAME(R.schedule_date))\n)) AS date_category\n\nFROM (\nSELECT id AS reservation_id, _promotion_id AS promotion_id, number_in_party, _store_id AS store_id, IF(reservation_status=''confirmed'',''Y'',''N'') AS is_confirmed, schedule_date\nFROM clout_v1_3.store_schedule S \nWHERE _user_id=''_USER_ID_'' AND status=''_STATUS_'' _SEARCH_STRING_\nORDER BY schedule_date\n_LIMIT_TEXT_\n) R\nLEFT JOIN clout_v1_3.stores S ON (S.id=R.store_id)\nLEFT JOIN clout_v1_3cron.promotions P ON (P.id=R.promotion_id)\n_PHRASE_CONDITION_ \n'),
(335, 'get_reservation_by_id', 'SELECT scheduler_name, number_in_party, scheduler_email, scheduler_phone, telephone_provider_id, phone_type, UNIX_TIMESTAMP(schedule_date) AS _schedule_date,\nspecial_request, is_schedule_used, store_notes, is_email_sent, is_sms_sent, is_voice_sent, IF(reservation_status=''confirmed'',''Y'',''N'') AS is_confirmed, status, UNIX_TIMESTAMP(date_entered) AS _date_entered, \nUNIX_TIMESTAMP(last_updated) AS _last_updated,\n(SELECT CONCAT(first_name, '' '', last_name) FROM clout_v1_3.users WHERE id=_last_updated_by LIMIT 1) AS last_updated_by\nFROM clout_v1_3.store_schedule R WHERE id = ''_RESERVATION_ID_'''),
(336, 'get_user_contact_information', 'SELECT id AS user_id, CONCAT(first_name, '' '', last_name) AS scheduler_name, email_address AS scheduler_email, telephone AS scheduler_phone, _provider_id AS provider_id, phone_type FROM users U LEFT JOIN\n\n(SELECT _user_id, _provider_id FROM clout_v1_3msg.contact_phones WHERE is_primary = ''Y'') P ON P._user_id = U.id WHERE U.id = ''_USER_ID_'' '),
(338, 'get_store_name_by_id', 'SELECT name FROM stores S WHERE S.id = ''_STORE_ID_'''),
(339, 'get_store_owner_id', 'SELECT user_id FROM store_owners WHERE parent_id = ''_STORE_ID_'''),
(340, 'mongodb__get_stores_in_search_categories', 'SELECT store_id, chain_id, loc.coordinates, categories, subcategories, is_featured, name, has_perk, max_cashback, min_cashback, search_rank FROM bname WHERE mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ AND _CATEGORY_CONDITION_ AND store_id NOT IN (''_EXCLUDE_ID_LIST_'') ORDER BY search_rank _LIMIT_TEXT_'),
(341, 'mongodb__get_stores_featured', 'SELECT store_id, chain_id, loc.coordinates, categories, subcategories, is_featured, name, has_perk, max_cashback, min_cashback, search_rank FROM bname WHERE mongo_distance(''_LATITUDE_'',''_LONGITUDE_'',''loc'') < _MAX_DISTANCE_ AND  search_rank=''1'' _EXCLUDE_CONDITION_ _LIMIT_TEXT_'),
(342, 'mongodb__get_stores_shopped', 'SELECT store_id, chain_id, loc.coordinates, categories, subcategories, is_featured, name, has_perk, max_cashback, min_cashback, search_rank FROM bname WHERE _INCLUDE_CONDITION_ ORDER BY search_rank _LIMIT_TEXT_'),
(344, 'get_referral_level_count', 'SELECT \nIF(level_1, LENGTH(level_1) - LENGTH(REPLACE(level_1, '','', '''')) + 1, 0) AS level1, \nIF(level_2, LENGTH(level_2) - LENGTH(REPLACE(level_2, '','', '''')) + 1, 0) AS level2, \nIF(level_3, LENGTH(level_3) - LENGTH(REPLACE(level_3, '','', '''')) + 1, 0) AS level3, \nIF(level_4, LENGTH(level_4) - LENGTH(REPLACE(level_4, '','', '''')) + 1, 0) AS level4 \nFROM clout_v1_3cron.datatable__network_data \nWHERE user_id=''_USER_ID_'''),
(345, 'get_network_level_ids', 'SELECT level_1, level_2, level_3, level_4 FROM clout_v1_3cron.datatable__network_data WHERE user_id=''_USER_ID_'''),
(346, 'get_user_details_list_profile', 'SELECT \nU.id AS user_id,\nU.first_name AS first_name,\nU.last_name AS last_name,\nU.email_address AS email_address,\nU.email_verified AS email_verified,\nU.telephone AS mobile,\nU.mobile_verified AS mobile_verified,\nU.gender AS gender,\nIF(U.birthday IS NOT NULL AND U.birthday NOT LIKE ''%0000%'', UNIX_TIMESTAMP(U.birthday), '' '') AS birthday,\nCONCAT(U.address_line_1,'' '', U.address_line_2) AS address,\nU.city AS city,\nU.state AS state,\nU.zipcode AS zipcode,\nU.country_code AS country,\nU.photo_url AS photo,\nU.driver_license AS driver_license,\nU.driver_license_verified AS driver_license_verified,\nU.ssn AS ssn,\nU.address_verified AS address_verified,\nIF(U.date_entered IS NOT NULL AND U.date_entered NOT LIKE ''%0000%'', UNIX_TIMESTAMP(U.date_entered), '' '') AS date_joined,\nU.user_status AS user_status,\nIF((SELECT id FROM  clout_v1_3.user_social_media WHERE _user_id = U.id AND social_media_name = ''facebook'' LIMIT 1) IS NOT NULL, ''Y'',''N'') AS facebook_connected,\nIF((SELECT id FROM  clout_v1_3.user_social_media WHERE _user_id = U.id AND social_media_name = ''linkedin'' LIMIT 1) IS NOT NULL, ''Y'',''N'') AS linkedin_connected,\nIF((SELECT id FROM  clout_v1_3.user_social_media WHERE _user_id = U.id AND social_media_name = ''twitter'' LIMIT 1) IS NOT NULL, ''Y'',''N'') AS twitter_connected,\nIF(U.email_address <> '''', ''Y'', ''N'') AS email_connected,\n(SELECT user_type FROM clout_v1_3.user_security_settings WHERE _user_id = U.id LIMIT 1) AS user_type\nFROM users U \n_ID_CONDITION_ \n_PHRASE_CONDITION_\n_TYPE_CONDITION_\n_ORDER_CONDITION_\n_LIMIT_TEXT_ '),
(348, 'get_user_details_list_network', 'SELECT U.id AS user_id,\r\nIF(D.last_transaction_date IS NOT NULL AND D.last_transaction_date NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_transaction_date), '' '') AS last_import,\r\nIF(D.date_joined IS NOT NULL AND D.date_joined NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.date_joined),'' '') AS last_join,\r\nIF(D.last_commission_pay_date IS NOT NULL AND D.last_commission_pay_date NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_commission_pay_date), '' '') AS last_commission,\r\nD.total_imported_contacts,\r\nD.total_network_referrals AS total_network, \r\nD.commissions_level_1,\r\nD.commissions_level_2, \r\nD.commissions_level_3, \r\nD.commissions_level_4,\r\nD.total_commissions,\r\nD.total_store_favorites,\r\nD.total_store_commissions AS commissions_store,\r\n(SELECT user_type FROM clout_v1_3.user_security_settings WHERE _user_id = U.id LIMIT 1) AS user_type\r\nFROM clout_v1_3.users U \r\nLEFT JOIN clout_v1_3cron.datatable__user_data D ON (U.id=D.user_id)\r\n_ID_CONDITION_ \r\n_PHRASE_CONDITION_\r\n_TYPE_CONDITION_\r\n_ORDER_CONDITION_\r\n_LIMIT_TEXT_ '),
(349, 'get_user_details_list_activity', 'SELECT U.id AS user_id,\nIF(D.date_joined IS NOT NULL AND D.date_joined NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.date_joined), '' '') AS date_joined,\nIF(D.last_login_date IS NOT NULL AND D.last_login_date NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_login_date), '' '') AS last_login, \nIF(D.last_promo_use_date IS NOT NULL AND D.last_promo_use_date NOT LIKE ''%0000%'',  UNIX_TIMESTAMP(D.last_promo_use_date), '' '') AS last_promo_used_on, \nIF(D.last_ticket_on IS NOT NULL AND D.last_ticket_on NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_ticket_on), '' '') AS last_ticket_on, \nD.total_logins, D.total_linked_accounts, \nD.total_linked_banks AS total_linked_institutions, \nD.total_raw_transactions, D.total_checkins, D.total_perks_used, D.total_cashback_used, D.total_reviews, \nD.total_store_favorites, D.total_store_views, D.total_clicks, D.total_searches, \nD.total_locations, D.total_ips, D.total_devices, D.total_open_tickets, D.total_closed_tickets, D.user_status,\n\n(SELECT user_type FROM clout_v1_3.user_security_settings WHERE _user_id = U.id LIMIT 1) AS user_type\nFROM clout_v1_3.users U \nLEFT JOIN clout_v1_3cron.datatable__user_data D ON (U.id=D.user_id)\n_ID_CONDITION_ \n_PHRASE_CONDITION_\n_TYPE_CONDITION_\n_ORDER_CONDITION_\n_LIMIT_TEXT_ '),
(350, 'get_user_details_list_money', 'SELECT U.id AS user_id,\nIF(D.last_transaction_import_date IS NOT NULL AND D.last_transaction_import_date NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_transaction_import_date), '' '') AS last_transaction_date, \nIF(D.last_transfer_out_request IS NOT NULL AND D.last_transfer_out_request NOT LIKE ''%0000%'', UNIX_TIMESTAMP(D.last_transfer_out_request), '' '') AS last_transfer_out_request,\nD.available_balance, D.pending_balance, D.total_withdrawn,  D.funds_expiring_in_30_days, D.funds_expired, D.total_withdraw_fees, D.total_cashback_fees, \nD.total_perks_used, D.total_unmatched_amount, D.total_unmatched_transactions AS total_unmatched, D.total_matched_amount, D.total_matched_transactions AS total_matched, \nD.pending_transfers_out, D.pending_transfers_in, \nD.total_financial_alerts, \n(SELECT user_type FROM clout_v1_3.user_security_settings WHERE _user_id = U.id LIMIT 1) AS user_type\nFROM clout_v1_3.users U \nLEFT JOIN clout_v1_3cron.datatable__user_data D ON (U.id=D.user_id)\n_ID_CONDITION_ \n_PHRASE_CONDITION_\n_TYPE_CONDITION_\n_ORDER_CONDITION_\n_LIMIT_TEXT_ \n'),
(351, 'get_user_details_list_clout_score', 'SELECT U.id AS user_id,\r\nC.total_score AS clout_score, \r\n\r\n(C.facebook_connected_score + C.email_verified_score + C.mobile_verified_score + C.profile_photo_added_score + C.bank_verified_and_active_score + C.credit_verified_and_active_score + C.location_services_activated_score + C.push_notifications_activated_score) AS account_setup_score, \r\n\r\n(C.first_adrelated_payment_success_score + C.member_processed_promo_payment_last7days_score + C.has_answered_survey_in_last90days_score + C.number_of_surveys_answered_in_last90days_score + C.first_payment_success_score + C.member_processed_payment_last7days_score) AS activity_score, \r\n\r\n(C.number_of_direct_referrals_last180days_score + C.number_of_direct_referrals_last360days_score + C.total_direct_referrals_score + C.number_of_network_referrals_last180days_score + \r\nC.number_of_network_referrals_last360days_score + C.total_network_referrals_score) AS referrals_score, \r\n\r\n(C.spending_of_direct_referrals_last180days_score + C.spending_of_direct_referrals_last360days_score + C.total_spending_of_direct_referrals_score + \r\nC.spending_of_network_referrals_last180days_score + C.spending_of_network_referrals_last360days_score + C.total_spending_of_network_referrals_score) AS spending_of_referrals_score, \r\n\r\n(C.spending_last180days_score + C.spending_last360days_score + C.spending_total_score) AS spending_score, \r\n\r\n(C.ad_spending_last180days_score + C.ad_spending_last360days_score + C.ad_spending_total_score) AS ad_spending_score, \r\n\r\n(C.cash_balance_today_score + C.average_cash_balance_last24months_score + C.credit_balance_today_score + C.average_credit_balance_last24months_score + C.has_first_public_checkin_success_score + C.has_public_checkin_last7days_score) AS linked_accounts_score,\r\n \r\nD.spending_last180days, D.spending_last360days, D.spending_total, D.ad_spending_last180days, D.ad_spending_last360days, D.ad_spending_total, \r\n(SELECT user_type FROM clout_v1_3.user_security_settings WHERE _user_id = U.id LIMIT 1) AS user_type\r\nFROM clout_v1_3.users U \r\nLEFT JOIN clout_v1_3cron.datatable__user_data D ON (U.id=D.user_id)\r\nLEFT JOIN clout_v1_3cron.cacheview__clout_score C ON (U.id=C.user_id)\r\n_ID_CONDITION_ \r\n_PHRASE_CONDITION_\r\n_TYPE_CONDITION_\r\n_ORDER_CONDITION_\r\n_LIMIT_TEXT_ \r\n'),
(352, 'get_stores_featured', 'SELECT DISTINCT P.store_id FROM clout_v1_3cron.cacheview__promotions_summary P \r\nWHERE is_boosted=''Y'' AND clout_v1_3.get_distance(''_LATITUDE_'', ''_LONGITUDE_'', P.latitude, P.longitude) < _MAX_DISTANCE_ AND P.store_id NOT IN (''_EXCLUDE_ID_LIST_'')'),
(353, 'get_stores_with_phrase', 'SELECT S.id AS store_id, clout_v1_3.get_distance(''_LATITUDE_'',''_LONGITUDE_'',S.latitude, S.longitude) AS distance  \nFROM stores S WHERE MATCH(name) AGAINST (''+"_PHRASE_"'') AND S.name LIKE "%_PHRASE_%" \nHAVING distance < _MAX_DISTANCE_ _EXCLUDE_CONDITION_\nORDER BY distance\n_LIMIT_TEXT_'),
(354, 'get_referral_level_count_by_id_list', 'SELECT user_id,\nlevel_1, level_2, level_3, level_4,\nIF(level_1, LENGTH(level_1) - LENGTH(REPLACE(level_1, '','', '''')) + 1, 0) AS level_1_count, \nIF(level_2, LENGTH(level_2) - LENGTH(REPLACE(level_2, '','', '''')) + 1, 0) AS level_2_count, \nIF(level_3, LENGTH(level_3) - LENGTH(REPLACE(level_3, '','', '''')) + 1, 0) AS level_3_count, \nIF(level_4, LENGTH(level_4) - LENGTH(REPLACE(level_4, '','', '''')) + 1, 0) AS level_4_count \nFROM clout_v1_3cron.datatable__network_data \nWHERE user_id IN (''_ID_LIST_'')'),
(355, 'get_social_media_facebook_data', 'SELECT M.social_media_id AS media_id, F.email AS email_address, F.first_name, F.last_name, F.name AS full_name, F.age_range, F.gender, F.profile_link, F.timezone_offset, F.photo_url, F.is_silhoutte, M._user_id AS owner_user_id,\nIF(F.birthday LIKE ''%0000%'' OR F.birthday = '''', '' '', UNIX_TIMESTAMP(STR_TO_DATE(F.birthday, ''%m/%d/%Y''))) AS birth_day,\nIF(M.date_entered LIKE ''%0000%'', '' '', UNIX_TIMESTAMP(M.date_entered)) AS date_entered,\nIF(M.last_updated LIKE ''%0000%'', '' '', UNIX_TIMESTAMP(M.last_updated)) AS last_update_date\nFROM clout_v1_3.user_social_media M\nLEFT JOIN clout_v1_3.user_facebook_data F ON (F.facebook_id=M.social_media_id)\n\nWHERE M._user_id=''_USER_ID_'' AND M.social_media_name=''facebook'''),
(356, 'get_promotion_list', 'SELECT\n    id,\n    owner_id,\n    owner_type,\n    promotion_type,\n    IF (start_score < end_score, start_score, end_score) AS score,\n    number_viewed,\n    number_redeemed,\n    new_customers,\n    gross_sales,\n    is_boosted,\n    boost_budget,\n    boost_start_date,\n    boost_end_date,\n    boost_remaining,\n    name,\n    amount,\n    description,\n    status,\n    start_date,\n    end_date,\n    date_entered,\n    _entered_by,\n    last_updated,\n    _last_updated_by,\n    custom_category_id,cash_back_percentage\n FROM clout_v1_3cron.promotions WHERE owner_id=''_OWNER_ID_'' AND owner_type=''_OWNER_TYPE_'' AND (custom_category_id IS NULL OR custom_category_id=0)\n GROUP BY id\n HAVING score>=''_MIN_SCORE_'''),
(357, 'update_promotion_status', 'UPDATE clout_v1_3cron.promotions SET status=''_STATUS_'' WHERE owner_id=''_OWNER_ID_'' AND owner_type=''_OWNER_TYPE_'' AND id=''_PROMOTION_ID_'''),
(358, 'get_custom_category_by_id', 'SELECT * FROM promotions_custom_categories WHERE id=''_ID_'' AND status=''active''\n'),
(359, 'add_custom_category', 'INSERT INTO promotions_custom_categories (user_id, store_owner_id, category_id, sub_category_id, category_label, status, category_type) VALUES (\n''_USER_ID_'', ''_STORE_OWNER_ID_'', ''_CATEGORY_ID_'', ''_SUB_CATEGORY_ID_'',''_CATEGORY_LABEL_'', ''_STATUS_'', ''_CATEGORY_TYPE_''\n)'),
(360, 'add_custom_level', 'INSERT INTO promotions_custom_levels (name, level_id, status, user_id, store_owner_id) VALUES (''_NAME_'', ''_LEVEL_ID_'', ''_STATUS_'', ''_USER_ID_'',''_STORE_OWNER_ID_'')'),
(361, 'get_custom_level_by_id', 'SELECT * FROM promotions_custom_levels WHERE id=''_ID_'' AND status=''active'''),
(362, 'delete_custom_category', 'UPDATE promotions_custom_categories SET status=''deleted'' WHERE id=''_ID_'''),
(363, 'delete_custom_level', 'UPDATE promotions_custom_levels SET status=''deleted'' WHERE id=''_ID_'''),
(364, 'get_custom_categories', 'SELECT * FROM promotions_custom_categories WHERE user_id=''_USER_ID_'' AND store_owner_id IS NULL OR store_owner_id=0 AND status=''active'''),
(366, 'get_custom_categories_with_store', 'SELECT * FROM promotions_custom_categories WHERE user_id=''_USER_ID_'' AND store_owner_id=''_STORE_OWNER_ID_'' AND status=''active'''),
(367, 'add_category_level_connection', 'INSERT INTO promotions_categories_levels (category_id, level_id, amount) VALUES (''_CATEGORY_ID_'',''_LEVEL_ID_'',''_AMOUNT_'')'),
(368, 'get_custom_levels', 'SELECT * FROM promotions_custom_levels WHERE user_id=''_USER_ID_'' AND store_owner_id IS NULL OR store_owner_id=0 AND status=''active'' ORDER BY level_id'),
(369, 'get_custom_levels_with_store', 'SELECT * FROM promotions_custom_levels WHERE user_id=''_USER_ID_'' AND store_owner_id=''_STORE_OWNER_ID_'' AND status=''active'''),
(370, 'get_category_level_connection_by_level', 'SELECT * FROM promotions_categories_levels WHERE level_id=''_LEVEL_ID_'''),
(371, 'get_category_level_connection', 'SELECT * FROM promotions_categories_levels WHERE level_id=''_ID_'''),
(372, 'get_category_level_connection_with_users', 'SELECT connections.id AS id, categories.id AS category_id, levels.id AS level_id, categories.user_id AS category_user_id, levels.user_id AS levels_user_id FROM promotions_categories_levels AS connections\r\nLEFT JOIN promotions_custom_categories AS categories ON categories.id=connections.category_id\r\nLEFT JOIN promotions_custom_levels AS levels ON levels.id=connections.level_id\r\nWHERE connections.id=''_ID_'''),
(373, 'update_value_category_level_connection', 'UPDATE promotions_categories_levels SET amount=''_VALUE_'' WHERE id=''_ID_'''),
(374, 'change_custom_category_name', 'UPDATE promotions_custom_categories SET category_label=''_CATEGORY_LABEL_'' WHERE id=''_ID_'' AND user_id=''_USER_ID_'''),
(375, 'change_custom_level_name', 'UPDATE promotions_custom_levels SET name=''_NAME_'' WHERE id=''_ID_'' AND user_id=''_USER_ID_'''),
(376, 'get_promotions_by_level', 'SELECT * FROM clout_v1_3cron.promotions\nLEFT JOIN promotions_custom_categories AS categories ON categories.id=clout_v1_3cron.promotions.custom_category_id\nLEFT JOIN promotions_categories_levels AS connections ON categories.id=connections.category_id\nWHERE clout_v1_3cron.promotions.custom_category_id IS NOT NULL AND clout_v1_3cron.promotions.custom_category_id!=0 AND connections.level_id=''_LEVEL_ID_''\nAND clout_v1_3cron.promotions.owner_id=''_OWNER_ID_'' AND clout_v1_3cron.promotions.owner_type=''_OWNER_TYPE_''\nAND clout_v1_3cron.promotions.amount>=connections.amount'),
(377, 'get_categories_level_2_by_parent', 'SELECT * FROM categories_level_2 WHERE _category_id=''_CATEGORY_ID_'''),
(378, 'get_store_competitors', 'SELECT * FROM store_competitors WHERE _store_id=''_STORE_ID_'''),
(380, 'get_store_sub_categories', 'SELECT * FROM store_sub_categories WHERE _store_id=''_STORE_ID_'''),
(381, 'get_categories_level_2_by_id', 'SELECT * FROM categories_level_2 WHERE id=''_ID_'''),
(382, 'get_categories_level_1_by_id', 'SELECT * FROM categories_level_1 WHERE id=''_ID_'''),
(383, 'get_custom_category_by_category_id', 'SELECT * FROM promotions_custom_categories WHERE user_id=''_USER_ID_'' AND store_owner_id=''_STORE_OWNER_ID_'' AND category_id=''_CATEGORY_ID_'''),
(384, 'delete_connections_by_level', 'DELETE  FROM promotions_categories_levels WHERE level_id=''_LEVEL_ID_'''),
(385, 'delete_connections_by_category', 'DELETE  FROM promotions_categories_levels WHERE category_id=''_CATEGORY_ID_'''),
(386, 'get_states_by_countries', 'SELECT*FROM states WHERE _country_code IN (_CODE_)'),
(387, 'get_cities_by_countries', 'SELECT*FROM cities WHERE _country_code IN (_CODE_)'),
(388, 'add_promotion', 'INSERT INTO clout_v1_3cron.promotions (promotion_type, owner_id, start_date, end_date, start_score, end_score, amount, _entered_by, name, description, custom_category_id, cash_back_percentage) VALUES (''_PROMOTION_TYPE_'', ''_OWNER_ID_'', ''_START_DATE_'', ''_END_DATE_'',  ''_START_SCORE_'', ''_END_SCORE_'', ''_AMOUNT_'', ''_ENTERED_BY_'', ''_NAME_'', ''_DESCRIPTION_'',''_CATEGORY_ID_'',''_CASH_BACK_PERCENTAGE_'')'),
(389, 'get_promotion_by_id', 'SELECT  id,\n						    owner_id,\n						    owner_type,\n						    promotion_type,\n						    IF (start_score < end_score, start_score, end_score) AS score,\n						    number_viewed,\n						    number_redeemed,\n						    new_customers,\n						    gross_sales,\n						    is_boosted,\n						    boost_budget,\n						    boost_start_date,\n						    boost_end_date,\n						    boost_remaining,\n						    name,\n						    amount,\n						    description,\n						    status,\n						    start_date,\n						    end_date,\n						    date_entered,\n						    _entered_by,\n						    last_updated,\n						    _last_updated_by,\n						    custom_category_id,cash_back_percentage FROM clout_v1_3cron.promotions WHERE id=''_ID_'''),
(391, 'update_promotion', 'UPDATE clout_v1_3cron.promotions SET start_date=''_START_DATE_'', end_date=''_END_DATE_'', start_score=''_START_SCORE_'', end_score=''_END_SCORE_'', amount=''_AMOUNT_'', name=''_NAME_'', cash_back_percentage=''_CASH_BACK_PERCENTAGE_'' WHERE id=''_ID_'''),
(392, 'get_stores_by_name', 'SELECT * FROM stores WHERE name LIKE ''%_STORE_NAME_%'' OR address_line_1 LIKE ''%_STORE_NAME_%'''),
(393, 'get_stores_by_cities', 'SELECT * FROM stores WHERE _WHERE_'),
(394, 'get_level_by_id', 'SELECT * FROM promotions_custom_levels WHERE id=''_ID_'''),
(395, 'get_category_with_subcategory', 'SELECT * FROM promotions_custom_categories WHERE _WHERE_'),
(397, 'check_duplicat_promotion', 'SELECT * FROM clout_v1_3cron.promotions WHERE owner_id=''_OWNER_ID_'' and promotion_type=''_PROMOTION_TYPE_'' and start_score=''_START_SCORE_'' and end_score=''_END_SCORE_'' and name=''_NAME_'' and start_date = ''_START_DATE_'' and end_date = ''_END_DATE_'' and cash_back_percentage = ''_CASH_BACK_PERCENTAGE_'''),
(398, 'get_customer_list', ' SELECT _user.id as user_id, CONCAT(_user.first_name, '' '',_user.last_name)as name,\n score(_user.id) as score,\n in_store_spending (_user.id) as in_store_spending,\n competitor_spending(_user.id) as competitor_spending,category_spending(_user.id) as category_spending,\n related_spending(_user.id) as related_spending,\n (SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,\n datatab_user_data.total_linked_accounts as linked_accounts,\n last_activity_ed(_user.id) as activity,\n _user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, ''%Y-%m-%d''))/365, ''.'', 1)   AS age,\n p_custom_cat.category_label as custom_label,\n s_schedule.special_request as notes,priority(_user.id) as priority,\n (SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,\n(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,\nget_upcoming_date(_user.id,g_tracking.latitude,g_tracking.longitude) as upcoming,\n_DISTANCE_                                                          \nDATE_FORMAT(s_schedule.schedule_date,''%r'') as time,\npromotion.promotion_type as type,\ns_schedule.number_in_party as size,\nc_transaction.status,active(_user.id) as action,\nother_reser_ed(_user.id) as other_reservations,\nCONCAT(g_tracking.tracking_time,''|'',g_tracking.source) as last_checkins,\n(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id  ) as past_checkins,(SELECT sum(clout_v1_3msg.message_invites.number_of_invitations) FROM clout_v1_3msg.message_invites WHERE _user.id = clout_v1_3msg.message_invites._user_id ) as in_network,\n(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,\n(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id ) as reviews,\n(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id ) as favorited,\n(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = ''accepted'') as network_size,\ns_schedule.reservation_status as reservation,\ns_schedule.schedule_date,\n_user.address_line_1 as store_address,\n_user.country_code as store_country,\n_user.city as store_city,\n_user.photo_url,\n(SELECT sum(clout_v1_3cron.promotions.amount) FROM clout_v1_3cron.promotions where clout_v1_3cron.promotions.owner_id = _user.id and clout_v1_3cron.promotions.owner_type = ''person'') as promo_spending,\nstore_last_transaction_ed(_user.id) as store_last_transaction\n\n\n	 FROM clout_v1_3.users as _user\n	  INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id\n	  LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id\n	  LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = _user.id\n      LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id\n      LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _user.id AND promotion.owner_type=''store''\n      LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._user_id = _user.id\n       _WHERE_ '),
(400, 'all_store_state', 'SELECT clout_v1_3.users.state_id as state_id, clout_v1_3.states.state_name  FROM clout_v1_3.users\n						INNER JOIN clout_v1_3.states ON clout_v1_3.states.id = clout_v1_3.users.state_id\n						where clout_v1_3.users.country_code = ''_COUNTRY_CODE_'' GROUP BY state_id'),
(401, 'get_store_address_by_state_id', 'SELECT clout_v1_3.users.address_line_1 as address,clout_v1_3.states.id as state_id FROM clout_v1_3.users \n        LEFT JOIN clout_v1_3.states ON clout_v1_3.users.state_id = clout_v1_3.states.id WHERE clout_v1_3.users.state_id = ''_STATE_ID_'''),
(405, 'get_all_customer_country', 'SELECT clout_v1_3.countries.code as country_code,clout_v1_3.countries.name as country_name FROM clout_v1_3.countries\n	INNER JOIN clout_v1_3.users ON clout_v1_3.users.country_code = clout_v1_3.countries.code\n    GROUP BY clout_v1_3.countries.code'),
(406, 'all_store_data', 'SELECT * FROM clout_v1_3.stores');

-- --------------------------------------------------------

--
-- Структура таблицы `referrals`
--

CREATE TABLE IF NOT EXISTS `referrals` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_referred_by` bigint(20) DEFAULT NULL,
  `referrer_type` enum('user','agent','chain','store') NOT NULL DEFAULT 'user',
  `total_unclaimed_pay` float NOT NULL,
  `total_available_pay` float NOT NULL,
  `total_cummulative_pay` float NOT NULL,
  `last_claim_date` datetime NOT NULL,
  `last_claimed_amount` float NOT NULL,
  `activation_date` datetime NOT NULL,
  `sent_referral_by` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `referrals`
--

INSERT INTO `referrals` (`id`, `_user_id`, `_referred_by`, `referrer_type`, `total_unclaimed_pay`, `total_available_pay`, `total_cummulative_pay`, `last_claim_date`, `last_claimed_amount`, `activation_date`, `sent_referral_by`) VALUES
(1, 1, 1, 'user', 0, 0, 0, '2015-10-01 00:00:00', 0, '2015-10-01 00:00:00', 'email'),
(2, 13, 23, 'user', 0, 0, 0, '2015-10-01 00:00:00', 0, '2015-10-01 00:00:00', 'email'),
(3, 21, 1, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-17 15:53:42', 'email'),
(4, 21, 1, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-17 16:12:39', 'email'),
(5, 21, 1, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-17 16:13:35', 'email'),
(6, 21, 1, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-17 16:14:39', 'email'),
(8, 76, 21, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2015-12-18 11:14:17', 'email'),
(11, 76, 1, 'user', 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-03-08 15:48:17', 'email'),
(12, 13, 23, '', 0, 0, 0, '0000-00-00 00:00:00', 0, '2016-03-16 16:11:44', 'email');

--
-- Триггеры `referrals`
--
DELIMITER $$
CREATE TRIGGER `triggerdelete__referrals` AFTER DELETE ON `referrals`
 FOR EACH ROW BEGIN
	
	
	IF OLD._referred_by > 0 THEN 
		
		UPDATE clout_v1_3cron.datatable__user_data SET 
			total_direct_referrals = (total_direct_referrals - 1), 
			total_network_referrals = (total_network_referrals - 1)
		WHERE user_id=OLD._referred_by;
		
		IF DATE(OLD.activation_date) >= (NOW() - INTERVAL 180 DAY) THEN 
			UPDATE clout_v1_3cron.datatable__user_data SET 
				number_of_direct_referrals_last180days = (number_of_direct_referrals_last180days - 1), 
				number_of_network_referrals_last180days = (number_of_network_referrals_last180days - 1)
			WHERE user_id=OLD._referred_by;
		END IF;

		IF DATE(OLD.activation_date) >= (NOW() - INTERVAL 360 DAY) THEN 
			UPDATE clout_v1_3cron.datatable__user_data SET 
				number_of_direct_referrals_last360days = (number_of_direct_referrals_last360days - 1), 
				number_of_network_referrals_last360days = (number_of_network_referrals_last360days - 1)
			WHERE user_id=OLD._referred_by;
		END IF;




		
		UPDATE clout_v1_3cron.datatable__network_data 
		SET	level_1 = 	IF(level_1 LIKE CONCAT(OLD._user_id,',%'), REPLACE(level_1, CONCAT(OLD._user_id,','), ''), 
						IF(level_1 LIKE CONCAT('%,',OLD._user_id,',%'), REPLACE(level_1, CONCAT(',',OLD._user_id,','), ''),
						IF(level_1 LIKE CONCAT('%,',OLD._user_id), REPLACE(level_1, CONCAT(',',OLD._user_id), ''), 
						level_1
					)))
		WHERE user_id=OLD._referred_by;

		UPDATE clout_v1_3cron.datatable__network_data A, (SELECT R0._user_id FROM referrals R0 
				WHERE R0._referred_by=OLD._user_id AND R0._user_id > 0) B
		SET	level_2 = 	IF(level_2 LIKE CONCAT(B._user_id,',%'), REPLACE(level_2, CONCAT(B._user_id,','), ''), 
						IF(level_2 LIKE CONCAT('%,',B._user_id,',%'), REPLACE(level_2, CONCAT(',',B._user_id,','), ''),
						IF(level_2 LIKE CONCAT('%,',B._user_id), REPLACE(level_2, CONCAT(',',B._user_id), ''), 
						level_2
					)))
		WHERE A.user_id=OLD._referred_by;

		UPDATE clout_v1_3cron.datatable__network_data A, (SELECT R1._user_id FROM referrals R0 
				LEFT JOIN referrals R1 ON (R1._referred_by = R0._user_id) 
				WHERE R0._referred_by = OLD._user_id AND R1._user_id > 0) B
		SET	level_3 = 	IF(level_3 LIKE CONCAT(B._user_id,',%'), REPLACE(level_3, CONCAT(B._user_id,','), ''), 
						IF(level_3 LIKE CONCAT('%,',B._user_id,',%'), REPLACE(level_3, CONCAT(',',B._user_id,','), ''),
						IF(level_3 LIKE CONCAT('%,',B._user_id), REPLACE(level_3, CONCAT(',',B._user_id), ''), 
						level_3
					)))
		WHERE A.user_id=OLD._referred_by;

		UPDATE clout_v1_3cron.datatable__network_data A, (SELECT R2._user_id FROM referrals R0 
				LEFT JOIN referrals R1 ON (R1._referred_by = R0._user_id) 
				LEFT JOIN referrals R2 ON (R2._referred_by = R1._user_id) 
				WHERE R0._referred_by = OLD._user_id AND R2._user_id > 0) B
		SET	level_4 = 	IF(level_4 LIKE CONCAT(B._user_id,',%'), REPLACE(level_4, CONCAT(B._user_id,','), ''), 
						IF(level_4 LIKE CONCAT('%,',B._user_id,',%'), REPLACE(level_4, CONCAT(',',B._user_id,','), ''),
						IF(level_4 LIKE CONCAT('%,',B._user_id), REPLACE(level_4, CONCAT(',',B._user_id), ''), 
						level_4
					)))
		WHERE A.user_id=OLD._referred_by;

	END IF;
	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerinsert__referrals` AFTER INSERT ON `referrals`
 FOR EACH ROW BEGIN


	-- get the previous network referral counts
	SELECT number_of_direct_referrals_last180days, number_of_direct_referrals_last360days, total_direct_referrals 
	FROM clout_v1_3cron.datatable__user_data WHERE user_id=NEW._referred_by 
	INTO @number_of_direct_referrals_last180days, @number_of_direct_referrals_last360days, @total_direct_referrals;

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET number_of_direct_referrals_last180days=(number_of_direct_referrals_last180days+1),
		number_of_direct_referrals_last360days=(number_of_direct_referrals_last360days+1), total_direct_referrals=(total_direct_referrals+1),
		last_referral_join_date=NEW.activation_date
	WHERE user_id=NEW._referred_by;

	-- INCREMENT
	INSERT INTO clout_v1_3cron.datatable__frequency_number_of_direct_referrals_last180days (data_value, frequency) 
	(SELECT (@number_of_direct_referrals_last180days+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

	INSERT INTO clout_v1_3cron.datatable__frequency_number_of_direct_referrals_last360days (data_value, frequency) 
	(SELECT (@number_of_direct_referrals_last360days+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

	INSERT INTO clout_v1_3cron.datatable__frequency_total_direct_referrals (data_value, frequency) 
	(SELECT (@total_direct_referrals+1), 1) ON DUPLICATE KEY UPDATE frequency=(frequency+1);

	-- DECREMENT
	UPDATE clout_v1_3cron.datatable__frequency_number_of_direct_referrals_last180days SET frequency=(frequency - 1) WHERE data_value= (@number_of_direct_referrals_last180days - 1);
	UPDATE clout_v1_3cron.datatable__frequency_number_of_direct_referrals_last360days SET frequency=(frequency - 1) WHERE data_value= (@number_of_direct_referrals_last360days - 1);
	UPDATE clout_v1_3cron.datatable__frequency_total_direct_referrals SET frequency=(frequency - 1) WHERE data_value= (@total_direct_referrals - 1);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `referral_url_ids`
--

CREATE TABLE IF NOT EXISTS `referral_url_ids` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `url_id` varchar(300) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_primary` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `referral_url_ids`
--

INSERT INTO `referral_url_ids` (`id`, `_user_id`, `url_id`, `is_active`, `is_primary`, `date_entered`) VALUES
(2, 1, 'CT0000000001', 'Y', 'Y', '2015-10-03 14:49:41'),
(3, 1, 'CT0000000001-E', 'Y', 'N', '2015-10-03 14:49:41'),
(4, 1, 'CT0000000001-L', 'Y', 'N', '2015-10-03 14:55:13'),
(5, 1, 'CT0000000001-C', 'Y', 'N', '2015-10-03 14:55:19'),
(6, 1, 'CT0000000001-Y', 'Y', 'N', '2015-10-03 14:55:24'),
(7, 12, 'CT000000000c', 'Y', 'Y', '2015-12-07 14:22:33'),
(8, 12, 'CT000000000c-C', 'Y', 'N', '2015-12-07 14:22:33'),
(11, 23, 'CT0000000017', 'Y', 'Y', '2016-01-07 19:59:10'),
(12, 23, 'beta4', 'Y', 'N', '2016-01-07 19:59:10'),
(13, 45, 'CT000000002d', 'Y', 'Y', '2016-03-01 13:00:17');

-- --------------------------------------------------------

--
-- Структура таблицы `reviews`
--

CREATE TABLE IF NOT EXISTS `reviews` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `comment` varchar(500) NOT NULL,
  `review_score` int(11) NOT NULL,
  `status` enum('pending','active','archived') NOT NULL DEFAULT 'active',
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `reviews`
--

INSERT INTO `reviews` (`id`, `_user_id`, `_store_id`, `comment`, `review_score`, `status`, `date_entered`, `last_updated`, `_last_updated_by`) VALUES
(9, 1, 1, 'Food is great when you do not swallow.', 3, 'active', '2015-09-28 14:36:41', '2015-09-28 14:36:41', 1),
(10, 2, 15691530, 'I liked this restaurant', 3, 'active', '2015-09-29 16:56:17', '2015-09-29 16:56:17', 1),
(11, 45, 10029873, 'It is a great store.', 3, 'active', '2016-03-01 12:52:54', '2016-03-01 12:52:54', 45),
(12, 0, 865282, 'testing', 2, 'active', '2016-04-25 12:10:16', '2016-04-25 12:10:16', 0);

--
-- Триггеры `reviews`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__reviews` AFTER INSERT ON `reviews`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET total_reviews=(total_reviews+1) WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `share_actions`
--

CREATE TABLE IF NOT EXISTS `share_actions` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `public_button_id` varchar(300) NOT NULL,
  `action` varchar(100) NOT NULL,
  `fields_shared` varchar(500) NOT NULL,
  `browser` varchar(300) NOT NULL,
  `ip_address` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `share_buttons`
--

CREATE TABLE IF NOT EXISTS `share_buttons` (
  `id` bigint(20) NOT NULL,
  `public_id` varchar(300) NOT NULL,
  `notes` text NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `referral_code` varchar(300) NOT NULL,
  `length` varchar(100) NOT NULL,
  `size` varchar(100) NOT NULL,
  `navigation` enum('redirect','popup') NOT NULL DEFAULT 'redirect',
  `website` varchar(500) NOT NULL,
  `redirect_url` varchar(500) NOT NULL,
  `deactivation_reason_code` varchar(300) NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `sic_codes`
--

CREATE TABLE IF NOT EXISTS `sic_codes` (
  `id` bigint(20) NOT NULL,
  `code` varchar(10) NOT NULL,
  `main_category_code` varchar(10) NOT NULL,
  `sub_category_code` varchar(10) NOT NULL,
  `sub_category_code_6` varchar(10) NOT NULL,
  `sub_category_code_8` varchar(10) NOT NULL,
  `code_details` varchar(255) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `sic_codes`
--

INSERT INTO `sic_codes` (`id`, `code`, `main_category_code`, `sub_category_code`, `sub_category_code_6`, `sub_category_code_8`, `code_details`) VALUES
(1, '01', '', '', '', '', 'Agricultural Production - Crops'),
(2, '0111', '01', '0111', '', '', 'Wheat'),
(3, '011100', '01', '0111', '011100', '', 'Wheat'),
(4, '01110000', '01', '0111', '011100', '01110000', 'Wheat'),
(5, '0112', '01', '0112', '', '', 'Rice'),
(6, '011200', '01', '0112', '011200', '', 'Rice'),
(7, '01120000', '01', '0112', '011200', '01120000', 'Rice'),
(8, '0115', '01', '0115', '', '', 'Corn'),
(9, '011500', '01', '0115', '011500', '', 'Corn'),
(10, '01150000', '01', '0115', '011500', '01150000', 'Corn');

-- --------------------------------------------------------

--
-- Структура таблицы `states`
--

CREATE TABLE IF NOT EXISTS `states` (
  `id` bigint(20) NOT NULL,
  `state_code` varchar(10) NOT NULL,
  `state_name` varchar(300) NOT NULL,
  `_country_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `states`
--

INSERT INTO `states` (`id`, `state_code`, `state_name`, `_country_code`) VALUES
(1, 'AL', 'Alabama', 'USA'),
(2, 'AK', 'Alaska', 'USA'),
(3, 'AZ', 'Arizona', 'USA'),
(4, 'AR', 'Arkansas', 'USA'),
(5, 'CA', 'California', 'USA'),
(6, 'CO', 'Colorado', 'USA'),
(7, 'CT', 'Connecticut', 'USA'),
(8, 'DE', 'Delaware', 'USA'),
(9, 'DC', 'District of Columbia', 'USA'),
(10, 'FL', 'Florida', 'USA');

-- --------------------------------------------------------

--
-- Структура таблицы `stores`
--

CREATE TABLE IF NOT EXISTS `stores` (
  `id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `has_multiple_locations` enum('Y','N') NOT NULL DEFAULT 'N',
  `online_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `slogan` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `_country_code` varchar(10) NOT NULL,
  `phone_number` int(11) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `star_rating` int(11) NOT NULL,
  `price_range` int(11) NOT NULL,
  `description` text NOT NULL,
  `public_store_key` text NOT NULL,
  `key_words` text,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores`
--

INSERT INTO `stores` (`id`, `_chain_id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 'IKONDU MEDICAL CENTER - DESMOND IKONDU MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2502 W TRENTON RD', '', 'EDINBURG', 1, 'TX', '78539', 'USA', 2147483647, 1, '', 0, 0, '', 'ikondu-medical-center-desmond-ikondu-md-2502-w-trenton-rd--edinburg-tx-78539-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-98.18303', '26.25544', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(2, 2, 'EWING INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '44 CLINTON ST', '', 'HUDSON', 2, 'OH', '44236', 'USA', 2147483647, 1, '', 0, 0, '', 'ewing-insurance-44-clinton-st--hudson-oh-44236-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-81.44158', '41.24222', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(3, 3, 'NATIONAL INSURANCE CRIME', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '510 THORNALL ST', '', 'EDISON', 3, 'NJ', '08837', 'USA', 2147483647, 1, '', 0, 0, '', 'national-insurance-crime-510-thornall-st--edison-nj-08837-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-74.33839', '40.55822', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(4, 4, 'MEMORIAL HERMANN MEMORIAL CITY - STEPHANIE FREEMAN MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '921 GESSNER RD', '', 'HOUSTON', 3, 'TX', '77024', 'USA', 2147483647, 1, 'WWW.MEMORIALHERMANNHOSPITAL.COM', 0, 0, '', 'memorial-hermann-memorial-city-stephanie-freeman-md-921-gessner-rd--houston-tx-77024-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-95.54449', '29.77935', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(6, 6, 'ST LOUIS UNIVERSITY HOSPITAL - LAURIE E BYRNE MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '3635 VISTA AVE', '', 'SAINT LOUIS', 5, 'MO', '63110', 'AFG', 2147483647, 1, '', 0, 0, '', 'st-louis-university-hospital-laurie-e-byrne-md-3635-vista-ave--saint louis-mo-63110-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-90.2396', '38.62266', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(7, 7, 'MCGRAW INSURANCE SERVICES', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', 'banner_7.png', '', '8185 E KAISER BLVD', '', 'ANAHEIM', 5, 'CA', '92808', 'AFG', 2147483647, 1, '', 0, 0, '', 'mcgraw-insurance-services-8185-e-kaiser-blvd--anaheim-ca-92808-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-117.7449', '33.8659', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(8, 8, 'CAPE FEAR VALLEY MEDICAL CENTER - JASON G COLLINS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1638 OWEN DR', '', 'FAYETTEVILLE', 6, 'NC', '28304', 'USA', 2147483647, 1, '', 0, 0, '', 'cape-fear-valley-medical-center-jason-g-collins-md-1638-owen-dr--fayetteville-nc-28304-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-78.93105', '35.03121', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(9, 9, 'FARM BUREAU INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '334 N STATE ST, STE B', '', 'DESLOGE', 7, 'MO', '63601', 'USA', 2147483647, 1, 'WWW.MOFB.COM', 0, 0, '', 'farm-bureau-insurance-334-n-state-st-ste-b--desloge-mo-63601-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-90.51013', '37.88674', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(10, 10, 'NORTHSHORE UNIVERSITY EVANSTON - BRUCE A HARRIS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2650 RIDGE AVE', '', 'EVANSTON', 8, 'IL', '60201', 'USA', 2147483647, 1, '', 0, 0, '', 'northshore-university-evanston-bruce-a-harris-md-2650-ridge-ave--evanston-il-60201-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-87.68336', '42.06533', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);
INSERT INTO `stores` (`id`, `_chain_id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(11, 11, 'AMERICAN FAMILY INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '5310 WARD RD', '', 'ARVADA', 9, 'CO', '80002', 'USA', 2147483647, 1, '', 0, 0, '', 'american-family-insurance-5310-ward-rd--arvada-co-80002-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-105.1373', '39.79301', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `stores_chain_zero_temp_jc`
--

CREATE TABLE IF NOT EXISTS `stores_chain_zero_temp_jc` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `_chain_id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `has_multiple_locations` enum('Y','N') NOT NULL DEFAULT 'N',
  `online_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `slogan` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `_country_code` varchar(10) NOT NULL,
  `phone_number` int(11) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `star_rating` int(11) NOT NULL,
  `price_range` int(11) NOT NULL,
  `description` text NOT NULL,
  `public_store_key` text NOT NULL,
  `key_words` text,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_chain_zero_temp_jc`
--

INSERT INTO `stores_chain_zero_temp_jc` (`id`, `_chain_id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(16880494, 0, 'WWW FIGANDOLIVE CO', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'WWW FIGANDOLIVE CO=-----', NULL, '', '', 'N', '2016-06-07 19:04:40', 0, '2016-06-07 19:04:40', 0),
(16880495, 0, 'City Of Santa Monic', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '525 Broadway', '', 'Santa Monica', 0, 'CA', '90401', '', 0, 0, '', 0, 0, '', 'City Of Santa Monic=525 Broadway--Santa Monica-CA-90401-', NULL, '', '', 'N', '2016-06-07 19:04:40', 0, '2016-06-07 19:04:40', 0),
(16880496, 0, 'Fandango', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'Fandango=-----', NULL, '', '', 'N', '2016-06-07 19:04:41', 0, '2016-06-07 19:04:41', 0),
(16880497, 0, 'The Room Sushi Bar', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', 'Los Angeles', 0, 'CA', '', '', 0, 0, '', 0, 0, '', 'The Room Sushi Bar=--Los Angeles-CA--', NULL, '', '', 'N', '2016-06-07 19:04:41', 0, '2016-06-07 19:04:41', 0),
(16880498, 0, 'OVERDRAFT PROTECTIO', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'OVERDRAFT PROTECTIO=-----', NULL, '', '', 'N', '2016-06-07 19:18:21', 0, '2016-06-07 19:18:21', 0),
(16880499, 0, 'Monthly Maintenance', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'Monthly Maintenance=-----', NULL, '', '', 'N', '2016-06-07 19:18:20', 0, '2016-06-07 19:18:20', 0),
(16880500, 0, 'Grill House Cafe', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '9494 Black Mountain Rd', '', 'San Diego', 0, 'CA', '92126', '', 0, 0, '', 0, 0, '', 'Grill House Cafe=9494 Black Mountain Rd--San Diego-CA-92126-', NULL, '', '', 'N', '2016-06-07 19:18:21', 0, '2016-06-07 19:18:21', 0),
(16880501, 0, 'Keep the Change', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'Keep the Change=-----', NULL, '', '', 'N', '2016-06-07 19:18:21', 0, '2016-06-07 19:18:21', 0),
(16880502, 0, 'Starbucks', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '716 Freeman Ln', '', 'Grass Valley', 0, 'CA', '95949', '', 0, 0, '', 0, 0, '', 'Starbucks=716 Freeman Ln--Grass Valley-CA-95949-', NULL, '', '', 'N', '2016-06-07 19:18:21', 0, '2016-06-07 19:18:21', 0),
(16880503, 0, 'UBER TECHNOLOGIES I', '0', '2016-06-07', '', 'N', 'N', 'pending', 0, '', '', '', '', '', '', '', 0, '', '', '', 0, 0, '', 0, 0, '', 'UBER TECHNOLOGIES I=-----', NULL, '', '', 'N', '2016-06-07 19:18:21', 0, '2016-06-07 19:18:21', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `stores_dba_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `stores_dba_TEMP_JC` (
  `dba` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `store` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `address` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `city` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `state` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `zip` varchar(255) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Дамп данных таблицы `stores_dba_TEMP_JC`
--

INSERT INTO `stores_dba_TEMP_JC` (`dba`, `store`, `address`, `city`, `state`, `zip`) VALUES
('#06543 ALBERTSONS', '6543', '2400 W. COMMONWEALTH', 'ALHAMBRA', 'CA', '91803'),
('#06704 ALBERTSONS', '6704', '2955 ALPINE BLVD.', 'ALPINE', 'CA', '91901'),
('#06194 ALBERTSONS', '6194', '810 S. STATE COLLEGE', 'ANAHEIM', 'CA', '92806'),
('#06513 ALBERTSONS', '6513', '20261 HWY. 18', 'APPLE VALLEY', 'CA', '92307'),
('#06561 ALBERTSONS', '6561', '298 E. LIVE OAK AVE.', 'ARCADIA', 'CA', '91006'),
('#06304 ALBERTSONS', '6304', '1132 W. BRANCH WAY', 'ARROYO GRAND', 'CA', '93420'),
('#06390 ALBERTSONS', '6390', '8200 EL CAMINO REAL', 'ATASCADERO', 'CA', '93422'),
('#06323 ALBERTSONS', '6323', '3500 PANAMA LN.', 'BAKERSFIELD', 'CA', '93313'),
('#06325 ALBERTSONS', '6325', '7900 WHITE LN.', 'BAKERSFIELD', 'CA', '93309'),
('#06336 ALBERTSONS', '6336', '1520 BRUNDAGE LN.', 'BAKERSFIELD', 'CA', '93304');

-- --------------------------------------------------------

--
-- Структура таблицы `stores_new`
--

CREATE TABLE IF NOT EXISTS `stores_new` (
  `id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `email_address` varchar(300) DEFAULT NULL,
  `has_multiple_locations` enum('Y','N') DEFAULT 'N',
  `online_only` enum('Y','N') DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) DEFAULT NULL,
  `logo_url` varchar(300) DEFAULT NULL,
  `slogan` varchar(300) DEFAULT NULL,
  `small_cover_image` varchar(300) DEFAULT NULL,
  `large_cover_image` varchar(300) DEFAULT NULL,
  `address_line_1` varchar(500) DEFAULT NULL,
  `address_line_2` varchar(500) DEFAULT NULL,
  `city` varchar(300) DEFAULT NULL,
  `_state_id` bigint(20) DEFAULT NULL,
  `state` varchar(10) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `phone_number` varchar(25) NOT NULL,
  `phone_string` varchar(30) DEFAULT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) DEFAULT NULL,
  `star_rating` int(11) DEFAULT NULL,
  `price_range` int(11) DEFAULT NULL,
  `description` text,
  `public_store_key` text,
  `key_words` text,
  `longitude` varchar(10) DEFAULT NULL,
  `latitude` varchar(10) DEFAULT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `stores_new_prd`
--

CREATE TABLE IF NOT EXISTS `stores_new_prd` (
  `id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) DEFAULT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `email_address` varchar(300) DEFAULT NULL,
  `has_multiple_locations` enum('Y','N') DEFAULT 'N',
  `online_only` enum('Y','N') DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) DEFAULT NULL,
  `logo_url` varchar(300) DEFAULT NULL,
  `slogan` varchar(300) DEFAULT NULL,
  `small_cover_image` varchar(300) DEFAULT NULL,
  `large_cover_image` varchar(300) DEFAULT NULL,
  `address_line_1` varchar(500) DEFAULT NULL,
  `address_line_2` varchar(500) DEFAULT NULL,
  `city` varchar(300) DEFAULT NULL,
  `_state_id` bigint(20) DEFAULT NULL,
  `state` varchar(10) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `phone_number` varchar(25) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) DEFAULT NULL,
  `star_rating` int(11) DEFAULT NULL,
  `price_range` int(11) DEFAULT NULL,
  `description` text,
  `public_store_key` text,
  `key_words` text,
  `longitude` varchar(10) DEFAULT NULL,
  `latitude` varchar(10) DEFAULT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `stores_OLD`
--

CREATE TABLE IF NOT EXISTS `stores_OLD` (
  `id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `has_multiple_locations` enum('Y','N') NOT NULL DEFAULT 'N',
  `online_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `slogan` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `_country_code` varchar(10) NOT NULL,
  `phone_number` int(11) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `star_rating` int(11) NOT NULL,
  `price_range` int(11) NOT NULL,
  `description` text NOT NULL,
  `public_store_key` text NOT NULL,
  `key_words` text,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_OLD`
--

INSERT INTO `stores_OLD` (`id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'IKONDU MEDICAL CENTER - DESMOND IKONDU MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2502 W TRENTON RD', '', 'EDINBURG', 44, 'TX', '78539', 'USA', 2147483647, 1, '', 0, 0, '', 'ikondu-medical-center-desmond-ikondu-md-2502-w-trenton-rd--edinburg-tx-78539-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-98.18303', '26.25544', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(2, 'EWING INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '44 CLINTON ST', '', 'HUDSON', 36, 'OH', '44236', 'USA', 2147483647, 1, '', 0, 0, '', 'ewing-insurance-44-clinton-st--hudson-oh-44236-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-81.44158', '41.24222', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(3, 'NATIONAL INSURANCE CRIME', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '510 THORNALL ST', '', 'EDISON', 31, 'NJ', '08837', 'USA', 2147483647, 1, '', 0, 0, '', 'national-insurance-crime-510-thornall-st--edison-nj-08837-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-74.33839', '40.55822', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(4, 'MEMORIAL HERMANN MEMORIAL CITY - STEPHANIE FREEMAN MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '921 GESSNER RD', '', 'HOUSTON', 44, 'TX', '77024', 'USA', 2147483647, 1, 'WWW.MEMORIALHERMANNHOSPITAL.COM', 0, 0, '', 'memorial-hermann-memorial-city-stephanie-freeman-md-921-gessner-rd--houston-tx-77024-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-95.54449', '29.77935', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(6, 'ST LOUIS UNIVERSITY HOSPITAL - LAURIE E BYRNE MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '3635 VISTA AVE', '', 'SAINT LOUIS', 26, 'MO', '63110', 'USA', 2147483647, 1, '', 0, 0, '', 'st-louis-university-hospital-laurie-e-byrne-md-3635-vista-ave--saint louis-mo-63110-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-90.2396', '38.62266', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(7, 'MCGRAW INSURANCE SERVICES', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', 'banner_7.png', '', '8185 E KAISER BLVD', '', 'ANAHEIM', 5, 'CA', '92808', 'USA', 2147483647, 1, '', 0, 0, '', 'mcgraw-insurance-services-8185-e-kaiser-blvd--anaheim-ca-92808-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-117.7449', '33.8659', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(8, 'CAPE FEAR VALLEY MEDICAL CENTER - JASON G COLLINS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1638 OWEN DR', '', 'FAYETTEVILLE', 34, 'NC', '28304', 'USA', 2147483647, 1, '', 0, 0, '', 'cape-fear-valley-medical-center-jason-g-collins-md-1638-owen-dr--fayetteville-nc-28304-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-78.93105', '35.03121', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(9, 'FARM BUREAU INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '334 N STATE ST, STE B', '', 'DESLOGE', 26, 'MO', '63601', 'USA', 2147483647, 1, 'WWW.MOFB.COM', 0, 0, '', 'farm-bureau-insurance-334-n-state-st-ste-b--desloge-mo-63601-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-90.51013', '37.88674', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(10, 'NORTHSHORE UNIVERSITY EVANSTON - BRUCE A HARRIS MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2650 RIDGE AVE', '', 'EVANSTON', 14, 'IL', '60201', 'USA', 2147483647, 1, '', 0, 0, '', 'northshore-university-evanston-bruce-a-harris-md-2650-ridge-ave--evanston-il-60201-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-87.68336', '42.06533', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);
INSERT INTO `stores_OLD` (`id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(11, 'AMERICAN FAMILY INSURANCE', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '5310 WARD RD', '', 'ARVADA', 6, 'CO', '80002', 'USA', 2147483647, 1, '', 0, 0, '', 'american-family-insurance-5310-ward-rd--arvada-co-80002-united-states', 'accident health insurance, accident attorneys, accountants, accountants information referral services, accounting tax consultants, accounting auditing bookkeeping services, administrative governmental law attorneys, adoption attorneys, appeals attorneys, appraisers, arbitration mediation services, arbitration mediation services attorneys, arbitrators, atm locations, attorneys, attorneys information referral services, auto financing loans, auto insurance, auto title loans, bail bonds, bail bondsmen, banking investment law attorneys, bankruptcy attorneys, bankruptcy services, banks, bookkeeping services, business insurance, cash advance loans, certified public accountants, civil law attorneys, collection agencies, commercial savings banks, construction law attorneys, corporate business attorneys, corporate finance securities attorneys, court convention reporters, court reporting, credit debt counseling services, credit card merchant services, credit card plans services, credit reporting agencies consultants, credit unions, creditors rights attorneys, criminal law attorneys, custody support law attorneys, disability law attorneys, discrimination civil rights attorneys, divorce mediation services, divorce attorneys, drug charges attorneys, dui dwi attorneys, elder law attorneys, employment labor law attorneys, environmental natural resources attorneys, escrow services, escrow services, estate appraisal liquidation, estate planning administration, estate planning administration attorneys, family law attorneys, financial brokers, financial counselors, financial management consulting, financial planning consultants services, financial services, financing consultants, foreign currency exchange brokers, franchising, general practice attorneys, group insurance, health insurance, holding companies, homeowners renters insurance, immigration naturalization consultants, immigration law attorneys, income tax consultants, income tax services, insurance, insurance adjusters, insurance agents brokers, insurance annuities, insurance claims services, insurance consultants advisors, insurance law attorneys, intellectual property attorneys, investment advisory services, investment bankers, investment management, investment securities, investment services, investments, investors, law enforcement, legal counsel prosecution, legal forms preparation services, legal service plans, legal services, life insurance, liquidators, loan financing services, malpractice negligence attorneys, medical malpractice attorneys, mergers acquisitions, money orders transfer services, mortgage loan banks, mutual funds brokers, newspaper publishers representatives, patent trademark attorneys, pawn brokers shops, payroll payroll tax preparation services, payroll services systems, pension profit sharing plans, personal financial services, personal financing, personal injury attorneys, personal loans, process service, product liability law attorneys, property casualty insurance, property law attorneys, public accountants, real estate attorneys, real estate investment trusts, real estate loans, retirement planning consultants services, savings loan associations, savings banks, social security attorneys, stock bond brokers, stocks bonds, surety fidelity bonds, tax attorneys, tax consultants, tax return preparation, tax return preparation electronic filing, tax return preparation accountants, taxation monetary policy, traffic law attorneys, trial attorneys, trust companies services, vehicular accident attorneys, venture capital, workers compensation attorneys, wrongful death attorneys,', '-105.1373', '39.79301', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `stores_scraper`
--

CREATE TABLE IF NOT EXISTS `stores_scraper` (
  `id` bigint(20) NOT NULL,
  `name` varchar(500) DEFAULT NULL,
  `clout_id` varchar(100) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `email_address` varchar(300) DEFAULT NULL,
  `has_multiple_locations` enum('Y','N') DEFAULT 'N',
  `online_only` enum('Y','N') DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') DEFAULT 'pending',
  `_store_owner_id` bigint(20) DEFAULT NULL,
  `logo_url` varchar(300) DEFAULT NULL,
  `slogan` varchar(300) DEFAULT NULL,
  `small_cover_image` varchar(300) DEFAULT NULL,
  `large_cover_image` varchar(300) DEFAULT NULL,
  `address_line_1` varchar(500) DEFAULT NULL,
  `address_line_2` varchar(500) DEFAULT NULL,
  `city` varchar(300) DEFAULT NULL,
  `_state_id` bigint(20) DEFAULT NULL,
  `state` varchar(10) DEFAULT NULL,
  `zipcode` varchar(10) DEFAULT NULL,
  `_country_code` varchar(10) DEFAULT NULL,
  `phone_number` int(100) DEFAULT NULL,
  `phone_number2` varchar(100) DEFAULT NULL,
  `_primary_contact_id` bigint(20) DEFAULT NULL,
  `website` varchar(300) DEFAULT NULL,
  `star_rating` int(11) DEFAULT NULL,
  `price_range` int(11) DEFAULT NULL,
  `description` text,
  `public_store_key` text,
  `key_words` text,
  `longitude` varchar(20) DEFAULT NULL,
  `latitude` varchar(20) DEFAULT NULL,
  `is_franchise` enum('Y','N') DEFAULT 'N',
  `date_entered` datetime DEFAULT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime DEFAULT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL,
  `full_address` varchar(150) DEFAULT NULL,
  `category_id` int(20) DEFAULT NULL,
  `category_level_2_id` int(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=74000023 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_scraper`
--

INSERT INTO `stores_scraper` (`id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `phone_number2`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`, `full_address`, `category_id`, `category_level_2_id`) VALUES
(74000006, 'Universal Forest', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '17551 Gothard St', NULL, 'Huntington Beach, ', 5, 'CA', '', 'USA', NULL, '7148477329', 1, NULL, 0, 0, '', 'universal-forest-17551-gothard-st--huntington beach, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 14:35:39', 1, '2016-05-02 14:35:39', 1, '17551 Gothard StHuntington Beach, CA 92647', NULL, NULL),
(74000012, 'Owl Fish', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '11225 Long Beach Blvd', NULL, 'Lynwood, ', 5, 'CA', '', 'USA', NULL, '3107630467', 1, NULL, 0, 0, '', 'owl-fish-11225-long-beach-blvd--lynwood, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 15:45:26', 1, '2016-05-02 15:45:26', 1, '11225 Long Beach BlvdLynwood, CA 90262', NULL, NULL),
(74000013, 'Fishermen''s Spot Fly Fishing', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '14411 Burbank Blvd', NULL, 'Van Nuys, ', 5, 'CA', '', 'USA', NULL, '8187857306', 1, NULL, 0, 0, '', 'fishermen-s-spot-fly-fishing-14411-burbank-blvd--van nuys, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 15:45:26', 1, '2016-05-02 15:45:26', 1, '14411 Burbank BlvdVan Nuys, CA 91401', NULL, NULL),
(74000014, 'Universal Forest', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '17551 Gothard St', NULL, 'Huntington Beach, ', 5, 'CA', '', 'USA', NULL, '7148477329', 1, NULL, 0, 0, '', 'universal-forest-17551-gothard-st--huntington beach, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 15:45:26', 1, '2016-05-02 15:45:26', 1, '17551 Gothard StHuntington Beach, CA 92647', NULL, NULL),
(74000015, 'Actors & Others For Animals', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '11523 Burbank Blvd', NULL, 'North Hollywood, ', 5, 'CA', '', 'USA', NULL, '8187556045', 1, NULL, 0, 0, '', 'actors-others-for-animals-11523-burbank-blvd--north hollywood, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 17:23:41', 1, '2016-05-02 17:23:41', 1, '11523 Burbank BlvdNorth Hollywood, CA 91601', NULL, NULL),
(74000017, 'East Side Smoke Shop', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '3549 E Cesar E Chavez Ave', NULL, 'Los Angeles, ', 5, 'CA', '', 'USA', NULL, '3232640667', 1, NULL, 0, 0, '', 'east-side-smoke-shop-3549-e-cesar-e-chavez-ave--los angeles, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 17:23:44', 1, '2016-05-02 17:23:44', 1, '3549 E Cesar E Chavez AveLos Angeles, CA 90063', NULL, NULL),
(74000019, 'Fishermen''s Spot Fly Fishing', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '14411 Burbank Blvd', NULL, 'Van Nuys, ', 5, 'CA', '', 'USA', NULL, '8187857306', 1, NULL, 0, 0, '', 'fishermen-s-spot-fly-fishing-14411-burbank-blvd--van nuys, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 20:18:56', 1, '2016-05-02 20:18:56', 1, '14411 Burbank BlvdVan Nuys, CA 91401', NULL, NULL),
(74000020, 'Universal Forest', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '17551 Gothard St', NULL, 'Huntington Beach, ', 5, 'CA', '', 'USA', NULL, '7148477329', 1, NULL, 0, 0, '', 'universal-forest-17551-gothard-st--huntington beach, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 20:18:57', 1, '2016-05-02 20:18:57', 1, '17551 Gothard StHuntington Beach, CA 92647', NULL, NULL),
(74000021, 'Crop Production Services', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '1290 N Knollwood Cir', NULL, 'Anaheim, ', 5, 'CA', '', 'USA', NULL, '7148508736', 1, NULL, 0, 0, '', 'crop-production-services-1290-n-knollwood-cir--anaheim, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 20:18:57', 1, '2016-05-02 20:18:57', 1, '1290 N Knollwood CirAnaheim, CA 92801', NULL, NULL),
(74000022, 'Marina Farms', '0', '2016-05-02', '', 'N', 'N', 'active', 0, '', '', '', '', '5454 S Centinela Ave', NULL, 'Los Angeles, ', 5, 'CA', '', 'USA', NULL, '3108273049', 1, NULL, 0, 0, '', 'marina-farms-5454-s-centinela-ave--los angeles, -ca--', NULL, NULL, NULL, 'N', '2016-05-02 20:18:57', 1, '2016-05-02 20:18:57', 1, '5454 S Centinela AveLos Angeles, CA 90066', NULL, NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `stores_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `stores_TEMP_JC` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `_chain_id` bigint(20) NOT NULL,
  `name` varchar(500) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `start_date` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `has_multiple_locations` enum('Y','N') NOT NULL DEFAULT 'N',
  `online_only` enum('Y','N') NOT NULL DEFAULT 'N',
  `status` enum('pending','active','suspended','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_owner_id` bigint(20) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `slogan` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `address_line_1` varchar(500) NOT NULL,
  `address_line_2` varchar(500) NOT NULL,
  `city` varchar(300) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `_country_code` varchar(10) NOT NULL,
  `phone_number` int(11) NOT NULL,
  `_primary_contact_id` bigint(20) NOT NULL,
  `website` varchar(300) NOT NULL,
  `star_rating` int(11) NOT NULL,
  `price_range` int(11) NOT NULL,
  `description` text NOT NULL,
  `public_store_key` text NOT NULL,
  `key_words` text,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `is_franchise` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_TEMP_JC`
--

INSERT INTO `stores_TEMP_JC` (`id`, `_chain_id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(255, 255, 'CENTER FOR BETTER HEARING', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '4350 WADSWORTH BLVD, STE 340', '', 'WHEAT RIDGE', 6, 'CO', '80033', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'center-for-better-hearing-4350-wadsworth-blvd-ste-340--wheat ridge-co-80033-united-states', 'adult entertainment products services, air conditioning dealers, anniversary gifts, archery equipment supplies dealers, athletic dance shoes, atv dealers, auctioneers auction houses, audio equipment supplies dealers, baby products services, bath products, beads retail, big screen televisions, bookstores, candles candle equipment supplies, card shops, children s books, children s parties, chocolate cocoa retail, christmas trees wreaths retail, cigar cigarette tobacco dealers, clock dealers repair, coin stamp dealers supplies, collectible gifts, collectibles dealers, comic books, consignment services shops, consumer electronics stores, convenience stores, cosmetics, crafts craft supplies retail, department stores, disc jockeys, discount furniture stores, discount stores, dolls accessories retail, draperies curtains retail custom, electronic commerce, factory outlets, fertilizers retail, fireplaces accessories retail, flags flagpoles banners pennants, flea markets, floors flooring retail, florists, frozen foods retail, fruits vegetables retail, fuels retail, funeral flowers, furniture accessories, furniture stores, games supplies dealers, general stores, gift baskets packs retail, gift certificates, gift shops, gold silver platinum buyers dealers, gourmet foods retail, guns ammunition dealers, hair braiding, hardware dealers, hats caps retail, hearing aids assistive devices retail, hobby model stores, home decorating supplies accessories, household linens retail, invitations announcements, janitorial equipment supplies retail, jewelers, junk dealers, laundry equipment supplies dealers, leather goods retail, lubricating oils retail, luggage stores, lumber dealers, magazine dealers, mail order catalog sales, mattresses retail, measuring instrument dealers, motorcycle motor scooter minibike parts accessories, musical instrument rental leasing, musical instruments retail, newspapers magazines, office supplies retail, paper dealers distributors, photofinishing retail, photographic equipment supplies retail, pianos organs retail, picture frames retail, pictures prints retail, pipes smoking accessories, plaques retail, plate glass retail, plumbing heating supplies retail, pottery retail, precious metals retail, quilting materials supplies retail, quilts retail, repair shops, resale second hand used merchandise stores, restaurant equipment supplies retail, retail custom blinds, retail nurseries, safes vaults dealers, seasonings retail, sewing machine dealers, shopping centers malls, shopping services, skin care cosmetics, small appliance dealers, souvenir novelty shops, specialty stores, sporting goods dealers, sports cards memorabilia, stationery retail, storage batteries retail, textiles retail, thrift stores, tools retail, toy stores, trading posts, trophy shops, used office furniture equipment, variety stores, video dvd sales rental, video games, washing machines dryers ironers retail, wedding chapels, wedding flowers, wedding gifts favors, wedding planners, wedding receptions parties, window shades equipment supplies, wood wood products, yogurt retail,', '-105.08038', '39.77617', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(588, 255, 'MULTICARE GOOD SAMARITAN HOME', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '3124 S 19TH ST, # 340', '', 'TACOMA', 48, 'WA', '98405', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'multicare-good-samaritan-home-3124-s-19th-st-340--tacoma-wa-98405-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-122.47654', '47.24269', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(643, 255, 'DONELSON PLACE CARE & REHABILITATION', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2733 MCCAMPBELL AVE', '', 'NASHVILLE', 43, 'TN', '37214', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'donelson-place-care-rehabilitation-2733-mccampbell-ave--nashville-tn-37214-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-86.66371', '36.15952', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(849, 255, 'PROGRESSIONAL REHABILITATION', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '403 CENTRAL AVE W', '', 'JAMESTOWN', 43, 'TN', '38556', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'progressional-rehabilitation-403-central-ave-w--jamestown-tn-38556-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-84.94201', '36.43091', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(1120, 255, 'HOLY FAMILY MANOR - HOLY FAMILY ASSISTED LIVING RESIDENTIAL GRACE MANSION TREXLER PAVILION', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1220 PROSPECT AVE', '', 'BETHLEHEM', 39, 'PA', '18018', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'holy-family-manor-holy-family-assisted-living-residential-grace-mansion-trexler-pavilion-1220-prospect-ave--bethlehem-pa-18018-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-75.39981', '40.62071', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(1130, 255, 'COMMONWEALTH HH OF NEPA TYLER', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1 KIM AVE, STE 9', '', 'TUNKHANNOCK', 39, 'PA', '18657', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'commonwealth-hh-of-nepa-tyler-1-kim-ave-ste-9--tunkhannock-pa-18657-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-75.9704', '41.57994', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(1364, 255, 'BALANCE CHIROPRACTIC', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '8355 ELK GROVE BLVD, STE 300', '', 'ELK GROVE', 5, 'CA', '95758', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'balance-chiropractic-8355-elk-grove-blvd-ste-300--elk grove-ca-95758-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-121.39745', '38.40906', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);
INSERT INTO `stores_TEMP_JC` (`id`, `_chain_id`, `name`, `clout_id`, `start_date`, `email_address`, `has_multiple_locations`, `online_only`, `status`, `_store_owner_id`, `logo_url`, `slogan`, `small_cover_image`, `large_cover_image`, `address_line_1`, `address_line_2`, `city`, `_state_id`, `state`, `zipcode`, `_country_code`, `phone_number`, `_primary_contact_id`, `website`, `star_rating`, `price_range`, `description`, `public_store_key`, `key_words`, `longitude`, `latitude`, `is_franchise`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1455, 255, 'MOSAIC COMMUNITY SERVICES INC', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '2121 FREDERICK RD', '', 'CATONSVILLE', 21, 'MD', '21228', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'mosaic-community-services-inc-2121-frederick-rd--catonsville-md-21228-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-76.76331', '39.2656', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(1563, 255, 'HUSSEIN ATIF MD', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1150 N 35TH AVE', '', 'HOLLYWOOD', 10, 'FL', '33021', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'hussein-atif-md-1150-n-35th-ave--hollywood-fl-33021-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-80.17892', '26.02049', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1),
(1577, 255, 'RIPPLE BEHAVIOR SOLUTIONS', '', '0000-00-00', '', 'N', 'N', 'active', 3, '', '', '', '', '1511 N PEACH AVE', '', 'MARSHFIELD', 50, 'WI', '54449', 'USA', 2147483647, 1, 'WWW.SP.BESTFLOWERS.COM', 0, 0, '', 'ripple-behavior-solutions-1511-n-peach-ave--marshfield-wi-54449-united-states', 'abortion alternatives information services, acupuncture acupressure, acupuncture acupressure specialists, acupuncture physicians surgeons, addiction information treatment, aids hiv information referral services, alcohol drug abuse information treatment, allergy immunology physicians surgeons, alternative medicine, alternative medicine practitioners, analytical testing laboratories, anesthesiology physicians, animal health, animal hospitals, artificial nails eyelashes, audiologists, birth control family planning information services, blood banks, blood typing testing, cancer clinics, cancer information referral services, cardiology physicians surgeons, caregivers, cemeteries crematories, cemeteries memorial parks, chiropractic clinics, chiropractic information referral services, chiropractors, clinics, clinics medical centers, contact lenses, cosmetic reconstructive surgeons, cosmetic dentists, craniosacral therapy, cremation services, crisis centers, dental clinics, dental equipment supplies, dental hygienists, dental implants, dental laboratories, dentists, denture service centers, dentures, dermatology physicians surgeons, developmental disabilities information services, dialysis clinics, dietitians, disabilities special needs equipment supplies retail, disabled elderly home health care, drug alcohol detection testing, drug stores pharmacies, drugs medications, elder care, emergency critical care physicians surgeons, emergency ambulance services, emergency services dentists, emergency services veterinarians, endocrinology metabolism physicians surgeons, endodontics dentists, eyeglasses sunglasses goggles, eyewear, family general practice physicians surgeons, family planning, family planning birth control clinics, family practice chiropractors, foot ankle surgeons, forensic testing laboratories, funeral services, gastroenterology physicians surgeons, general anesthesia sedation dentists, general surgeons, geriatric care nursing homes, group medical practice, group practice chiropractors, gynecology obstetrics physicians surgeons, health welfare agencies, health wellness programs, health care consultants, health care management, health care management consultants, health care plans, health care professionals, health care providers, health information referral services, health maintenance organizations, hearing aids assistive devices service repair, hematology physicians surgeons, herbs retail, holistic health practitioners, home care services, home health care agencies, home health care equipment supplies, hospice services, hospital equipment supplies retail, hospitals, hypnotherapy, hypnotherapy psychiatry physicians, independent living services, infectious disease physicians surgeons, intermediate care nursing homes, internal medicine physicians surgeons, laser vision correction, licensed psychologists, marriage family counseling, maxillofacial physicians surgeons, medical dental x ray laboratories, medical surgical emergency services, medical billing services, medical diagnostic clinics, medical diagnostic services, medical equipment supplies rental leasing, medical equipment supplies retail, medical equipment service repair, medical examinations, medical imaging, medical laboratories, medical research development, medical services, medical services organizations, medical spas, medical testing, men s health physicians surgeons, mental health, mental health clinics, mental health counselors, mental health practitioners, midwives, naturopathic clinics, nephrology physicians surgeons, neurology physicians surgeons, non prescription medicines, nurse practitioners, nurses, nurses registered professional rn, nursing convalescent homes, nursing personal care facilities, nutrition consultants, nutritionists, occupational industrial health safety, occupational industrial medicine physicians surgeons, occupational therapy rehabilitation, oncology physicians surgeons, ophthalmology physicians surgeons, optical goods retail, optical goods service repair, opticians, optometrists, oral maxillofacial pathology surgery dentists, oral surgeons, orthodontics dentists, orthopedic appliances retail, orthopedic shoes, orthopedics chiropractors, orthopedics physicians surgeons, osteopathic physicians surgeons, osteoporosis physicians surgeons, otolaryngology physicians surgeons, oxygen equipment supplies, pain management physicians surgeons, paternity testing, pathology physicians surgeons, pediatrics dentists, pediatrics physicians surgeons, pedodontics dentists, periodontics dentists, pharmacists, pharmacy pharmaceutical consultants, physical therapists, physical therapy, physical therapy clinics, physicians surgeons, physicians surgeons information referral services, physicians assistants, podiatry clinics, podiatry information referral services, podiatry physicians surgeons, pre arranged funeral plans, pregnancy counseling information services, prescription services, preventive medicine veterinarians, proctology physicians surgeons, prosthetic artificial limbs, prosthetics, prosthodontics dentists, psychiatric hospitals, psychiatry physicians, psychologists, psychotherapists, pulmonary respiratory physicians surgeons, radiology physicians surgeons, rehabilitation centers, rehabilitation chiropractors, rehabilitation medicine physicians surgeons, rehabilitation services, rheumatology physicians surgeons, sexually transmitted diseases testing treatment, sleep disorders information treatment centers, small animal veterinarians, social human services, speech hearing, speech language pathologists, sports medicine chiropractors, sports medicine physical therapists, sports medicine physicians surgeons, sports medicine podiatry physicians surgeons, stress management counseling, surgery veterinarians, surgical centers, teeth whitening, testing laboratories, therapeutic massage, urology physicians surgeons, vascular medicine physicians surgeons, veterinarians, veterinary information referral services, veterinary laboratories, vitamins food supplements retail, web site design, weight control centers, weight loss control, weight loss control consultants, weight loss control programs, wheelchair lifts scooters, wheelchairs retail, yoga instruction therapy,', '-90.15971', '44.68067', 'N', '2015-07-03 14:08:17', 1, '2015-07-03 14:08:17', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `stores_trans_cat_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `stores_trans_cat_TEMP_JC` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `name` varchar(500) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `sub_categories` varchar(342) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_trans_cat_TEMP_JC`
--

INSERT INTO `stores_trans_cat_TEMP_JC` (`id`, `name`, `longitude`, `latitude`, `sub_categories`) VALUES
(169425, 'RITE AID', '-118.34364', '34.09155', '1064,1065'),
(344269, 'PARADISE COVE BEACH CAFE', '-118.7866', '34.02403', '943'),
(356959, 'LUNA PARK KITCHEN & COCKTAILS', '-118.34394', '34.0628', '922'),
(1244918, 'HILTON LOS ANGELES/UNIVERSAL CITY', '-118.3584', '34.13703', '2115'),
(1980222, 'SUPERCUTS', '-118.39318', '34.05534', '1793'),
(2290294, 'MIRAMONTE RESORT AND SPA- DESTINATION HOTELS & RESORTS', '-116.33093', '33.7201', '2115,2146'),
(3036340, 'CHICK-FIL-A', '-117.98909', '33.72336', '954'),
(3218718, 'SUR RESTAURANT', '-118.38543', '34.08115', '922'),
(3995520, 'WYNN PALMS', '-115.19347', '36.12085', '1834'),
(4145600, 'TEAVANA', '-118.41904', '34.0586', '943,1448');

-- --------------------------------------------------------

--
-- Структура таблицы `stores_trans_cat_TEMP_JC2`
--

CREATE TABLE IF NOT EXISTS `stores_trans_cat_TEMP_JC2` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `name` varchar(500) NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `_state_id` bigint(20) NOT NULL,
  `sub_categories` varchar(342) CHARACTER SET utf8 DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `stores_trans_cat_TEMP_JC2`
--

INSERT INTO `stores_trans_cat_TEMP_JC2` (`id`, `name`, `longitude`, `latitude`, `_state_id`, `sub_categories`) VALUES
(410, 'AMARIN THAI CUISINE', '-122.07873', '37.39437', 5, '1010'),
(509, 'WEST ELM', '-115.08467', '36.02414', 29, '1932'),
(1022, 'STATE FARM', '-90.02497', '29.92615', 19, '1720'),
(4596, 'HOT TOPIC', '-89.37752', '31.32444', 25, '406'),
(5196, 'WALMART', '-118.19172', '33.77293', 5, '965'),
(5418, 'SUBWAY', '-122.3556', '47.32306', 48, '954'),
(5924, 'COST PLUS WORLD MARKET', '-121.76135', '38.54643', 5, '1932'),
(6532, 'MOLLY BROWNS', '-117.89077', '33.65834', 5, '428'),
(14653, 'RITE AID', '-105.08216', '39.68362', 6, '1064,1065'),
(15727, 'TAYLOR EDC', '-97.40989', '30.5735', 44, '491');

-- --------------------------------------------------------

--
-- Структура таблицы `store_chains`
--

CREATE TABLE IF NOT EXISTS `store_chains` (
  `id` bigint(20) NOT NULL,
  `_chain_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=764 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_chains`
--

INSERT INTO `store_chains` (`id`, `_chain_id`, `_store_id`, `date_entered`, `_entered_by`) VALUES
(750, 626, 626, '2015-11-16 11:31:20', 1),
(752, 413, 413, '2015-11-16 11:31:20', 1),
(753, 1113, 1113, '2015-11-16 11:31:20', 1),
(754, 477, 477, '2015-11-16 11:31:20', 1),
(755, 265, 265, '2015-11-16 11:31:20', 1),
(756, 520, 520, '2015-11-16 11:31:20', 1),
(757, 565, 565, '2015-11-16 11:31:20', 1),
(758, 229, 229, '2015-11-16 11:31:20', 1),
(762, 158, 158, '2015-11-16 11:31:20', 1),
(763, 375, 375, '2015-11-16 11:31:20', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `store_competitors`
--

CREATE TABLE IF NOT EXISTS `store_competitors` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `store_name` varchar(500) NOT NULL,
  `competitor_id` bigint(20) NOT NULL,
  `competitor_name` varchar(300) NOT NULL,
  `competitor_type` enum('merchant','store') NOT NULL DEFAULT 'store',
  `competitor_zipcode` varchar(10) NOT NULL,
  `price_level` varchar(10) NOT NULL,
  `address` varchar(300) NOT NULL,
  `separation_distance` float NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_competitors`
--

INSERT INTO `store_competitors` (`id`, `_store_id`, `store_name`, `competitor_id`, `competitor_name`, `competitor_type`, `competitor_zipcode`, `price_level`, `address`, `separation_distance`) VALUES
(1, 4, 'AMARIN THAI CUISINE', 2, 'AMARIN THAI CUISINE', 'store', '94041', 'price_lev', '174 CASTRO ST', 0),
(2, 4, 'AMARIN THAI CUISINE', 3, 'RUBY THAI KITCHEN', 'store', '95050', 'price_lev', '2855, STEVENS CREEK BLVD', 8.56225),
(3, 4, 'AMARIN THAI CUISINE', 5, 'DUSITA THAI CUISINE', 'store', '95050', 'price_lev', '2325 EL CAMINO REAL, STE 104', 6.84595),
(4, 4, 'AMARIN THAI CUISINE', 6, 'KARAKADE THAI CUISINE', 'store', '94061', 'price_lev', '593 WOODSIDE RD, # G', 9.49887),
(5, 4, 'AMARIN THAI CUISINE', 7, 'THAI RESTAURANT', 'store', '94306', 'price_lev', '3924 EL CAMINO REAL', 3.134),
(6, 4, 'AMARIN THAI CUISINE', 8, 'BUA THAI CUISINE', 'store', '95035', 'price_lev', '209 S MAIN ST', 9.73098),
(7, 4, 'AMARIN THAI CUISINE', 9, 'SIAM THAI CUISINE', 'store', '95129', 'price_lev', '1080 S DE ANZA BLVD, STE A', 6.55471),
(8, 4, 'AMARIN THAI CUISINE', 13638341, 'BARN THAI RESTAURANT', 'store', '94085', 'price_lev', '921 E DUANE AVE', 4.10849),
(9, 4, 'AMARIN THAI CUISINE', 13950831, 'PATTAYA THAI CUISINE', 'store', '94306', 'price_lev', '4329 EL CAMINO REAL', 2.34854),
(10, 4, 'AMARIN THAI CUISINE', 15302123, 'RICE THAI CUISINE', 'store', '94306', 'price_lev', '3924 EL CAMINO REAL', 3.134);

-- --------------------------------------------------------

--
-- Структура таблицы `store_competitors_dev`
--

CREATE TABLE IF NOT EXISTS `store_competitors_dev` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `store_name` varchar(500) NOT NULL,
  `competitor_id` bigint(20) NOT NULL,
  `competitor_name` varchar(300) NOT NULL,
  `competitor_type` enum('merchant','store') NOT NULL DEFAULT 'store',
  `competitor_zipcode` varchar(10) NOT NULL,
  `price_level` varchar(10) NOT NULL,
  `address` varchar(300) NOT NULL,
  `separation_distance` float NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_competitors_dev`
--

INSERT INTO `store_competitors_dev` (`id`, `_store_id`, `store_name`, `competitor_id`, `competitor_name`, `competitor_type`, `competitor_zipcode`, `price_level`, `address`, `separation_distance`) VALUES
(1, 169425, 'RITE AID', 140678, 'RITE AID', 'store', '90004', 'price_lev', '226 N LARCHMONT BLVD', 1.62413),
(2, 169425, 'RITE AID', 146197, 'RITE AID', 'store', '91604', 'price_lev', '10989 VENTURA BLVD', 3.63854),
(3, 169425, 'RITE AID', 147814, 'RITE AID', 'store', '90013', 'price_lev', '500 S BROADWAY', 6.10751),
(4, 169425, 'RITE AID', 149654, 'RITE AID', 'store', '90291', 'price_lev', '888 LINCOLN BLVD', 9.33708),
(5, 169425, 'RITE AID', 161200, 'RITE AID', 'store', '90029', 'price_lev', '4633 SANTA MONICA BLVD', 3.06389),
(6, 169425, 'RITE AID', 166426, 'RITE AID', 'store', '90042', 'price_lev', '6305 YORK BLVD', 9.35845),
(7, 169425, 'RITE AID', 169249, 'RITE AID', 'store', '90024', 'price_lev', '1001 GLENDON AVE', 6.15012),
(8, 169425, 'RITE AID', 169425, 'RITE AID', 'store', '90038', 'price_lev', '1130 N LA BREA AVE', 0),
(9, 169425, 'RITE AID', 189560, 'RITE AID', 'store', '90034', 'price_lev', '9864 NATIONAL BLVD', 5.40752),
(10, 169425, 'RITE AID', 192335, 'RITE AID', 'store', '90028', 'price_lev', '6726 W SUNSET BLVD', 0.559947);

-- --------------------------------------------------------

--
-- Структура таблицы `store_favorites`
--

CREATE TABLE IF NOT EXISTS `store_favorites` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_favorites`
--

INSERT INTO `store_favorites` (`id`, `_user_id`, `_store_id`, `date_entered`) VALUES
(6, 1, 1, '2015-09-23 12:44:31'),
(8, 0, 38512, '2015-09-23 12:57:23'),
(10, 2, 67, '2015-09-23 13:02:08'),
(11, 3, 13882675, '2015-09-23 18:51:02'),
(12, 4, 15691530, '2015-09-29 16:52:35'),
(14, 5, 15820, '2015-10-07 17:56:45'),
(15, 6, 10029873, '2015-10-21 11:39:24'),
(16, 7, 9133910, '2015-12-07 11:53:40'),
(17, 8, 1, '2016-03-30 20:23:21'),
(18, 9, 1000, '2016-03-31 20:05:07');

--
-- Триггеры `store_favorites`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__store_favorites` AFTER INSERT ON `store_favorites`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET total_store_favorites=(total_store_favorites+1) WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `store_features`
--

CREATE TABLE IF NOT EXISTS `store_features` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `feature` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `store_hours`
--

CREATE TABLE IF NOT EXISTS `store_hours` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `week_day` varchar(100) NOT NULL,
  `start_hour` varchar(10) NOT NULL,
  `end_hour` varchar(10) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1769583 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_hours`
--

INSERT INTO `store_hours` (`id`, `_store_id`, `week_day`, `start_hour`, `end_hour`) VALUES
(1769573, 377, 'monday', 'any', 'any'),
(1769574, 377, 'tuesday', 'any', 'any'),
(1769575, 377, 'wednesday', 'any', 'any'),
(1769576, 377, 'thursday', 'any', 'any'),
(1769577, 377, 'friday', 'any', 'any'),
(1769578, 377, 'saturday', 'any', 'any'),
(1769579, 377, 'sunday', 'any', 'any'),
(1769580, 1012, 'monday', 'any', 'any'),
(1769581, 1012, 'tuesday', 'any', 'any'),
(1769582, 1012, 'wednesday', 'any', 'any');

-- --------------------------------------------------------

--
-- Структура таблицы `store_hours_new`
--

CREATE TABLE IF NOT EXISTS `store_hours_new` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `week_day` varchar(100) NOT NULL,
  `start_hour` varchar(10) NOT NULL,
  `end_hour` varchar(10) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=1769583 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_hours_new`
--

INSERT INTO `store_hours_new` (`id`, `_store_id`, `week_day`, `start_hour`, `end_hour`) VALUES
(1769573, 377, 'monday', 'any', 'any'),
(1769574, 377, 'tuesday', 'any', 'any'),
(1769575, 377, 'wednesday', 'any', 'any'),
(1769576, 377, 'thursday', 'any', 'any'),
(1769577, 377, 'friday', 'any', 'any'),
(1769578, 377, 'saturday', 'any', 'any'),
(1769579, 377, 'sunday', 'any', 'any'),
(1769580, 1012, 'monday', 'any', 'any'),
(1769581, 1012, 'tuesday', 'any', 'any'),
(1769582, 1012, 'wednesday', 'any', 'any');

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
(8326, 'reject', '', '..* atm ..* withdraw..*', '', ''),
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
-- Структура таблицы `store_offer_requests`
--

CREATE TABLE IF NOT EXISTS `store_offer_requests` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `wants_cashback` enum('Y','N') NOT NULL DEFAULT 'N',
  `wants_perks` enum('Y','N') NOT NULL DEFAULT 'N',
  `wants_vip` enum('Y','N') NOT NULL DEFAULT 'N',
  `per_visit_spend` float NOT NULL,
  `per_month_spend` float NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_offer_requests`
--

INSERT INTO `store_offer_requests` (`id`, `_user_id`, `_store_id`, `wants_cashback`, `wants_perks`, `wants_vip`, `per_visit_spend`, `per_month_spend`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 221241, 'Y', 'Y', 'N', 100, 3000.5, '2015-10-07 08:49:40', 1, '2015-10-07 08:57:14', 1),
(6, 1, 6895381, 'N', 'N', 'Y', 0, 0, '2015-10-07 14:37:14', 1, '2015-10-07 14:37:14', 1),
(7, 1, 1407238, 'N', 'N', 'Y', 400, 0, '2015-10-08 22:22:32', 1, '2015-10-08 22:26:10', 1),
(9, 1, 170099, 'N', 'N', 'Y', 120, 3000, '2015-10-21 11:37:22', 1, '2015-10-21 11:37:34', 1),
(10, 45, 10029873, 'Y', 'N', 'N', 230, 450, '2016-03-01 12:49:56', 45, '2016-03-01 12:50:11', 45),
(11, 1, 9344915, 'N', 'Y', 'N', 2423, 5454, '2016-03-30 20:59:20', 1, '2016-03-30 20:59:49', 1),
(12, 0, 16365959, 'Y', 'Y', 'Y', 0, 0, '2016-03-31 18:24:52', 0, '2016-03-31 18:24:52', 0),
(13, 0, 1000, 'N', 'N', 'Y', 0, 12, '2016-03-31 19:57:01', 0, '2016-03-31 20:28:12', 0),
(14, 13, 865282, 'Y', 'N', 'N', 0, 0, '2016-04-25 11:05:00', 13, '2016-04-25 11:05:00', 13);

-- --------------------------------------------------------

--
-- Структура таблицы `store_owners`
--

CREATE TABLE IF NOT EXISTS `store_owners` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `parent_id` bigint(20) NOT NULL,
  `is_account_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_ran_first_promo` enum('Y','N') NOT NULL DEFAULT 'N',
  `offers_store_discount` enum('Y','N') NOT NULL DEFAULT 'N',
  `has_processed_first_payment` enum('Y','N') NOT NULL DEFAULT 'N',
  `pos_system_clout_connected` enum('Y','N') NOT NULL DEFAULT 'N',
  `accepts_bonus_cash` enum('Y','N') NOT NULL DEFAULT 'N',
  `owner_score` int(11) NOT NULL,
  `logo_url` varchar(300) NOT NULL,
  `small_cover_image` varchar(300) NOT NULL,
  `large_cover_image` varchar(300) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_owners`
--

INSERT INTO `store_owners` (`id`, `name`, `user_id`, `parent_id`, `is_account_verified`, `has_ran_first_promo`, `offers_store_discount`, `has_processed_first_payment`, `pos_system_clout_connected`, `accepts_bonus_cash`, `owner_score`, `logo_url`, `small_cover_image`, `large_cover_image`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(3, 'NO PARENT', 1, 0, 'N', 'N', 'N', 'N', 'N', 'N', 0, '', '', '', '0000-00-00 00:00:00', 1, '0000-00-00 00:00:00', 1),
(4, 'Clout Admin', 2, 9344915, 'N', 'N', 'N', 'N', 'N', 'N', 0, '', '', '', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL),
(5, 'Clout Admin 2', 3, 16365959, 'N', 'N', 'N', 'N', 'N', 'N', 0, '', '', '', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `store_owner_stores`
--

CREATE TABLE IF NOT EXISTS `store_owner_stores` (
  `id` bigint(20) NOT NULL,
  `_store_owner_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `store_photos`
--

CREATE TABLE IF NOT EXISTS `store_photos` (
  `id` bigint(20) NOT NULL,
  `photo_url` varchar(300) NOT NULL,
  `photo_note` varchar(300) NOT NULL,
  `photo_category` varchar(200) NOT NULL,
  `is_featured` enum('Y','N') NOT NULL DEFAULT 'N',
  `display_order` varchar(10) NOT NULL,
  `status` enum('pending','active','inactive','deleted') NOT NULL DEFAULT 'pending',
  `_store_id` bigint(20) DEFAULT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_photos`
--

INSERT INTO `store_photos` (`id`, `photo_url`, `photo_note`, `photo_category`, `is_featured`, `display_order`, `status`, `_store_id`, `date_entered`, `_entered_by`) VALUES
(1, 'store_1443551618.jpg', '', 'store_photo', 'N', '', 'active', 15693715, '2015-09-29 11:33:34', 1),
(2, 'store_1443551778.jpg', 'A nice phone for you.', 'store_photo', 'N', '', 'active', 15693715, '2015-09-29 11:36:14', 1),
(3, 'store_1443553174.jpg', 'A water faucet', 'store_photo', 'N', '', 'active', 15693715, '2015-09-29 11:59:30', 1),
(4, 'store_1443553694.jpg', 'Just a Faucet', 'store_photo', 'N', '', 'active', 6536039, '2015-09-29 12:08:09', 1),
(5, 'store_1443553709.jpg', 'Just a Phone', 'store_photo', 'N', '', 'active', 6536039, '2015-09-29 12:08:25', 1),
(6, 'store_1443570825.jpg', 'Great phone', 'store_photo', 'N', '', 'active', 15691530, '2015-09-29 16:53:41', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `store_products_or_services`
--

CREATE TABLE IF NOT EXISTS `store_products_or_services` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `no_of_purchases` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6094766 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_products_or_services`
--

INSERT INTO `store_products_or_services` (`id`, `_store_id`, `name`, `no_of_purchases`) VALUES
(6094756, 13, 'PAIN MANAGEMENT', 0),
(6094757, 19, 'PRESCRIPTION SERVICES', 0),
(6094758, 19, 'ONLINE & IN-STORE PHOTO PROCESSING', 0),
(6094759, 29, 'AEROBICS', 0),
(6094760, 29, 'COORDINATION', 0),
(6094761, 29, 'CARDIO', 0),
(6094762, 29, 'BALANCE', 0),
(6094763, 29, 'BALANCE & COORDINATION', 0),
(6094764, 29, 'AEROBICS & CARDIO', 0),
(6094765, 35, 'WOUND CARE', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `store_products_or_services_new`
--

CREATE TABLE IF NOT EXISTS `store_products_or_services_new` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `name` varchar(200) NOT NULL,
  `no_of_purchases` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=6094766 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_products_or_services_new`
--

INSERT INTO `store_products_or_services_new` (`id`, `_store_id`, `name`, `no_of_purchases`) VALUES
(6094756, 13, 'PAIN MANAGEMENT', 0),
(6094757, 19, 'PRESCRIPTION SERVICES', 0),
(6094758, 19, 'ONLINE & IN-STORE PHOTO PROCESSING', 0),
(6094759, 29, 'AEROBICS', 0),
(6094760, 29, 'COORDINATION', 0),
(6094761, 29, 'CARDIO', 0),
(6094762, 29, 'BALANCE', 0),
(6094763, 29, 'BALANCE & COORDINATION', 0),
(6094764, 29, 'AEROBICS & CARDIO', 0),
(6094765, 35, 'WOUND CARE', 0);

-- --------------------------------------------------------

--
-- Структура таблицы `store_sales_channels`
--

CREATE TABLE IF NOT EXISTS `store_sales_channels` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `channel` varchar(100) NOT NULL,
  `how_many` int(11) NOT NULL,
  `percent_of_sales` int(11) NOT NULL,
  `is_confirmed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
  `date_entere` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_schedule`
--

INSERT INTO `store_schedule` (`id`, `_store_id`, `_promotion_id`, `_user_id`, `scheduler_name`, `scheduler_email`, `scheduler_phone`, `telephone_provider_id`, `phone_type`, `schedule_date`, `number_in_party`, `special_request`, `is_schedule_used`, `store_notes`, `is_email_sent`, `is_sms_sent`, `is_voice_sent`, `reservation_status`, `status`, `date_entere`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(0, 10013396, 0, 0, '', '', 0, 0, 'Mobile', '0000-00-00 00:00:00', 0, '', 'N', '', 'N', 'N', 'N', 'active', 'active', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL),
(0, NULL, 0, 0, '', '', 0, 0, 'Mobile', '0000-00-00 00:00:00', 0, 'test', 'N', '', 'N', 'N', 'N', 'active', 'active', '0000-00-00 00:00:00', NULL, '0000-00-00 00:00:00', NULL),
(1, 1, 189, 1, 'sdfsdf', 'boggob@ram.ru', 234534545, 345345, 'Mobile', '2016-08-10 04:39:24', 0, 'ertertret', 'N', 'erter ertert ert', 'N', 'N', 'N', 'active', 'active', '2016-08-30 00:00:00', NULL, '2016-08-10 07:10:19', NULL);

-- --------------------------------------------------------

--
-- Структура таблицы `store_staff`
--

CREATE TABLE IF NOT EXISTS `store_staff` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_staff_user_id` bigint(20) DEFAULT NULL,
  `is_primary_user` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_staff`
--

INSERT INTO `store_staff` (`id`, `_store_id`, `_staff_user_id`, `is_primary_user`, `date_entered`, `_entered_by`) VALUES
(1, 4213014, 1, 'Y', '2015-07-25 00:00:00', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `store_sub_categories`
--

CREATE TABLE IF NOT EXISTS `store_sub_categories` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) DEFAULT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_sub_categories`
--

INSERT INTO `store_sub_categories` (`id`, `_store_id`, `_category_id`, `_sub_category_id`) VALUES
(1, 1, 1, 1),
(2, 2, 1, 2),
(3, 3, 1, 3),
(4, 4, 1, 4),
(5, 5, 1, 5),
(6, 6, 1, 6),
(7, 7, 1, 7),
(8, 8, 1, 8),
(9, 9, 2, NULL),
(10, 10, 1, 9);

-- --------------------------------------------------------

--
-- Структура таблицы `store_sub_categories_new`
--

CREATE TABLE IF NOT EXISTS `store_sub_categories_new` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) DEFAULT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=5128 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_sub_categories_new`
--

INSERT INTO `store_sub_categories_new` (`id`, `_store_id`, `_category_id`, `_sub_category_id`) VALUES
(5100, 14328068, 9, 928),
(5103, 8003, 9, 928),
(5106, 635545, 9, 928),
(5109, 747796, 9, 928),
(5112, 1433015, 9, 928),
(5115, 1497818, 9, 928),
(5118, 1741227, 9, 928),
(5121, 2124337, 9, 928),
(5124, 8559198, 9, 928),
(5127, 2180474, 9, 928);

-- --------------------------------------------------------

--
-- Структура таблицы `store_sub_categories_new_tst`
--

CREATE TABLE IF NOT EXISTS `store_sub_categories_new_tst` (
  `id` bigint(20) NOT NULL DEFAULT '0',
  `_store_id` bigint(20) DEFAULT NULL,
  `_category_id` bigint(20) DEFAULT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_sub_categories_new_tst`
--

INSERT INTO `store_sub_categories_new_tst` (`id`, `_store_id`, `_category_id`, `_sub_category_id`) VALUES
(5100, 14328068, 9, 928),
(0, 14, 13, 1720),
(0, 23, 7, 752),
(0, 32, 11, 1311),
(0, 38, 11, 1360),
(0, 44, 13, 1765);

-- --------------------------------------------------------

--
-- Структура таблицы `store_suggestions`
--

CREATE TABLE IF NOT EXISTS `store_suggestions` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `website` varchar(300) NOT NULL,
  `contact_name` varchar(300) NOT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `contact_email` varchar(300) NOT NULL,
  `address` varchar(300) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `country` varchar(100) NOT NULL,
  `chain_id` bigint(20) NOT NULL,
  `is_live` enum('Y','N') NOT NULL DEFAULT 'N',
  `store_id` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `store_suggestions`
--

INSERT INTO `store_suggestions` (`id`, `name`, `website`, `contact_name`, `contact_phone`, `contact_email`, `address`, `city`, `state`, `zipcode`, `country`, `chain_id`, `is_live`, `store_id`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'Traget Super&#039;s Store', 'www.traget.com', '', '', '', '45 N Green Fella Rd', '', '', '89004', '', 6, 'N', 0, '2015-08-13 10:06:23', 0, '2015-08-15 13:39:34', 1),
(3, 'walmart pharmacy', 'www.walmart.com', '', '', '', '701 W Cesar E Chavez Ave', '', '', '90012', '', 6, 'N', 0, '2015-08-14 12:58:21', 1, '2015-08-18 11:58:10', 0),
(4, 'Calton Incoporated', 'caltonpools.com', '', '', '', '234 China Town Ave', '', '', '19401', '', 0, 'N', 0, '2015-08-14 13:40:45', 1, '0000-00-00 00:00:00', 0),
(5, 'Sera Pharmacies Inc', 'www.serramedicalclinic.com', '', '', '', '8100 Sunland Blvd', '', '', '91351', '', 5, 'N', 0, '2015-08-14 14:08:36', 1, '2015-08-15 13:31:10', 1),
(6, 'Chico Township Inc', 'www.chico.com', '', '', '', '234 Wilshire Blvd', '', '', '90045', '', 9, 'N', 0, '2015-08-17 17:09:43', 1, '2015-08-25 13:37:05', 1),
(7, 'Target', 'WWW.TARGET.COM', '', '', '', '5065 Main St, Ste Target , Trumbull', '', '', '06611', '', 9, 'N', 609536, '2015-08-17 19:41:47', 1, '2015-08-25 13:40:00', 1),
(8, 'Thim Hing Sandwich Shop', '', '', '', '', '11107 Bellaire Blvd , Houston', '', '', '77072', '', 0, 'N', 7966569, '2015-08-18 13:04:08', 1, '2015-08-18 13:04:08', 1),
(9, 'Geico', 'WWW.LOCAL.YP.COM', '', '', '', '14981 Old Hickory Blvd , Nashville', '', '', '37211', '', 0, 'N', 9245696, '2015-08-18 13:10:48', 1, '2015-08-18 13:10:48', 1),
(10, 'Timb Merchandise', '', '', '', '', '778 Nostrand Ave , Brooklyn', '', '', '11216', '', 0, 'N', 15383229, '2015-08-18 13:27:12', 1, '2015-08-18 13:27:12', 1),
(11, '', '', '', '', '', '', '', '', '', '', 0, 'N', 0, '2015-08-19 20:34:40', 1, '2015-08-19 20:34:40', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `superpages_raw`
--

CREATE TABLE IF NOT EXISTS `superpages_raw` (
  `name` varchar(110) COLLATE utf8_bin DEFAULT NULL,
  `category` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `street` varchar(110) COLLATE utf8_bin DEFAULT NULL,
  `city` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `state` varchar(5) COLLATE utf8_bin DEFAULT NULL,
  `zip_code` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `email_address` varchar(65) COLLATE utf8_bin DEFAULT NULL,
  `phone` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `website` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `user_rating` varchar(5) COLLATE utf8_bin DEFAULT NULL,
  `user_rating_count` varchar(5) COLLATE utf8_bin DEFAULT NULL,
  `services` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `slogan` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `payment` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `products` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `brands` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `languages` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `licensed_insured_bonded` varchar(150) COLLATE utf8_bin DEFAULT NULL,
  `additional_info` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `certification_and_affiliations` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `free_consultation` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `description` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `customers_served` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `emergency_service` varchar(125) COLLATE utf8_bin DEFAULT NULL,
  `accepts_insurance` varchar(5) COLLATE utf8_bin DEFAULT NULL,
  `discount` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `minority_female_owned` varchar(60) COLLATE utf8_bin DEFAULT NULL,
  `multiple_locations` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `firm_profile` varchar(210) COLLATE utf8_bin DEFAULT NULL,
  `degree_and_license_number` varchar(160) COLLATE utf8_bin DEFAULT NULL,
  `health_care_profile` varchar(60) COLLATE utf8_bin DEFAULT NULL,
  `practitioners_gender` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `insured` varchar(10) COLLATE utf8_bin DEFAULT NULL,
  `hospital_affiliations` varchar(160) COLLATE utf8_bin DEFAULT NULL,
  `insurance_affiliations` varchar(170) COLLATE utf8_bin DEFAULT NULL,
  `education` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `experience` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `cuisine` varchar(225) COLLATE utf8_bin DEFAULT NULL,
  `price_range` varchar(30) COLLATE utf8_bin DEFAULT NULL,
  `sensitivities` varchar(100) COLLATE utf8_bin DEFAULT NULL,
  `about` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `parking` varchar(60) COLLATE utf8_bin DEFAULT NULL,
  `hours` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `id` int(11) NOT NULL,
  `has_smarty_street_match` bit(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Дамп данных таблицы `superpages_raw`
--

INSERT INTO `superpages_raw` (`name`, `category`, `street`, `city`, `state`, `zip_code`, `email_address`, `phone`, `website`, `user_rating`, `user_rating_count`, `services`, `slogan`, `payment`, `products`, `brands`, `languages`, `licensed_insured_bonded`, `additional_info`, `certification_and_affiliations`, `free_consultation`, `description`, `customers_served`, `emergency_service`, `accepts_insurance`, `discount`, `minority_female_owned`, `multiple_locations`, `firm_profile`, `degree_and_license_number`, `health_care_profile`, `practitioners_gender`, `insured`, `hospital_affiliations`, `insurance_affiliations`, `education`, `experience`, `cuisine`, `price_range`, `sensitivities`, `about`, `parking`, `hours`, `id`, `has_smarty_street_match`) VALUES
('IKONDU MEDICAL CENTER - DESMOND IKONDU MD', 'EMERGENCY & CRITICAL CARE PHYSICIANS & SURGEONS', '2502 W TRENTON RD', 'EDINBURG', 'TX', '78539', '', '9566302119', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 1, b'1'),
('EWING INSURANCE', 'INSURANCE', '44 CLINTON ST', 'HUDSON', 'OH', '44236', '', '3307451824', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 2, b'1'),
('NATIONAL INSURANCE CRIME', 'INSURANCE', '510 THORNALL ST', 'EDISON', 'NJ', '8837', '', '7325162280', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 3, b'1'),
('MEMORIAL HERMANN MEMORIAL CITY - STEPHANIE FREEMAN MD', 'EMERGENCY & CRITICAL CARE PHYSICIANS & SURGEONS', '921 GESSNER RD', 'HOUSTON', 'TX', '77024', '', '7132423000', 'WWW.MEMORIALHERMANNHOSPITAL.COM', '', '', 'PLASTIC SURGERY, INFORMATION, EMPLOYMENT OPPORTUNITIES, HEALTH INFORMATION', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 4, b'1'),
('TURKEN HELEN', 'INSURANCE', '', '', '', '', '', '8457833741', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 5, b'1'),
('ST LOUIS UNIVERSITY HOSPITAL - LAURIE E BYRNE MD', 'EMERGENCY & CRITICAL CARE PHYSICIANS & SURGEONS', '3635 VISTA AVE', 'SAINT LOUIS', 'MO', '63110', '', '3145778000', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 6, b'1'),
('MCGRAW INSURANCE SERVICES', 'INSURANCE', '8185 E KAISER BLVD', 'ANAHEIM', 'CA', '92808', '', '7149399875', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 7, b'1'),
('CAPE FEAR VALLEY MEDICAL CENTER - JASON G COLLINS MD', 'EMERGENCY & CRITICAL CARE PHYSICIANS & SURGEONS', '1638 OWEN DR', 'FAYETTEVILLE', 'NC', '28304', '', '9106096225', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 8, b'1'),
('FARM BUREAU INSURANCE', 'INSURANCE', '334 N STATE ST, STE B', 'DESLOGE', 'MO', '63601', '', '5735181688', 'WWW.MOFB.COM', '', '', '', '', '', '', 'FARMERS INSURANCE GROUP', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 9, b'1'),
('NORTHSHORE UNIVERSITY EVANSTON - BRUCE A HARRIS MD', 'EMERGENCY & CRITICAL CARE PHYSICIANS & SURGEONS', '2650 RIDGE AVE', 'EVANSTON', 'IL', '60201', '', '8475702000', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', 10, b'1');

-- --------------------------------------------------------

--
-- Структура таблицы `surveys`
--

CREATE TABLE IF NOT EXISTS `surveys` (
  `id` bigint(20) NOT NULL,
  `name` varchar(300) NOT NULL,
  `survey_type` enum('system','industry','store','merchant') NOT NULL DEFAULT 'system',
  `_store_id` bigint(20) DEFAULT NULL,
  `total_views` int(11) NOT NULL,
  `total_responses` int(11) NOT NULL,
  `date_created` datetime NOT NULL,
  `_entered_by` bigint(20) DEFAULT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `surveys`
--

INSERT INTO `surveys` (`id`, `name`, `survey_type`, `_store_id`, `total_views`, `total_responses`, `date_created`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, 'Steak Choice', 'store', 344269, 15, 10, '2015-07-09 00:00:00', 1, '2015-07-16 00:00:00', 1),
(2, 'Favorite Presents', 'system', 1650, 1608, 562, '2015-06-24 00:00:00', 1, '2015-07-17 00:00:00', 1),
(3, 'Present Frequency', 'system', 34, 28, 20, '2015-07-12 00:00:00', 1, '2015-07-17 00:00:00', 1);

-- --------------------------------------------------------

--
-- Структура таблицы `survey_answers`
--

CREATE TABLE IF NOT EXISTS `survey_answers` (
  `id` bigint(20) NOT NULL,
  `_question_id` bigint(20) DEFAULT NULL,
  `answer_details` text NOT NULL,
  `answer_order` varchar(10) NOT NULL,
  `image_url` varchar(300) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `survey_answers`
--

INSERT INTO `survey_answers` (`id`, `_question_id`, `answer_details`, `answer_order`, `image_url`) VALUES
(1, 1, 'Medium-rare', '1', ''),
(2, 1, 'Well-done', '2', ''),
(3, 2, 'Rib', '1', ''),
(4, 2, 'Flunk', '2', ''),
(5, 2, 'Chuck', '3', ''),
(6, 2, 'Rump', '4', ''),
(7, 2, 'Sirloin', '5', ''),
(8, 3, 'Dessert', '1', ''),
(9, 3, 'Service', '2', ''),
(10, 4, 'Login', '1', '');

-- --------------------------------------------------------

--
-- Структура таблицы `survey_categories`
--

CREATE TABLE IF NOT EXISTS `survey_categories` (
  `id` bigint(20) NOT NULL,
  `_survey_id` bigint(20) DEFAULT NULL,
  `_sub_category_id` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `survey_categories`
--

INSERT INTO `survey_categories` (`id`, `_survey_id`, `_sub_category_id`) VALUES
(1, 3, 19),
(2, 3, 904),
(3, 2, 939),
(4, 2, 995),
(5, 1, 995),
(6, 1, 998);

-- --------------------------------------------------------

--
-- Структура таблицы `survey_questions`
--

CREATE TABLE IF NOT EXISTS `survey_questions` (
  `id` bigint(20) NOT NULL,
  `_survey_id` bigint(20) DEFAULT NULL,
  `question_details` text NOT NULL,
  `question_order` varchar(10) NOT NULL,
  `image_url` varchar(300) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `survey_questions`
--

INSERT INTO `survey_questions` (`id`, `_survey_id`, `question_details`, `question_order`, `image_url`) VALUES
(1, 1, 'Do you prefer your steak medium-rare or well done?', '1', ''),
(2, 1, 'Which part of beef do you prefer?', '2', ''),
(3, 1, 'Which part of your restaurant experience do you enjoy the most?', '3', ''),
(4, 2, 'Which part of the system would you change?', '1', ''),
(5, 2, 'Where do you normally access Clout?', '2', ''),
(6, 3, 'Which present do you prefer to wrap more?', '1', ''),
(7, 3, 'What color of wrapping paper do you prefer?', '2', ''),
(8, 3, 'How often do you send presents?', '1', ''),
(9, 3, 'Where do you send presents the most?', '2', '');

-- --------------------------------------------------------

--
-- Структура таблицы `survey_responses`
--

CREATE TABLE IF NOT EXISTS `survey_responses` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `_question_id` bigint(20) DEFAULT NULL,
  `_answer_id` bigint(20) DEFAULT NULL,
  `_survey_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `response_details` text NOT NULL,
  `response_date` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `survey_responses`
--

INSERT INTO `survey_responses` (`id`, `_user_id`, `_question_id`, `_answer_id`, `_survey_id`, `_store_id`, `response_details`, `response_date`) VALUES
(1, 1, 1, 2, 0, 0, '', '2015-05-29 18:12:49'),
(2, 1, 2, 7, 0, 0, 'On a good day', '2015-02-20 18:12:49'),
(3, 1, 5, 14, 0, 0, 'When on the move', '2015-06-29 18:12:49'),
(4, 1, 7, 18, 0, 0, 'On Valentines Day', '2015-07-02 18:12:49'),
(7, 12, 8, 1, 1, 13267924, 'NONE', '2016-06-14 00:00:00');

--
-- Триггеры `survey_responses`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__survey_responses` AFTER INSERT ON `survey_responses`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF (SELECT COUNT(*) FROM survey_responses WHERE _user_id=NEW._user_id AND _survey_id=NEW._survey_id LIMIT 2) = 1 THEN 
		UPDATE clout_v1_3cron.datatable__user_data SET number_of_surveys_answered_in_last90days=(number_of_surveys_answered_in_last90days+1)
		WHERE user_id=NEW._user_id;
	END IF;

	UPDATE clout_v1_3cron.datatable__user_data SET has_answered_survey_in_last90days='Y' WHERE user_id=NEW._user_id;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `system_content`
--

CREATE TABLE IF NOT EXISTS `system_content` (
  `id` bigint(20) NOT NULL,
  `content_code` varchar(250) NOT NULL,
  `content_details` text NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `system_content`
--

INSERT INTO `system_content` (`id`, `content_code`, `content_details`, `is_active`, `date_entered`) VALUES
(1, 'clout_score_profile_setup', 'This is determined from your profile setup progress.', 'Y', '2014-03-02 00:00:00'),
(2, 'clout_score_activity', 'This is determined from your activity on the Clout system.', 'Y', '2014-03-02 00:00:00'),
(3, 'clout_score_overall_spending', 'This is determined from your spending at Clout affiliated merchants.', 'Y', '2014-03-03 00:00:00'),
(4, 'clout_score_ad_related_spending', 'This is determined from your spending on transactions originated from advertisements in the Clout system.', 'Y', '2014-03-03 00:00:00'),
(5, 'clout_score_linked_accounts', 'This is determined from linking of your financial accounts to the Clout system for receiving cash back and enable tracking of transactions at Clout affiliated merchants.', 'Y', '2014-03-01 00:00:00'),
(6, 'clout_score_network_size_growth', 'This is determined from your network size and growth rate.', 'Y', '2014-03-03 00:00:00'),
(7, 'clout_score_network_spending', 'This is determined from spending by users in your network.', 'Y', '2014-03-04 00:00:00'),
(8, 'store_score_same_store_spending', 'Is determined from your spending at this store.', 'Y', '2014-05-15 00:00:00'),
(9, 'store_score_competitor_spending', 'Is determined from your spending at this store''s competitors.', 'Y', '2014-05-08 00:00:00'),
(10, 'store_score_category_spending', 'Is determined from your spending in categories where this store offers goods and/or services.', 'Y', '2014-05-21 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `tickets`
--

CREATE TABLE IF NOT EXISTS `tickets` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `ticket_type` varchar(100) NOT NULL,
  `details` text NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `status` enum('pending','assigned','closed','archived') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `transactions_raw_TEMP_JC`
--

CREATE TABLE IF NOT EXISTS `transactions_raw_TEMP_JC` (
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
  `is_saved` enum('Y','N') NOT NULL DEFAULT 'N',
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `is_processed` enum('Y','N') NOT NULL DEFAULT 'N'
) ENGINE=InnoDB AUTO_INCREMENT=29869 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `transactions_raw_TEMP_JC`
--

INSERT INTO `transactions_raw_TEMP_JC` (`id`, `transaction_id`, `transaction_type`, `currency_type`, `institution_transaction_id`, `correct_institution_transaction_id`, `correct_action`, `server_transaction_id`, `check_number`, `reference_number`, `confirmation_number`, `payee_id`, `payee_name`, `extended_payee_name`, `memo`, `type`, `value_type`, `currency_rate`, `original_currency`, `posted_date`, `user_date`, `available_date`, `amount`, `running_balance_amount`, `pending`, `normalized_payee_name`, `merchant`, `sic`, `source`, `category_name`, `context_type`, `schedule_c`, `clout_transaction_id`, `latitude`, `longitude`, `zipcode`, `state`, `city`, `address`, `sub_category_id`, `contact_telephone`, `website`, `confidence_level`, `place_type`, `related_ad_id`, `_user_id`, `_bank_id`, `api_account`, `banking_transaction_type`, `subaccount_fund_type`, `banking_401k_source_type`, `principal_amount`, `interest_amount`, `escrow_total_amount`, `escrow_tax_amount`, `escrow_insurance_amount`, `escrow_pmi_amount`, `escrow_fees_amount`, `escrow_other_amount`, `last_update_date`, `is_saved`, `is_active`, `is_processed`) VALUES
(29859, 'VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn-29859', 'banking', 'USD', 'PLAID-VkbxJoLYmySqEQ8z0Y65soQ94Rz5vDsrEwqdn', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Quaker State Liquor', 'Quaker State Liquor', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '13.4900', '0.0000', 'true', 'Quaker State Liquor', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Shops:Food and Beverage Store:Beer, Wine and Spirits', '', '', '', '34.083872158114', '', '90038', 'CA', 'Los Angeles', '6901 Melrose Ave', '19025004', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29860, 'O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg-29860', 'banking', 'USD', 'PLAID-O1M4v8RYr5UdYxme1ZBAuqBRxbDk7at8bakzg', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Susina Bakery', 'Susina Bakery', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '9.8500', '0.0000', 'true', 'Susina Bakery', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.075737', '', '90036', 'CA', 'Los Angeles', '7122 Beverly Blvd', '13005000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29861, 'MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175-29861', 'banking', 'USD', 'PLAID-MLDbk8MV0rsqx0QgoDrBsbvRVNJywXIM9e175', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Shell', 'Shell', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '28.3600', '0.0000', 'true', 'Shell', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Gas Stations', '', '', '', '34.053445', '', '90035', 'CA', 'Los Angeles', '8500 W Pico Blvd', '22009000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29862, 'EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ-29862', 'banking', 'USD', 'PLAID-EMY4Dn58q1UpOXBymb8YsJ3wxd5g68fpPkYeZ', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Hollywood Juice Bar', 'Hollywood Juice Bar', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '3.0000', '0.0000', 'true', 'Hollywood Juice Bar', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.102108', '', '90028', 'CA', 'Los Angeles', '7021  Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29863, 'RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd-29863', 'banking', 'USD', 'PLAID-RBMKr8pYx6hLYQAgkZ78h0yNeOzp6kIynQzpd', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Palm Thai Restaurant', 'Palm Thai Restaurant', '', 'place', '', '1', '', '2015-11-17 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '26.9500', '0.0000', 'true', 'Palm Thai Restaurant', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.10128', '', '90028', 'CA', 'Los Angeles', '5900 Hollywood Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29864, 'QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J-29864', 'banking', 'USD', 'PLAID-QqM7jbnYawh6Ye5gNy1RukLKOwZpQmSELDn5J', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Subway', 'Subway', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '7.7000', '0.0000', 'true', 'Subway', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.054538', '', '90035', 'CA', 'Los Angeles', '1270 S La Cienega Blvd', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29865, 'n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN-29865', 'banking', 'USD', 'PLAID-n3ZrLmgYdRHOwm5p8gKNSYN7OR1XJvsA3nyYN', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'THE CORNER HOLLYWOOD', 'THE CORNER HOLLYWOOD', '', 'unresolved', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '33.5000', '0.0000', 'true', 'THE CORNER HOLLYWOOD', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', '', '', '', '', '', '', '', 'CA', '', '', '', '', '', 0.2, 'unresolved', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29866, 'pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6-29866', 'banking', 'USD', 'PLAID-pKOV1q9w60TPZOVpK3j6hwjQVmZEOxcJy1VX6', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29867, 'XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK-29867', 'banking', 'USD', 'PLAID-XvboZQ1Y6Bu3ExApBnXkhg7kdoAZqVt4xwpDK', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'Republique', 'Republique', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '42.6200', '0.0000', 'true', 'Republique', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Food and Drink:Restaurants', '', '', '', '34.064152', '', '90036', 'CA', 'Los Angeles', '624 La Brea Ave', '13005000', '', '', 1, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N'),
(29868, 'ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0-29868', 'banking', 'USD', 'PLAID-ND1XA8EOjrSY76XmaVMJi98boZQKe4UROJPg0', '', '', '', '', '', '', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', 'City Center Parking Inc', 'City Center Parking Inc', '', 'place', '', '1', '', '2015-11-16 00:00:00', '0000-00-00 00:00:00', '2015-11-18 17:16:02', '1.5000', '0.0000', 'true', 'City Center Parking Inc', '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', 'plaid', 'Travel:Parking', '', '', '', '34.029965', '', '90007', 'CA', 'Los Angeles', '220 W 21st St', '22013000', '', '', 0.5, 'place', '', 100, 11279, '4MzZ9Dq1OjUN9B4PgA1vU7MJYzKV04T03gpwr', '', '', '', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '0.0000', '2015-11-19 01:16:02', 'Y', 'Y', 'N');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE IF NOT EXISTS `users` (
  `id` bigint(20) NOT NULL,
  `clout_id` varchar(100) NOT NULL,
  `first_name` varchar(300) NOT NULL,
  `middle_name` varchar(200) NOT NULL,
  `last_name` varchar(300) NOT NULL,
  `gender` enum('male','female','unknown') NOT NULL DEFAULT 'unknown',
  `birthday` date NOT NULL,
  `email_address` varchar(300) NOT NULL,
  `telephone` varchar(20) NOT NULL,
  `phone_type` enum('mobile','home','work') NOT NULL DEFAULT 'mobile',
  `email_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `mobile_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `photo_url` varchar(300) NOT NULL,
  `driver_license` varchar(300) NOT NULL,
  `driver_license_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `ssn` varchar(100) NOT NULL,
  `address_verified` enum('Y','N') NOT NULL DEFAULT 'N',
  `address_line_1` varchar(300) NOT NULL,
  `address_line_2` varchar(300) NOT NULL,
  `city` varchar(300) NOT NULL,
  `state` varchar(250) NOT NULL,
  `state_id` bigint(20) NOT NULL,
  `country_code` varchar(10) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `location_services_on` enum('Y','N') NOT NULL DEFAULT 'N',
  `push_notifications_on` enum('Y','N') NOT NULL DEFAULT 'N',
  `sms_notifications_on` enum('Y','N') NOT NULL DEFAULT 'N',
  `made_public_checkin` enum('Y','N') NOT NULL DEFAULT 'N',
  `made_first_payment` enum('Y','N') NOT NULL DEFAULT 'N',
  `made_first_promo_payment` enum('Y','N') DEFAULT 'N',
  `cash_balance` float NOT NULL,
  `credit_balance` float NOT NULL,
  `clout_score` float NOT NULL,
  `default_store_score` float NOT NULL,
  `security_answer` varchar(200) NOT NULL,
  `relationship_status` enum('single','in_a_relationship','engaged','married','complicated','open_relationship','widowed','separated','divorced','civil_union','domestic_partnership','unknown') NOT NULL DEFAULT 'unknown',
  `signed_up_using` varchar(200) NOT NULL,
  `user_status` enum('pending','active','inactive','deleted') NOT NULL DEFAULT 'pending',
  `no_of_linked_accounts` int(11) NOT NULL,
  `password_needs_reset` enum('Y','N') NOT NULL DEFAULT 'N',
  `activation_email_sent` enum('Y','N') NOT NULL DEFAULT 'N',
  `skip_linking_account` enum('Y','N') NOT NULL DEFAULT 'N',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`id`, `clout_id`, `first_name`, `middle_name`, `last_name`, `gender`, `birthday`, `email_address`, `telephone`, `phone_type`, `email_verified`, `mobile_verified`, `photo_url`, `driver_license`, `driver_license_verified`, `ssn`, `address_verified`, `address_line_1`, `address_line_2`, `city`, `state`, `state_id`, `country_code`, `zipcode`, `location_services_on`, `push_notifications_on`, `sms_notifications_on`, `made_public_checkin`, `made_first_payment`, `made_first_promo_payment`, `cash_balance`, `credit_balance`, `clout_score`, `default_store_score`, `security_answer`, `relationship_status`, `signed_up_using`, `user_status`, `no_of_linked_accounts`, `password_needs_reset`, `activation_email_sent`, `skip_linking_account`, `date_entered`, `_entered_by`, `last_updated`, `_last_updated_by`) VALUES
(1, '1452269910-1', 'Clout', '', 'Admin', 'unknown', '1987-07-21', 'admin@clout.com', '1231231234', 'mobile', 'Y', 'N', 'user_1444251123.png', '', 'N', '', 'N', '428 N Orange Dr', '', 'Alaska', 'CA', 2, 'USA', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 23822.3, 6051.16, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-09-08 10:39:00', 0, '0000-00-00 00:00:00', 0),
(2, '1452269910-2', 'Clout', '', 'No-Reply', 'unknown', '0000-00-00', 'noreply@clout.com', '', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-07-24 00:00:00', 1, '2015-07-24 00:00:00', 1),
(12, '1452269910-12', 'Almond', '', 'Zziwa', 'male', '1987-11-18', 'azziwa@gmail.com', '6786442425', 'mobile', 'Y', 'N', '', '', 'N', '', 'N', 'some address', '', '', '', 2, 'USA', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-11-25 15:51:33', 12, '2015-11-25 15:51:34', 12),
(13, '1452269910-13', 'Aloysious', '', 'Zziwa', 'male', '1983-06-21', 'azziwa@gmail.gov', '6786442425', 'mobile', 'Y', 'Y', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 19567, 4551.16, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-11-25 15:55:18', 13, '2016-02-29 20:34:27', 13),
(14, '1452269910-14', 'Almond', '', 'Test 2', 'male', '1984-05-19', 'azziwa@gmail.me', '6786442425', 'mobile', 'Y', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-11-25 16:01:25', 14, '2015-11-25 16:01:25', 14),
(18, '1452269910-18', 'Albright', '', 'Zious', 'male', '1985-11-18', 'al.zziwa@gmail.com', '6786442425', 'mobile', 'Y', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90045', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-12-16 15:35:44', 18, '2015-12-16 15:39:41', 18),
(21, '1452269910-21', 'Jenny', '', 'Craig', 'male', '1985-12-19', 'jenny.c@gmail.com', '6786442425', 'mobile', 'Y', 'Y', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-12-17 15:25:01', 21, '2015-12-17 15:29:40', 21),
(23, '1452269910-23', 'Joseph', '', 'Tinga', 'male', '1987-11-18', 'tinga@gmail.com', '678324452', 'mobile', 'Y', 'Y', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90234', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2015-12-18 11:14:17', 23, '2015-12-18 11:18:27', 23),
(44, '1455822716-44', 'Al', '', 'Zious', 'male', '1985-04-18', 'al.zziwa@wexel.com', '6786442425', 'mobile', 'Y', 'Y', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 29350.4, 6826.74, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2016-02-18 11:11:56', 44, '2016-03-16 16:08:59', 44),
(45, '1456845733-45', 'Aloy', '', 'Zziwa', 'male', '1985-12-19', 'al.zziwa@tech.gov', '6786442425', 'mobile', 'Y', 'Y', '', '', 'N', '', 'N', '', '', '', '', 0, '', '90036', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2016-03-01 07:22:12', 45, '2016-03-01 10:44:03', 45),
(54, '1471589968-54', 'bogdan', '', 'dvinin', 'male', '1987-12-29', 'bog@ram.ru', '3453453453', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23453', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-18 23:59:20', 54, '2016-08-18 23:59:23', 54),
(55, '1471599055-55', 'gfdgdfgdfgdfg', '', 'dfgdfgdfgdfgdfg', 'female', '1987-10-18', 'gggobboggo@ram.ru', '4234234234', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '42342', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 02:30:51', 55, '2016-08-19 02:30:52', 55),
(56, '1471601127-56', 'ertertret', '', 'ertertert', 'female', '1990-11-18', 'fgooo@ram.rtu', '34534534535', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '35345', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:05:22', 56, '2016-08-19 03:05:24', 56),
(57, '1471601376-57', 'rtertert', '', 'ertertertert', 'female', '1986-12-16', 'etertt@rrr.ru', '3453453453', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '34543', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:09:30', 57, '2016-08-19 03:09:32', 57),
(58, '1471601479-58', 'sdfsdfsdf', '', 'sdfsdfsdfsd', 'female', '1986-11-18', 'fsdfsdf@ram.ru', '4534534534', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '34534', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:11:13', 58, '2016-08-19 03:11:15', 58),
(59, '1471601673-59', 'ertertert', '', 'ertertertert', 'female', '1987-12-16', 'boggo@ram.ru', '43534534355', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '34534', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:14:28', 59, '2016-08-19 03:14:29', 59),
(60, '1471601848-60', 'dfgdfgdfg', '', 'dfgdfgdfg', 'female', '1988-11-16', 'boggoo@ram.ru', '2342342342', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '32423', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:17:23', 60, '2016-08-19 03:17:25', 60),
(61, '1471602346-61', 'aaaaaaaaaaaa', '', 'abbbbbbbbbbbbb', 'male', '1986-10-30', 'fffobnbono@ram.ru', '3343242342', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23423', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:25:40', 61, '2016-08-19 03:25:42', 61),
(62, '1471602508-62', 'dfsdfsdf', '', 'sdfsdfsdf', 'female', '1986-11-17', 'ggobgo@ram.ru', '3453453453', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '34534', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 03:28:23', 62, '2016-08-19 03:28:25', 62),
(73, '1471605881-73', 'dfgdfgdf', '', 'gdfgdfgdg', 'female', '1988-11-16', 'bogdfdf@df.com', '234234234234', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23423', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 04:24:36', 73, '2016-08-19 04:24:37', 73),
(74, '1471606302-74', 'fdgfdgdfg', '', 'dfgdfgdfg', 'male', '1986-11-17', 'bogdandvini@gmail.com', '3423423423', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23432', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 04:31:36', 74, '2016-08-19 04:31:38', 74),
(75, '1471606917-75', 'fsdfsdfsdf', '', 'sdfsdfsdf', 'female', '1986-09-30', 'bog@fdfsdfsdf.ram', '3324234324', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23423', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 04:41:51', 75, '2016-08-19 04:41:53', 75),
(76, '1471607241-76', 'rfgdfgdf', '', 'dfgdfgdfg', 'female', '1988-04-17', 'boggfgdfgo@ram.ru', '2342342342', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '34234', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 04:47:14', 76, '2016-08-19 04:47:17', 76),
(77, '1471607348-77', 'alert&amp;#40;234&amp;#41;', '', 'rwerwerwer', 'female', '1987-03-18', 'bogoo@fsdfds.com', '2334234234', 'mobile', 'N', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '23423', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-19 04:49:01', 77, '2016-08-19 04:49:02', 77),
(89, '1471950235-89', 'perk', '', '4563456455462', 'male', '1988-12-23', '2016-12-23', '4345564564', 'mobile', 'Y', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '12345', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2016-08-23 04:03:51', 89, '2016-08-23 04:03:57', 89),
(90, '1471950618-90', '', '', '', '', '1969-12-31', '', '', 'mobile', '', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'pending', 0, 'N', 'N', 'N', '2016-08-23 04:10:14', 90, '2016-08-23 04:10:15', 90),
(91, '1471950702-91', 'afghsdas', '', 'asfghdasd', 'male', '2015-12-12', 'pulsahhhr557@gmail.com', '123123', 'mobile', 'Y', 'N', '', '', 'N', '', 'N', '', '', '', '', 0, '', '123123', 'N', 'N', 'N', 'N', 'N', 'N', 0, 0, 0, 0, '', 'unknown', '', 'active', 0, 'N', 'N', 'N', '2016-08-23 04:11:39', 91, '2016-08-23 04:11:44', 91);

--
-- Триггеры `users`
--
DELIMITER $$
CREATE TRIGGER `triggerdelete__users` AFTER DELETE ON `users`
 FOR EACH ROW BEGIN
	
	-- update the total user counter
	UPDATE clout_v1_3cron.datatable__system_stats SET code_value = IF((code_value + 0) > 0, (code_value - 1), 0) WHERE statistic_code = 'number_of_users';
	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerinsert__users` AFTER INSERT ON `users`
 FOR EACH ROW BEGIN
	
	-- update total user counter
	UPDATE clout_v1_3cron.datatable__system_stats SET code_value = (code_value+1) WHERE statistic_code = 'number_of_users';

	-- create user data-point cache record
	INSERT IGNORE INTO clout_v1_3cron.datatable__user_data (user_id, email_connected, date_joined, user_status) 
	VALUES (NEW.id, NEW.email_verified, NEW.date_entered, NEW.user_status);
	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerupdate__users` AFTER UPDATE ON `users`
 FOR EACH ROW BEGIN
	
	-- update the user cache with changes on the user record
	UPDATE clout_v1_3cron.datatable__user_data SET email_connected=NEW.email_verified, user_status=NEW.user_status, 
		profile_photo_added=IF(NEW.photo_url <> '','Y','N'), location_services_activated = NEW.location_services_on,
		push_notifications_activated = NEW.push_notifications_on, first_payment_success = NEW.made_first_payment, 
		has_first_public_checkin_success = NEW.made_public_checkin 
	WHERE user_id = OLD.id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_facebook_data`
--

CREATE TABLE IF NOT EXISTS `user_facebook_data` (
  `id` bigint(20) NOT NULL,
  `facebook_id` varchar(200) NOT NULL,
  `email` varchar(300) NOT NULL,
  `name` varchar(500) NOT NULL,
  `first_name` varchar(300) NOT NULL,
  `last_name` varchar(300) NOT NULL,
  `age_range` varchar(100) NOT NULL,
  `gender` varchar(100) NOT NULL,
  `birthday` varchar(100) NOT NULL,
  `profile_link` varchar(500) NOT NULL,
  `timezone_offset` varchar(10) NOT NULL,
  `photo_url` varchar(300) NOT NULL,
  `is_silhoutte` enum('Y','N') NOT NULL DEFAULT 'N',
  `owner_user_id` bigint(20) NOT NULL,
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `user_geo_tracking`
--

CREATE TABLE IF NOT EXISTS `user_geo_tracking` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `tracking_time` datetime NOT NULL,
  `longitude` varchar(10) NOT NULL,
  `latitude` varchar(10) NOT NULL,
  `address` varchar(300) NOT NULL,
  `city` varchar(100) NOT NULL,
  `zipcode` varchar(10) NOT NULL,
  `state` varchar(100) NOT NULL,
  `_checkin_store_id` bigint(20) DEFAULT NULL,
  `_checkin_offer_id` bigint(20) DEFAULT NULL,
  `details` varchar(300) NOT NULL,
  `source` varchar(100) NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_geo_tracking`
--

INSERT INTO `user_geo_tracking` (`id`, `_user_id`, `tracking_time`, `longitude`, `latitude`, `address`, `city`, `zipcode`, `state`, `_checkin_store_id`, `_checkin_offer_id`, `details`, `source`) VALUES
(1, 1, '2015-08-10 10:31:49', '-98.18303', '26.25544', '', 'Los Angeles', '90036', 'California', 1, 13, '', 'checkin'),
(2, 2, '2015-07-22 10:34:22', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(3, 3, '2015-07-22 10:35:08', '-108.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(4, 4, '2015-07-22 10:38:42', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(5, 5, '2015-07-22 10:40:47', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(6, 6, '2015-07-22 10:46:28', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(7, 7, '2015-07-22 10:47:20', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(8, 8, '2015-07-22 10:57:17', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(9, 9, '2015-07-22 10:59:31', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 4213014, 13, '', 'checkin'),
(10, 10, '2015-09-23 13:45:23', '-118.3502', '34.069', '', 'Los Angeles', '90036', 'California', 209670, 0, '', 'checkin');

--
-- Триггеры `user_geo_tracking`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_geo_tracking` AFTER INSERT ON `user_geo_tracking`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.`source`='checkin' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_checkins=(total_checkins+1) WHERE user_id=NEW._user_id;
	END IF;

	UPDATE clout_v1_3cron.datatable__user_data SET total_locations=(total_locations+1), has_public_checkin_last7days='Y' WHERE user_id=NEW._user_id;

	-- update the tracker of the unique locations of this user
	INSERT IGNORE INTO clout_v1_3.user_locations (_user_id, latitude, longitude, ip_address, `source`, device, date_entered) 
	VALUES (NEW._user_id, NEW.latitude, NEW.longitude, '', NEW.`source`, 'other', NEW.tracking_time);

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_locations`
--

CREATE TABLE IF NOT EXISTS `user_locations` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) NOT NULL,
  `latitude` varchar(100) NOT NULL,
  `longitude` varchar(100) NOT NULL,
  `ip_address` varchar(100) NOT NULL,
  `source` varchar(100) NOT NULL,
  `device` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_locations`
--

INSERT INTO `user_locations` (`id`, `_user_id`, `latitude`, `longitude`, `ip_address`, `source`, `device`, `date_entered`) VALUES
(1, 13, '34.0491421', '-118.34013', '', 'checkin', 'other', '2016-06-21 09:52:01'),
(2, 0, '34.0491421', '-118.34013', '', 'checkin', 'other', '2016-06-27 14:42:03'),
(9, 1, '34.0491421', '-118.34013', '', 'checkin', 'other', '2016-06-27 15:10:28');

--
-- Триггеры `user_locations`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_locations` AFTER INSERT ON `user_locations`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.`source`='checkin' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_unique_checkin_locations=(total_unique_checkin_locations+1) WHERE user_id=NEW._user_id;
	END IF;

	IF NEW.ip_address <> '' AND (SELECT id FROM user_locations WHERE ip_address=NEW.ip_address LIMIT 1) IS NULL THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_ips=(total_ips+1) WHERE user_id=NEW._user_id;
	END IF;

	IF NEW.device <> '' AND (SELECT id FROM user_locations WHERE device=NEW.device LIMIT 1) IS NULL THEN
		UPDATE clout_v1_3cron.datatable__user_data SET total_devices=(total_devices+1) WHERE user_id=NEW._user_id;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_search_learned_phrases`
--

CREATE TABLE IF NOT EXISTS `user_search_learned_phrases` (
  `id` bigint(20) NOT NULL,
  `raw_phrase` varchar(300) NOT NULL,
  `learned_phrase` varchar(300) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `user_search_tracking`
--

CREATE TABLE IF NOT EXISTS `user_search_tracking` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `search_type` varchar(100) NOT NULL,
  `phrase` varchar(300) NOT NULL,
  `details` text NOT NULL,
  `location` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Триггеры `user_search_tracking`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_search_tracking` AFTER INSERT ON `user_search_tracking`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET total_searches=(total_searches+1) WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_security_settings`
--

CREATE TABLE IF NOT EXISTS `user_security_settings` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `show_my_full_name_to_stores` enum('Y','N') NOT NULL DEFAULT 'N',
  `show_my_address_to_stores` enum('Y','N') NOT NULL DEFAULT 'N',
  `allow_friends_to_view_my_recent_transactions` enum('Y','N') NOT NULL DEFAULT 'N',
  `allow_friends_to_view_my_full_profile` enum('Y','N') NOT NULL DEFAULT 'N',
  `allow_public_to_view_my_full_profile` enum('Y','N') NOT NULL DEFAULT 'N',
  `only_access_from_phone` enum('Y','N') NOT NULL DEFAULT 'N',
  `only_access_from_web` enum('Y','N') NOT NULL DEFAULT 'N',
  `turn_on_location_tracking` enum('Y','N') NOT NULL DEFAULT 'N',
  `allowed_ips` text NOT NULL,
  `user_type` varchar(100) NOT NULL,
  `user_type_level` varchar(10) NOT NULL,
  `last_login_ip` varchar(100) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_security_settings`
--

INSERT INTO `user_security_settings` (`id`, `_user_id`, `show_my_full_name_to_stores`, `show_my_address_to_stores`, `allow_friends_to_view_my_recent_transactions`, `allow_friends_to_view_my_full_profile`, `allow_public_to_view_my_full_profile`, `only_access_from_phone`, `only_access_from_web`, `turn_on_location_tracking`, `allowed_ips`, `user_type`, `user_type_level`, `last_login_ip`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'clout_owner', 'level 2', '0.0.0.0', '2015-08-07 00:00:00', 1),
(2, 2, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '0.0.0.0', 'clout_admin_user', 'level 1', '0.0.0.0', '2015-08-25 00:00:00', 2),
(12, 12, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2015-11-25 15:51:33', 12),
(13, 13, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'invited_shopper', 'level 1', '', '2016-03-16 16:11:44', 0),
(14, 14, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2015-11-25 16:01:25', 14),
(18, 18, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'store_owner_owner', 'level 1', '', '2016-01-04 11:30:59', 1),
(21, 21, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'invited_shopper', 'level 1', '', '2016-01-08 11:36:37', 1),
(23, 23, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'invited_shopper', 'level 1', '', '2015-12-18 11:19:31', 23),
(34, 44, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-02-18 11:11:56', 44),
(35, 45, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'invited_shopper', 'level 1', '', '2016-03-01 12:19:52', 1),
(36, 50, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-18 22:42:34', 50),
(37, 51, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-18 22:47:09', 51),
(38, 52, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-18 23:27:30', 52),
(39, 53, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-18 23:37:57', 53),
(40, 54, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-18 23:59:25', 54),
(41, 55, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 02:30:54', 55),
(42, 56, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:05:26', 56),
(43, 57, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:09:34', 57),
(44, 58, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:11:17', 58),
(45, 59, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:14:31', 59),
(46, 60, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:17:26', 60),
(47, 61, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:25:44', 61),
(48, 62, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:28:27', 62),
(49, 63, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:47:15', 63),
(50, 68, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 03:59:26', 68),
(51, 69, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:06:19', 69),
(52, 70, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:15:09', 70),
(53, 71, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:18:13', 71),
(54, 72, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:21:14', 72),
(55, 73, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:24:39', 73),
(56, 74, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:31:40', 74),
(57, 75, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:41:55', 75),
(58, 76, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:47:19', 76),
(59, 77, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-19 04:49:05', 77),
(60, 78, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:41:58', 78),
(61, 80, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:46:46', 80),
(62, 82, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:47:26', 82),
(63, 83, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:50:11', 83),
(64, 84, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:52:22', 84),
(65, 86, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:52:50', 86),
(66, 87, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 02:53:25', 87),
(67, 89, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 04:03:54', 89),
(68, 90, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 04:10:16', 90),
(69, 91, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'N', '', 'random_shopper', 'level 1', '', '2016-08-23 04:11:41', 91);

--
-- Триггеры `user_security_settings`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_security_settings` AFTER INSERT ON `user_security_settings`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET user_type=NEW.user_type WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `triggerupdate__user_security_settings` AFTER UPDATE ON `user_security_settings`
 FOR EACH ROW BEGIN

	-- update user cache data
	UPDATE clout_v1_3cron.datatable__user_data SET user_type=NEW.user_type WHERE user_id=NEW._user_id;
	
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Структура таблицы `user_social_media`
--

CREATE TABLE IF NOT EXISTS `user_social_media` (
  `id` bigint(20) NOT NULL,
  `_user_id` bigint(20) DEFAULT NULL,
  `social_media_name` varchar(100) NOT NULL,
  `social_media_id` varchar(300) NOT NULL,
  `access_token` varchar(500) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `number_of_contacts` int(11) NOT NULL,
  `status` enum('pending','verified','deleted') NOT NULL DEFAULT 'pending',
  `last_ip_address` varchar(100) NOT NULL,
  `date_entered` datetime NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) DEFAULT NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1;

--
-- Дамп данных таблицы `user_social_media`
--

INSERT INTO `user_social_media` (`id`, `_user_id`, `social_media_name`, `social_media_id`, `access_token`, `user_name`, `number_of_contacts`, `status`, `last_ip_address`, `date_entered`, `last_updated`, `_last_updated_by`) VALUES
(1, 1, 'facebook', '', 'none', 'none', 130, 'verified', '127.0.0.0', '2015-07-13 00:00:00', '2015-07-13 00:00:00', 1),
(5, 12, 'facebook', '', '', 'azziwa@gmail.com', 0, 'verified', '99.59.233.60', '2015-11-25 15:51:34', '2015-11-25 15:51:34', 12),
(6, 13, 'facebook', '', '', 'azziwa@gmail.gov', 0, 'verified', '99.59.233.60', '2015-11-25 15:55:19', '2015-11-25 15:55:19', 13),
(7, 14, 'facebook', '', '', 'azziwa@gmail.me', 0, 'verified', '99.59.233.60', '2015-11-25 16:01:25', '2015-11-25 16:01:25', 14),
(8, 78, 'facebook', '', '', 'pulghjghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:42:01', '2016-08-23 02:42:01', 78),
(9, 80, 'facebook', '', '', 'pul45tghjghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:46:49', '2016-08-23 02:46:49', 80),
(10, 82, 'facebook', '', '', 'pul45tghjfghghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:47:29', '2016-08-23 02:47:29', 82),
(11, 83, 'facebook', '', '', 'pulf45tghjfghghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:50:14', '2016-08-23 02:50:14', 83),
(12, 84, 'facebook', '', '', 'pulf45tghgjfghghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:52:25', '2016-08-23 02:52:25', 84),
(13, 86, 'facebook', '', '', 'pulfgh45tghgjfghghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:52:53', '2016-08-23 02:52:53', 86),
(14, 87, 'facebook', '', '', 'puglfgh45tghgjfghghjsar557@gmail.com', 0, 'verified', '', '2016-08-23 02:53:28', '2016-08-23 02:53:28', 87),
(15, 89, 'facebook', '', '', '2016-12-23', 0, 'verified', '', '2016-08-23 04:03:58', '2016-08-23 04:03:58', 89),
(16, 91, 'facebook', '', '', 'pulsahhhr557@gmail.com', 0, 'verified', '', '2016-08-23 04:11:45', '2016-08-23 04:11:45', 91);

--
-- Триггеры `user_social_media`
--
DELIMITER $$
CREATE TRIGGER `triggerinsert__user_social_media` AFTER INSERT ON `user_social_media`
 FOR EACH ROW BEGIN

	-- update user cache data
	IF NEW.social_media_name='facebook' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET facebook_connected = 'Y' WHERE user_id=NEW._user_id;
	END IF;

	IF NEW.social_media_name='linkedin' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET linkedin_connected = 'Y' WHERE user_id=NEW._user_id;
	END IF;

	IF NEW.social_media_name='twitter' THEN
		UPDATE clout_v1_3cron.datatable__user_data SET twitter_connected = 'Y' WHERE user_id=NEW._user_id;
	END IF;

END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__default_search_suggestions`
--
CREATE TABLE IF NOT EXISTS `view__default_search_suggestions` (
`user_id` varchar(100)
,`store_id` varchar(100)
,`store_score` double
,`name` varchar(500)
,`longitude` varchar(10)
,`latitude` varchar(10)
,`price_range` int(11)
,`address_line_1` varchar(500)
,`address_line_2` varchar(500)
,`city` varchar(300)
,`state` varchar(10)
,`zipcode` varchar(10)
,`sub_category_tags` text
,`is_favorite` varchar(1)
,`has_perk` varchar(1)
,`max_cashback` double
,`min_cashback` double
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__promotions_summary`
--
CREATE TABLE IF NOT EXISTS `view__promotions_summary` (
`id` bigint(20)
,`owner_id` bigint(20)
,`owner_type` enum('person','store','merchant','system','other')
,`promotion_type` enum('cashback','perk')
,`start_score` float
,`end_score` float
,`number_viewed` int(11)
,`number_redeemed` int(11)
,`new_customers` int(11)
,`gross_sales` float
,`is_boosted` enum('Y','N')
,`boost_budget` float
,`boost_start_date` datetime
,`boost_end_date` datetime
,`boost_remaining` float
,`name` varchar(300)
,`amount` float
,`description` varchar(255)
,`status` enum('active','pending','inactive','deleted')
,`start_date` datetime
,`end_date` datetime
,`date_entered` datetime
,`_entered_by` bigint(20)
,`last_updated` datetime
,`_last_updated_by` bigint(20)
,`advert_id` bigint(20)
,`store_name` varchar(500)
,`logo_url` varchar(300)
,`small_cover_image` varchar(300)
,`large_cover_image` varchar(300)
,`price_range` int(11)
,`latitude` varchar(10)
,`longitude` varchar(10)
,`store_id` bigint(20)
,`sub_category_tags` text
,`category_image` varchar(100)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__search_tracking_by_user_summary`
--
CREATE TABLE IF NOT EXISTS `view__search_tracking_by_user_summary` (
`user_phrase` varchar(300)
,`search_type` varchar(100)
,`_user_id` bigint(20)
,`frequency` bigint(21)
,`date_entered` datetime
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__search_tracking_summary`
--
CREATE TABLE IF NOT EXISTS `view__search_tracking_summary` (
`search_type` varchar(100)
,`user_phrase` varchar(300)
,`frequency` bigint(21)
,`date_entered` datetime
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view__user_details`
--
CREATE TABLE IF NOT EXISTS `view__user_details` (
`user_id` bigint(20)
,`first_name` varchar(300)
,`last_name` varchar(300)
,`email_address` varchar(300)
,`email_verified` enum('Y','N')
,`mobile` varchar(20)
,`mobile_verified` enum('Y','N')
,`gender` enum('male','female','unknown')
,`birthday` date
,`address` text
,`city` varchar(300)
,`state` varchar(250)
,`zipcode` varchar(10)
,`country` varchar(10)
,`photo` varchar(300)
,`driver_license` varchar(300)
,`driver_license_verified` enum('Y','N')
,`ssn` varchar(100)
,`address_verified` enum('Y','N')
,`date_joined` datetime
,`user_status` enum('pending','active','inactive','deleted')
,`facebook_connected` varchar(1)
,`linkedin_connected` varchar(1)
,`twitter_connected` varchar(1)
,`email_connected` varchar(1)
,`last_import` datetime
,`last_join` datetime
,`last_commission` datetime
,`total_imported_contacts` bigint(21)
,`total_network` bigint(24)
,`commissions_level_1` double
,`commissions_level_2` double
,`commissions_level_3` double
,`commissions_level_4` double
,`total_commissions` double
,`total_store_favorites` bigint(21)
,`commissions_store` double
,`last_login` datetime
,`total_logins` bigint(21)
,`last_promo_used_on` datetime
,`last_ticket_on` datetime
,`total_linked_accounts` bigint(21)
,`total_linked_institutions` bigint(21)
,`total_raw_transactions` bigint(21)
,`total_checkins` bigint(21)
,`total_perks_used` bigint(21)
,`total_cashback_used` double
,`total_reviews` bigint(21)
,`total_store_views` bigint(21)
,`total_clicks` bigint(21)
,`total_searches` bigint(21)
,`total_locations` bigint(21)
,`total_ips` bigint(21)
,`total_devices` bigint(21)
,`total_open_tickets` bigint(21)
,`total_closed_tickets` bigint(21)
,`last_transaction_date` datetime
,`last_transfer_out_request` datetime
,`available_balance` double
,`pending_balance` double
,`total_withdrawn` double
,`funds_expiring_in_30_days` double
,`funds_expired` double
,`total_withdraw_fees` double
,`total_cashback_fees` double
,`total_unmatched_amount` double
,`total_unmatched` bigint(21)
,`total_matched_amount` double
,`total_matched` bigint(21)
,`pending_transfers_out` double
,`pending_transfers_in` double
,`total_financial_alerts` bigint(21)
,`user_type` varchar(100)
,`clout_score` double
,`account_setup_score` double
,`activity_score` double
,`referrals_score` double
,`spending_of_referrals_score` double
,`spending_score` double
,`ad_spending_score` double
,`linked_accounts_score` double
,`spending_last180days` decimal(42,4)
,`spending_last360days` decimal(42,4)
,`spending_total` decimal(42,4)
,`ad_spending_last180days` decimal(42,4)
,`ad_spending_last360days` decimal(42,4)
,`ad_spending_total` decimal(42,4)
);

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
-- Дублирующая структура для представления `view__where_user_shopped`
--
CREATE TABLE IF NOT EXISTS `view__where_user_shopped` (
`store_id` bigint(20)
,`user_id` bigint(20)
,`store_score` double
,`frequency` bigint(21)
,`name` varchar(500)
,`zipcode` varchar(10)
);

-- --------------------------------------------------------

--
-- Структура таблицы `vip_levels`
--

CREATE TABLE IF NOT EXISTS `vip_levels` (
  `id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `level_name` varchar(300) NOT NULL,
  `level_description` text NOT NULL,
  `level_title` varchar(100) NOT NULL,
  `level_score` int(11) NOT NULL,
  `level_overall_spending` float NOT NULL,
  `is_active` enum('Y','N') NOT NULL DEFAULT 'Y',
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `vip_level_categories`
--

CREATE TABLE IF NOT EXISTS `vip_level_categories` (
  `id` bigint(20) NOT NULL,
  `category_name` varchar(300) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `category_type` varchar(100) NOT NULL,
  `_vip_level_id` bigint(20) NOT NULL,
  `_store_id` bigint(20) NOT NULL,
  `category_value` varchar(300) NOT NULL,
  `date_entered` datetime NOT NULL,
  `_entered_by` bigint(20) NOT NULL,
  `last_updated` datetime NOT NULL,
  `_last_updated_by` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Структура таблицы `yellowpages_links`
--

CREATE TABLE IF NOT EXISTS `yellowpages_links` (
  `id` bigint(20) NOT NULL,
  `naics_code` varchar(100) DEFAULT NULL,
  `code_details` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `pages` int(20) DEFAULT NULL,
  `category` varchar(200) DEFAULT NULL,
  `link` varchar(200) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

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
-- Структура для представления `view__default_search_suggestions`
--
DROP TABLE IF EXISTS `view__default_search_suggestions`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__default_search_suggestions` AS select `V`.`user_id` AS `user_id`,`V`.`store_id` AS `store_id`,if((`V`.`total_score` > 0),`V`.`total_score`,if((`U`.`default_store_score` > 0),`U`.`default_store_score`,0)) AS `store_score`,`S`.`name` AS `name`,`S`.`longitude` AS `longitude`,`S`.`latitude` AS `latitude`,`S`.`price_range` AS `price_range`,`S`.`address_line_1` AS `address_line_1`,`S`.`address_line_2` AS `address_line_2`,`S`.`city` AS `city`,`S`.`state` AS `state`,`S`.`zipcode` AS `zipcode`,(select if((`SUB`.`_sub_category_id` <> '0'),group_concat(`CAT`.`name` separator ', '),group_concat(`BIZ`.`name` separator ', ')) from ((`store_sub_categories` `SUB` left join `categories_level_2` `CAT` on((`CAT`.`id` = `SUB`.`_sub_category_id`))) left join `categories_level_1` `BIZ` on((`BIZ`.`id` = `SUB`.`_category_id`))) where (`SUB`.`_store_id` = `V`.`store_id`)) AS `sub_category_tags`,if((`F`.`_store_id` is not null),'Y','N') AS `is_favorite`,if(((select count(0) from `clout_v1_3cron`.`cacheview__promotions_summary` `C` where ((`C`.`promotion_type` = 'perk') and (`C`.`store_id` = `V`.`store_id`) and ((`store_score` between `C`.`start_score` and `C`.`end_score`) or ((`store_score` >= 1000) and (`C`.`end_score` = 1000)))) limit 0,1) > 0),'Y','N') AS `has_perk`,(select `C`.`amount` from `clout_v1_3cron`.`cacheview__promotions_summary` `C` where ((`C`.`promotion_type` = 'cash_back') and (`C`.`store_id` = `V`.`store_id`) and ((`store_score` between `C`.`start_score` and `C`.`end_score`) or ((`store_score` >= 1000) and (`C`.`end_score` = 1000)))) order by `C`.`amount` desc limit 0,1) AS `max_cashback`,(select `C`.`amount` from `clout_v1_3cron`.`cacheview__promotions_summary` `C` where ((`C`.`promotion_type` = 'cash_back') and (`C`.`store_id` = `V`.`store_id`) and ((`store_score` between `C`.`start_score` and `C`.`end_score`) or ((`store_score` >= 1000) and (`C`.`end_score` = 1000)))) order by `C`.`amount` limit 0,1) AS `min_cashback` from (((`clout_v1_3cron`.`cacheview__store_score_by_store` `V` left join `stores` `S` on((`V`.`store_id` = `S`.`id`))) left join `users` `U` on((`U`.`id` = `V`.`user_id`))) left join `store_favorites` `F` on(((`F`.`_user_id` = `V`.`user_id`) and (`F`.`_store_id` = `V`.`store_id`)))) where ((`V`.`user_id` <> '') and (`S`.`name` <> '')) group by `V`.`store_id`,`V`.`user_id` order by `V`.`user_id`,(`store_score` + 0) desc,(`max_cashback` + 0) desc,`has_perk` desc;

-- --------------------------------------------------------

--
-- Структура для представления `view__promotions_summary`
--
DROP TABLE IF EXISTS `view__promotions_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__promotions_summary` AS select `P`.`id` AS `id`,`P`.`owner_id` AS `owner_id`,`P`.`owner_type` AS `owner_type`,`P`.`promotion_type` AS `promotion_type`,`P`.`start_score` AS `start_score`,`P`.`end_score` AS `end_score`,`P`.`number_viewed` AS `number_viewed`,`P`.`number_redeemed` AS `number_redeemed`,`P`.`new_customers` AS `new_customers`,`P`.`gross_sales` AS `gross_sales`,`P`.`is_boosted` AS `is_boosted`,`P`.`boost_budget` AS `boost_budget`,`P`.`boost_start_date` AS `boost_start_date`,`P`.`boost_end_date` AS `boost_end_date`,`P`.`boost_remaining` AS `boost_remaining`,`P`.`name` AS `name`,`P`.`amount` AS `amount`,`P`.`description` AS `description`,`P`.`status` AS `status`,`P`.`start_date` AS `start_date`,`P`.`end_date` AS `end_date`,`P`.`date_entered` AS `date_entered`,`P`.`_entered_by` AS `_entered_by`,`P`.`last_updated` AS `last_updated`,`P`.`_last_updated_by` AS `_last_updated_by`,`P`.`id` AS `advert_id`,`S`.`name` AS `store_name`,`S`.`logo_url` AS `logo_url`,`S`.`small_cover_image` AS `small_cover_image`,`S`.`large_cover_image` AS `large_cover_image`,`S`.`price_range` AS `price_range`,`S`.`latitude` AS `latitude`,`S`.`longitude` AS `longitude`,`P`.`owner_id` AS `store_id`,(select if((`SUB`.`_sub_category_id` <> '0'),group_concat(`CAT`.`name` separator ', '),group_concat(`BIZ`.`name` separator ', ')) from ((`store_sub_categories` `SUB` left join `categories_level_2` `CAT` on((`CAT`.`id` = `SUB`.`_sub_category_id`))) left join `categories_level_1` `BIZ` on((`BIZ`.`id` = `SUB`.`_category_id`))) where (`SUB`.`_store_id` = `P`.`owner_id`)) AS `sub_category_tags`,(select `BIZ`.`icon_url` from ((`store_sub_categories` `SUB` left join `categories_level_1` `BIZ` on((`BIZ`.`id` = `SUB`.`_category_id`))) left join `categories_level_2` `CAT` on((`CAT`.`id` = `SUB`.`_sub_category_id`))) where (`SUB`.`_store_id` = `P`.`owner_id`) limit 0,1) AS `category_image` from (`clout_v1_3cron`.`promotions` `P` left join `stores` `S` on((`P`.`owner_id` = `S`.`id`))) where ((`P`.`status` = 'active') and (now() between `P`.`start_date` and `P`.`end_date`) and (((`P`.`amount` > 0) and (`P`.`promotion_type` = 'cash_back')) or (`P`.`promotion_type` <> 'cash_back'))) order by (`P`.`end_score` + 0) desc,(`P`.`amount` + 0) desc;

-- --------------------------------------------------------

--
-- Структура для представления `view__search_tracking_by_user_summary`
--
DROP TABLE IF EXISTS `view__search_tracking_by_user_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`extlocaluser`@`%` SQL SECURITY DEFINER VIEW `view__search_tracking_by_user_summary` AS select distinct `s`.`phrase` AS `user_phrase`,`s`.`search_type` AS `search_type`,`s`.`_user_id` AS `_user_id`,(select count(`a`.`id`) from `user_search_tracking` `A` where (`a`.`phrase` = `s`.`phrase`)) AS `frequency`,`s`.`date_entered` AS `date_entered` from `user_search_tracking` `S` where (`s`.`date_entered` = (select max(`t`.`date_entered`) from `user_search_tracking` `T` where ((`t`.`phrase` = `s`.`phrase`) and (`t`.`_user_id` = `s`.`_user_id`)))) order by (select count(`a`.`id`) from `user_search_tracking` `A` where (`a`.`phrase` = `s`.`phrase`)) desc,`s`.`date_entered` desc;

-- --------------------------------------------------------

--
-- Структура для представления `view__search_tracking_summary`
--
DROP TABLE IF EXISTS `view__search_tracking_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`extlocaluser`@`%` SQL SECURITY DEFINER VIEW `view__search_tracking_summary` AS select distinct `s`.`search_type` AS `search_type`,`s`.`phrase` AS `user_phrase`,(select count(`a`.`id`) from `user_search_tracking` `A` where (`a`.`phrase` = `s`.`phrase`)) AS `frequency`,`s`.`date_entered` AS `date_entered` from `user_search_tracking` `S` where (`s`.`date_entered` = (select max(`t`.`date_entered`) from `user_search_tracking` `T` where (`t`.`phrase` = `s`.`phrase`))) order by (select count(`a`.`id`) from `user_search_tracking` `A` where (`a`.`phrase` = `s`.`phrase`)) desc,`s`.`date_entered` desc;

-- --------------------------------------------------------

--
-- Структура для представления `view__user_details`
--
DROP TABLE IF EXISTS `view__user_details`;

CREATE ALGORITHM=UNDEFINED DEFINER=`extlocaluser`@`%` SQL SECURITY DEFINER VIEW `view__user_details` AS select `u`.`id` AS `user_id`,`u`.`first_name` AS `first_name`,`u`.`last_name` AS `last_name`,`u`.`email_address` AS `email_address`,`u`.`email_verified` AS `email_verified`,`u`.`telephone` AS `mobile`,`u`.`mobile_verified` AS `mobile_verified`,`u`.`gender` AS `gender`,`u`.`birthday` AS `birthday`,concat(`u`.`address_line_1`,' ',`u`.`address_line_2`) AS `address`,`u`.`city` AS `city`,`u`.`state` AS `state`,`u`.`zipcode` AS `zipcode`,`u`.`country_code` AS `country`,`u`.`photo_url` AS `photo`,`u`.`driver_license` AS `driver_license`,`u`.`driver_license_verified` AS `driver_license_verified`,`u`.`ssn` AS `ssn`,`u`.`address_verified` AS `address_verified`,`u`.`date_entered` AS `date_joined`,`u`.`user_status` AS `user_status`,if(((select `user_social_media`.`id` from `user_social_media` where ((`user_social_media`.`_user_id` = `u`.`id`) and (`user_social_media`.`social_media_name` = 'facebook')) limit 1) is not null),'Y','N') AS `facebook_connected`,if(((select `user_social_media`.`id` from `user_social_media` where ((`user_social_media`.`_user_id` = `u`.`id`) and (`user_social_media`.`social_media_name` = 'linkedin')) limit 1) is not null),'Y','N') AS `linkedin_connected`,if(((select `user_social_media`.`id` from `user_social_media` where ((`user_social_media`.`_user_id` = `u`.`id`) and (`user_social_media`.`social_media_name` = 'twitter')) limit 1) is not null),'Y','N') AS `twitter_connected`,if((`u`.`email_address` <> ''),'Y','N') AS `email_connected`,(select max(`clout_v1_3cron`.`transactions_raw`.`last_update_date`) from `clout_v1_3cron`.`transactions_raw` where (`clout_v1_3cron`.`transactions_raw`.`_user_id` = `u`.`id`)) AS `last_import`,(select max(`referrals`.`activation_date`) from `referrals` where (`referrals`.`_referred_by` = `u`.`id`)) AS `last_join`,(select max(`clout_v1_3cron`.`commissions_network`.`date_entered`) from `clout_v1_3cron`.`commissions_network` where (`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`)) AS `last_commission`,(select count(`contacts`.`id`) from `contacts` where (`contacts`.`_owner_id` = `u`.`id`)) AS `total_imported_contacts`,(select (((count(`r0`.`_user_id`) + count(`r1`.`_user_id`)) + count(`r2`.`_user_id`)) + count(`r3`.`_user_id`)) from (((`referrals` `R0` left join `referrals` `R1` on((`r1`.`_referred_by` = `r0`.`_user_id`))) left join `referrals` `R2` on((`r2`.`_referred_by` = `r1`.`_user_id`))) left join `referrals` `R3` on((`r3`.`_referred_by` = `r2`.`_user_id`))) where (`r0`.`_referred_by` = `u`.`id`)) AS `total_network`,(select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`source_network_level` = '1'))) AS `commissions_level_1`,(select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`source_network_level` = '2'))) AS `commissions_level_2`,(select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`source_network_level` = '3'))) AS `commissions_level_3`,(select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`source_network_level` = '4'))) AS `commissions_level_4`,(select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where (`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`)) AS `total_commissions`,(select count(distinct `store_favorites`.`_store_id`) from `store_favorites` where (`store_favorites`.`_user_id` = `u`.`id`)) AS `total_store_favorites`,(select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where (`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`)) AS `commissions_store`,(select max(`activity_log`.`event_time`) from `activity_log` where ((`activity_log`.`user_id` = `u`.`id`) and (`activity_log`.`activity_code` = 'login'))) AS `last_login`,(select count(`activity_log`.`id`) from `activity_log` where ((`activity_log`.`user_id` = `u`.`id`) and (`activity_log`.`activity_code` = 'login'))) AS `total_logins`,(select max(`clout_v1_3cron`.`advert_and_promo_tracking`.`use_date`) from `clout_v1_3cron`.`advert_and_promo_tracking` where ((`clout_v1_3cron`.`advert_and_promo_tracking`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`advert_and_promo_tracking`.`is_used` = 'Y'))) AS `last_promo_used_on`,(select max(`tickets`.`date_entered`) from `tickets` where (`tickets`.`_user_id` = `u`.`id`)) AS `last_ticket_on`,(select count(`clout_v1_3cron`.`bank_accounts`.`id`) from `clout_v1_3cron`.`bank_accounts` where (`clout_v1_3cron`.`bank_accounts`.`_user_id` = `u`.`id`)) AS `total_linked_accounts`,(select count(distinct `clout_v1_3cron`.`bank_accounts`.`_bank_id`) from `clout_v1_3cron`.`bank_accounts` where (`clout_v1_3cron`.`bank_accounts`.`_user_id` = `u`.`id`)) AS `total_linked_institutions`,(select count(`clout_v1_3cron`.`transactions_raw`.`id`) from `clout_v1_3cron`.`transactions_raw` where (`clout_v1_3cron`.`transactions_raw`.`_user_id` = `u`.`id`)) AS `total_raw_transactions`,(select count(`user_geo_tracking`.`id`) from `user_geo_tracking` where ((`user_geo_tracking`.`source` = 'checkin') and (`user_geo_tracking`.`_user_id` = `u`.`id`))) AS `total_checkins`,(select count(distinct `p`.`id`) from (`clout_v1_3cron`.`commissions_transactions` `C` left join `clout_v1_3cron`.`promotions` `P` on((`c`.`_promotion_id` = `p`.`id`))) where ((`c`.`_user_id` = `u`.`id`) and (`p`.`promotion_type` = 'perk'))) AS `total_perks_used`,(select sum(`c`.`pay_out`) from (`clout_v1_3cron`.`commissions_transactions` `C` left join `clout_v1_3cron`.`promotions` `P` on((`c`.`_promotion_id` = `p`.`id`))) where ((`c`.`_user_id` = `u`.`id`) and (`p`.`promotion_type` = 'cashback'))) AS `total_cashback_used`,(select count(`reviews`.`id`) from `reviews` where (`reviews`.`_user_id` = `u`.`id`)) AS `total_reviews`,(select count(`activity_log`.`id`) from `activity_log` where ((`activity_log`.`user_id` = `u`.`id`) and (`activity_log`.`activity_code` = 'store_view'))) AS `total_store_views`,(select count(`activity_log`.`id`) from `activity_log` where ((`activity_log`.`user_id` = `u`.`id`) and (`activity_log`.`activity_code` = 'promotion_click'))) AS `total_clicks`,(select count(`activity_log`.`id`) from `activity_log` where ((`activity_log`.`user_id` = `u`.`id`) and (`activity_log`.`activity_code` = 'store_search'))) AS `total_searches`,(select count(distinct concat(`user_geo_tracking`.`longitude`,',',`user_geo_tracking`.`latitude`)) from `user_geo_tracking` where ((`user_geo_tracking`.`_user_id` = `u`.`id`) and (`user_geo_tracking`.`source` = 'checkin'))) AS `total_locations`,(select count(distinct `activity_log`.`ip_address`) from `activity_log` where (`activity_log`.`user_id` = `u`.`id`)) AS `total_ips`,(select count(distinct `activity_log`.`device`) from `activity_log` where (`activity_log`.`user_id` = `u`.`id`)) AS `total_devices`,(select count(`tickets`.`id`) from `tickets` where ((`tickets`.`_user_id` = `u`.`id`) and (`tickets`.`status` = 'pending'))) AS `total_open_tickets`,(select count(`tickets`.`id`) from `tickets` where ((`tickets`.`_user_id` = `u`.`id`) and (`tickets`.`status` = 'closed'))) AS `total_closed_tickets`,(select max(`clout_v1_3cron`.`transactions_raw`.`posted_date`) from `clout_v1_3cron`.`transactions_raw` where (`clout_v1_3cron`.`transactions_raw`.`_user_id` = `u`.`id`)) AS `last_transaction_date`,(select max(`clout_v1_3cron`.`user_payment_tracking`.`date_entered`) from `clout_v1_3cron`.`user_payment_tracking` where ((`clout_v1_3cron`.`user_payment_tracking`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`user_payment_tracking`.`status` = 'pending'))) AS `last_transfer_out_request`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` = 'approved'))) + (select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`status` = 'approved')))) AS `available_balance`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` = 'pending'))) + (select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`status` = 'pending')))) AS `pending_balance`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` = 'paid'))) + (select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`status` = 'paid')))) AS `total_withdrawn`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` = 'approved') and (cast(`clout_v1_3cron`.`commissions_transactions`.`expiry_date` as date) >= cast(now() as date)) and ((to_days(cast(`clout_v1_3cron`.`commissions_transactions`.`expiry_date` as date)) - to_days(now())) <= 30))) + (select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`status` = 'approved') and (cast(`clout_v1_3cron`.`commissions_network`.`expiry_date` as date) >= cast(now() as date)) and ((to_days(cast(`clout_v1_3cron`.`commissions_network`.`expiry_date` as date)) - to_days(now())) <= 30)))) AS `funds_expiring_in_30_days`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`pay_out`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and ((`clout_v1_3cron`.`commissions_transactions`.`status` = 'expired') or (cast(`clout_v1_3cron`.`commissions_transactions`.`expiry_date` as date) < cast(now() as date))))) + (select sum(`clout_v1_3cron`.`commissions_network`.`pay_out`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and ((`clout_v1_3cron`.`commissions_network`.`status` = 'expired') or (cast(`clout_v1_3cron`.`commissions_network`.`expiry_date` as date) < cast(now() as date)))))) AS `funds_expired`,((select sum(`clout_v1_3cron`.`commissions_transactions`.`fee`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` in ('paid','approved')))) + (select sum(`clout_v1_3cron`.`commissions_network`.`fee`) from `clout_v1_3cron`.`commissions_network` where ((`clout_v1_3cron`.`commissions_network`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_network`.`status` in ('paid','approved'))))) AS `total_withdraw_fees`,(select sum(`clout_v1_3cron`.`commissions_transactions`.`fee`) from `clout_v1_3cron`.`commissions_transactions` where ((`clout_v1_3cron`.`commissions_transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transactions`.`status` in ('paid','approved')))) AS `total_cashback_fees`,(select sum(`clout_v1_3cron`.`transactions`.`amount`) from `clout_v1_3cron`.`transactions` where ((`clout_v1_3cron`.`transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`transactions`.`_store_id` = '0'))) AS `total_unmatched_amount`,(select count(`clout_v1_3cron`.`transactions`.`id`) from `clout_v1_3cron`.`transactions` where ((`clout_v1_3cron`.`transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`transactions`.`_store_id` = '0'))) AS `total_unmatched`,(select sum(`clout_v1_3cron`.`transactions`.`amount`) from `clout_v1_3cron`.`transactions` where ((`clout_v1_3cron`.`transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`transactions`.`_store_id` > '0'))) AS `total_matched_amount`,(select count(`clout_v1_3cron`.`transactions`.`id`) from `clout_v1_3cron`.`transactions` where ((`clout_v1_3cron`.`transactions`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`transactions`.`_store_id` > '0'))) AS `total_matched`,(select sum(`clout_v1_3cron`.`commissions_transfers`.`amount`) from `clout_v1_3cron`.`commissions_transfers` where ((`clout_v1_3cron`.`commissions_transfers`.`_payee_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transfers`.`status` in ('pending','initiated')) and (`clout_v1_3cron`.`commissions_transfers`.`is_deposit` = 'N'))) AS `pending_transfers_out`,(select sum(`clout_v1_3cron`.`commissions_transfers`.`amount`) from `clout_v1_3cron`.`commissions_transfers` where ((`clout_v1_3cron`.`commissions_transfers`.`_payee_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_transfers`.`status` in ('pending','initiated')) and (`clout_v1_3cron`.`commissions_transfers`.`is_deposit` = 'Y'))) AS `pending_transfers_in`,(select count(`clout_v1_3cron`.`commissions_alerts`.`id`) from `clout_v1_3cron`.`commissions_alerts` where ((`clout_v1_3cron`.`commissions_alerts`.`_user_id` = `u`.`id`) and (`clout_v1_3cron`.`commissions_alerts`.`status` = 'active'))) AS `total_financial_alerts`,(select `user_security_settings`.`user_type` from `user_security_settings` where (`user_security_settings`.`_user_id` = `u`.`id`) limit 1) AS `user_type`,`cs`.`total_score` AS `clout_score`,(((((((`cs`.`facebook_connected_score` + `cs`.`email_verified_score`) + `cs`.`mobile_verified_score`) + `cs`.`profile_photo_added_score`) + `cs`.`bank_verified_and_active_score`) + `cs`.`credit_verified_and_active_score`) + `cs`.`location_services_activated_score`) + `cs`.`push_notifications_activated_score`) AS `account_setup_score`,(((`cs`.`has_first_public_checkin_success_score` + `cs`.`has_public_checkin_last7days_score`) + `cs`.`has_answered_survey_in_last90days_score`) + `cs`.`number_of_surveys_answered_in_last90days_score`) AS `activity_score`,(((((`cs`.`number_of_direct_referrals_last180days_score` + `cs`.`number_of_direct_referrals_last360days_score`) + `cs`.`total_direct_referrals_score`) + `cs`.`number_of_network_referrals_last180days_score`) + `cs`.`number_of_network_referrals_last360days_score`) + `cs`.`total_network_referrals_score`) AS `referrals_score`,(((((`cs`.`spending_of_direct_referrals_last180days_score` + `cs`.`spending_of_direct_referrals_last360days_score`) + `cs`.`total_spending_of_direct_referrals_score`) + `cs`.`spending_of_network_referrals_last180days_score`) + `cs`.`spending_of_network_referrals_last360days_score`) + `cs`.`total_spending_of_network_referrals_score`) AS `spending_of_referrals_score`,((`cs`.`spending_last180days_score` + `cs`.`spending_last360days_score`) + `cs`.`spending_total_score`) AS `spending_score`,((`cs`.`ad_spending_last180days_score` + `cs`.`ad_spending_last360days_score`) + `cs`.`ad_spending_total_score`) AS `ad_spending_score`,(((`cs`.`cash_balance_today_score` + `cs`.`average_cash_balance_last24months_score`) + `cs`.`credit_balance_today_score`) + `cs`.`average_credit_balance_last24months_score`) AS `linked_accounts_score`,`cs`.`spending_last180days` AS `spending_last180days`,`cs`.`spending_last360days` AS `spending_last360days`,`cs`.`spending_total` AS `spending_total`,`cs`.`ad_spending_last180days` AS `ad_spending_last180days`,`cs`.`ad_spending_last360days` AS `ad_spending_last360days`,`cs`.`ad_spending_total` AS `ad_spending_total` from (`users` `U` left join `clout_v1_3cron`.`cacheview__clout_score` `CS` on((`cs`.`user_id` = `u`.`id`)));

-- --------------------------------------------------------

--
-- Структура для представления `view__user_spending_summary`
--
DROP TABLE IF EXISTS `view__user_spending_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__user_spending_summary` AS select distinct `clout_v1_3cron`.`transactions`.`id` AS `transaction_id`,`clout_v1_3cron`.`transactions`.`_store_id` AS `store_id`,`clout_v1_3cron`.`transactions`.`_user_id` AS `user_id`,`clout_v1_3cron`.`transactions`.`amount` AS `amount`,`clout_v1_3cron`.`transactions`.`start_date` AS `start_date` from `clout_v1_3cron`.`transactions` where ((`clout_v1_3cron`.`transactions`.`transaction_type` = 'buy') and (`clout_v1_3cron`.`transactions`.`amount` > 0) and (`clout_v1_3cron`.`transactions`.`_store_id` <> '0'));

-- --------------------------------------------------------

--
-- Структура для представления `view__where_user_shopped`
--
DROP TABLE IF EXISTS `view__where_user_shopped`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view__where_user_shopped` AS select distinct `T`.`_store_id` AS `store_id`,`T`.`_user_id` AS `user_id`,`C`.`total_score` AS `store_score`,(select count(`A`.`id`) from `clout_v1_3cron`.`transactions` `A` where ((`A`.`_store_id` = `T`.`_store_id`) and (`A`.`_user_id` = `T`.`_user_id`))) AS `frequency`,`S`.`name` AS `name`,`S`.`zipcode` AS `zipcode` from ((`clout_v1_3cron`.`transactions` `T` left join `clout_v1_3cron`.`cacheview__store_score_by_store` `C` on((`C`.`store_id` = `T`.`_store_id`))) left join `stores` `S` on((`T`.`_store_id` = `S`.`id`))) where ((`T`.`_store_id` <> '0') and (`S`.`name` is not null)) order by (`C`.`total_score` + 0) desc,(select count(`A`.`id`) from `clout_v1_3cron`.`transactions` `A` where ((`A`.`_store_id` = `T`.`_store_id`) and (`A`.`_user_id` = `T`.`_user_id`))) desc;

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
-- Индексы таблицы `advertisements`
--
ALTER TABLE `advertisements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_advertisements__promotion_id` (`_promotion_id`);

--
-- Индексы таблицы `agents`
--
ALTER TABLE `agents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_agents__user_id` (`_user_id`);

--
-- Индексы таблицы `agent_experience`
--
ALTER TABLE `agent_experience`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_agent_experience__user_id` (`_user_id`),
  ADD KEY `fk_agent_experience__last_updated_by` (`_last_updated_by`);

--
-- Индексы таблицы `archived_photos`
--
ALTER TABLE `archived_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_archived_photos__user_id` (`_user_id`);

--
-- Индексы таблицы `brands`
--
ALTER TABLE `brands`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_brands__store_id` (`_store_id`),
  ADD KEY `fk_brands__store_owner_id` (`_store_owner_id`);

--
-- Индексы таблицы `cacheview__default_search_suggestions`
--
ALTER TABLE `cacheview__default_search_suggestions`
  ADD PRIMARY KEY (`table_id`),
  ADD UNIQUE KEY `cache_id` (`store_id`,`user_id`),
  ADD FULLTEXT KEY `suggestion_index` (`name`);

--
-- Индексы таблицы `cacheview__search_tracking_by_user_summary`
--
ALTER TABLE `cacheview__search_tracking_by_user_summary`
  ADD PRIMARY KEY (`table_id`);

--
-- Индексы таблицы `cacheview__search_tracking_summary`
--
ALTER TABLE `cacheview__search_tracking_summary`
  ADD PRIMARY KEY (`table_id`),
  ADD FULLTEXT KEY `suggestion_index` (`user_phrase`);

--
-- Индексы таблицы `categories_level_1`
--
ALTER TABLE `categories_level_1`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `categories_level_2`
--
ALTER TABLE `categories_level_2`
  ADD PRIMARY KEY (`id`),
  ADD KEY `indx1_name` (`name`),
  ADD FULLTEXT KEY `name` (`name`);

--
-- Индексы таблицы `categories_level_2_naics_mapping`
--
ALTER TABLE `categories_level_2_naics_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_category_level_2_id` (`_category_level_2_id`,`naics_code`);

--
-- Индексы таблицы `categories_level_2_naics_mapping_new`
--
ALTER TABLE `categories_level_2_naics_mapping_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_category_level_2_id` (`_category_level_2_id`,`naics_code`);

--
-- Индексы таблицы `categories_level_2_sic_mapping`
--
ALTER TABLE `categories_level_2_sic_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_category_level_2_id` (`_category_level_2_id`,`sic_code`);

--
-- Индексы таблицы `categories_level_2_sic_mapping_new`
--
ALTER TABLE `categories_level_2_sic_mapping_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_category_level_2_id` (`_category_level_2_id`,`sic_code`);

--
-- Индексы таблицы `categories_level_2_suggestions`
--
ALTER TABLE `categories_level_2_suggestions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `suggestion` (`suggestion`,`_categories_level_1_id`);

--
-- Индексы таблицы `chains`
--
ALTER TABLE `chains`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `website` (`website`),
  ADD KEY `website_2` (`website`),
  ADD FULLTEXT KEY `name_2` (`name`);

--
-- Индексы таблицы `chains_new`
--
ALTER TABLE `chains_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`),
  ADD KEY `website` (`website`),
  ADD KEY `indx1_name_address` (`name`,`address_line_1`,`city`),
  ADD KEY `indx1_name` (`name`),
  ADD FULLTEXT KEY `name_2` (`name`);

--
-- Индексы таблицы `chain_categories`
--
ALTER TABLE `chain_categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `chain_references`
--
ALTER TABLE `chain_references`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `changes`
--
ALTER TABLE `changes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `change_flags`
--
ALTER TABLE `change_flags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_change_id` (`_change_id`,`_flag_id`);

--
-- Индексы таблицы `change_log`
--
ALTER TABLE `change_log`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_cities__country_code` (`_country_code`);

--
-- Индексы таблицы `cities_new`
--
ALTER TABLE `cities_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UQ_Name_Dist` (`name`,`district`),
  ADD KEY `fk_cities__country_code` (`_country_code`);

--
-- Индексы таблицы `commissions_status_track`
--
ALTER TABLE `commissions_status_track`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `common_words`
--
ALTER TABLE `common_words`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `contacts`
--
ALTER TABLE `contacts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_owner_id` (`_owner_id`,`phone`,`email`),
  ADD UNIQUE KEY `_owner_id_2` (`_owner_id`,`phone`,`email`);

--
-- Индексы таблицы `contact_addresses`
--
ALTER TABLE `contact_addresses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`address_line_1`,`city`,`zipcode`),
  ADD FULLTEXT KEY `address_index` (`address_line_1`);

--
-- Индексы таблицы `contact_subscribe_list`
--
ALTER TABLE `contact_subscribe_list`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_contact_subscribe_list__contact_id` (`_contact_id`),
  ADD KEY `fk_contact_subscribe_list__contacted_by_user_id` (`_contacted_by_user_id`);

--
-- Индексы таблицы `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `currencies`
--
ALTER TABLE `currencies`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_currencies__country_code` (`_country_code`);

--
-- Индексы таблицы `flags`
--
ALTER TABLE `flags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`type`);

--
-- Индексы таблицы `help`
--
ALTER TABLE `help`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_help__entered_by` (`_entered_by`);

--
-- Индексы таблицы `keys`
--
ALTER TABLE `keys`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_languages__store_id` (`_store_id`);

--
-- Индексы таблицы `list_actions`
--
ALTER TABLE `list_actions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `naics_codes`
--
ALTER TABLE `naics_codes`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `payment_accepted`
--
ALTER TABLE `payment_accepted`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_payment_accepted__store_id` (`_store_id`);

--
-- Индексы таблицы `plaid_categories`
--
ALTER TABLE `plaid_categories`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `CUSTOM_CATEGORY_ID` (`custom_category_id`),
  ADD KEY `ENTERED_BY` (`_entered_by`);

--
-- Индексы таблицы `promotions_categories_levels`
--
ALTER TABLE `promotions_categories_levels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `CATEGORY_ID` (`category_id`),
  ADD KEY `LEVEL_ID` (`level_id`);

--
-- Индексы таблицы `promotions_custom_categories`
--
ALTER TABLE `promotions_custom_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `CATEGORY_ID` (`category_id`),
  ADD KEY `STORE_OWNER_ID` (`store_owner_id`),
  ADD KEY `USER_ID` (`user_id`),
  ADD KEY `SUB_CATEGORY_ID` (`sub_category_id`);

--
-- Индексы таблицы `promotions_custom_levels`
--
ALTER TABLE `promotions_custom_levels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `CATEGORY_ID` (`category_id`);

--
-- Индексы таблицы `queries`
--
ALTER TABLE `queries`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Индексы таблицы `referrals`
--
ALTER TABLE `referrals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_referrals__user_id` (`_user_id`),
  ADD KEY `fk_referrals__referred_by` (`_referred_by`);

--
-- Индексы таблицы `referral_url_ids`
--
ALTER TABLE `referral_url_ids`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`url_id`),
  ADD KEY `fk_referral_url_ids__user_id` (`_user_id`);

--
-- Индексы таблицы `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`_store_id`);

--
-- Индексы таблицы `share_actions`
--
ALTER TABLE `share_actions`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `share_buttons`
--
ALTER TABLE `share_buttons`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `public_id` (`public_id`);

--
-- Индексы таблицы `sic_codes`
--
ALTER TABLE `sic_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `indx1_details` (`code_details`,`code`);

--
-- Индексы таблицы `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_states__country_code` (`_country_code`);

--
-- Индексы таблицы `stores`
--
ALTER TABLE `stores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_stores__entered_by` (`_entered_by`),
  ADD KEY `fk_stores__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_stores__state_id` (`_state_id`),
  ADD KEY `fk_stores__country_code` (`_country_code`),
  ADD KEY `fk_stores__primary_contact_id` (`_primary_contact_id`),
  ADD KEY `indx1_name_address` (`name`,`address_line_1`,`city`),
  ADD KEY `indx_chain_id` (`_chain_id`),
  ADD FULLTEXT KEY `ft_stores__name` (`name`);
ALTER TABLE `stores`
  ADD FULLTEXT KEY `name` (`name`);
ALTER TABLE `stores`
  ADD FULLTEXT KEY `address_line_1` (`address_line_1`);

--
-- Индексы таблицы `stores_new`
--
ALTER TABLE `stores_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_stores__entered_by` (`_entered_by`),
  ADD KEY `fk_stores__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_stores__state_id` (`_state_id`),
  ADD KEY `fk_stores__country_code` (`_country_code`),
  ADD KEY `fk_stores__primary_contact_id` (`_primary_contact_id`),
  ADD KEY `idx1_name_address` (`name`,`address_line_1`),
  ADD KEY `indx_name` (`name`),
  ADD KEY `indx_phone` (`phone_number`),
  ADD KEY `indx_email` (`email_address`),
  ADD KEY `indx_address` (`address_line_1`),
  ADD KEY `indx_lati_longi` (`longitude`,`latitude`),
  ADD KEY `indx_website` (`website`),
  ADD KEY `indx_chain_id` (`_chain_id`),
  ADD FULLTEXT KEY `ft_stores__name` (`name`);
ALTER TABLE `stores_new`
  ADD FULLTEXT KEY `ft_stores__address` (`address_line_1`);

--
-- Индексы таблицы `stores_new_prd`
--
ALTER TABLE `stores_new_prd`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_stores__entered_by` (`_entered_by`),
  ADD KEY `fk_stores__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_stores__state_id` (`_state_id`),
  ADD KEY `fk_stores__country_code` (`_country_code`),
  ADD KEY `fk_stores__primary_contact_id` (`_primary_contact_id`),
  ADD KEY `idx1_name_address` (`name`,`address_line_1`),
  ADD KEY `indx_name` (`name`),
  ADD KEY `indx_phone` (`phone_number`),
  ADD KEY `indx_email` (`email_address`),
  ADD KEY `indx_address` (`address_line_1`),
  ADD KEY `indx_lati_longi` (`longitude`,`latitude`),
  ADD KEY `indx_website` (`website`),
  ADD KEY `indx_chain_id` (`_chain_id`),
  ADD FULLTEXT KEY `ft_stores__name` (`name`);
ALTER TABLE `stores_new_prd`
  ADD FULLTEXT KEY `ft_stores__address` (`address_line_1`);

--
-- Индексы таблицы `stores_OLD`
--
ALTER TABLE `stores_OLD`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_stores__entered_by` (`_entered_by`),
  ADD KEY `fk_stores__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_stores__state_id` (`_state_id`),
  ADD KEY `fk_stores__country_code` (`_country_code`),
  ADD KEY `fk_stores__primary_contact_id` (`_primary_contact_id`),
  ADD KEY `indx1_name_address` (`name`,`address_line_1`,`city`),
  ADD FULLTEXT KEY `ft_stores__name` (`name`);

--
-- Индексы таблицы `stores_scraper`
--
ALTER TABLE `stores_scraper`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_stores__entered_by` (`_entered_by`),
  ADD KEY `fk_stores__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_stores__state_id` (`_state_id`),
  ADD KEY `fk_stores__country_code` (`_country_code`),
  ADD KEY `fk_stores__primary_contact_id` (`_primary_contact_id`),
  ADD FULLTEXT KEY `ft_stores__name` (`name`);

--
-- Индексы таблицы `stores_trans_cat_TEMP_JC2`
--
ALTER TABLE `stores_trans_cat_TEMP_JC2`
  ADD KEY `index_1` (`_state_id`);

--
-- Индексы таблицы `store_chains`
--
ALTER TABLE `store_chains`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_store_id` (`_store_id`);

--
-- Индексы таблицы `store_competitors`
--
ALTER TABLE `store_competitors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UQ` (`_store_id`,`competitor_id`),
  ADD KEY `fk_store_competitors__store_id` (`_store_id`);

--
-- Индексы таблицы `store_competitors_dev`
--
ALTER TABLE `store_competitors_dev`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `UQ` (`_store_id`,`competitor_id`),
  ADD KEY `fk_store_competitors__store_id` (`_store_id`);

--
-- Индексы таблицы `store_favorites`
--
ALTER TABLE `store_favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`_store_id`);

--
-- Индексы таблицы `store_features`
--
ALTER TABLE `store_features`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `store_hours`
--
ALTER TABLE `store_hours`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_hours__store_id` (`_store_id`);

--
-- Индексы таблицы `store_hours_new`
--
ALTER TABLE `store_hours_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_hours__store_id` (`_store_id`);

--
-- Индексы таблицы `store_match_patterns`
--
ALTER TABLE `store_match_patterns`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rule_type` (`command`,`name_pattern`,`address_pattern`);

--
-- Индексы таблицы `store_offer_requests`
--
ALTER TABLE `store_offer_requests`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`_store_id`);

--
-- Индексы таблицы `store_owners`
--
ALTER TABLE `store_owners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_owners__entered_by` (`_entered_by`),
  ADD KEY `fk_store_owners__last_updated_by` (`_last_updated_by`);

--
-- Индексы таблицы `store_owner_stores`
--
ALTER TABLE `store_owner_stores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_owner_stores__store_owner_id` (`_store_owner_id`),
  ADD KEY `fk_store_owner_stores__store_id` (`_store_id`),
  ADD KEY `fk_store_owner_stores__entered_by` (`_entered_by`);

--
-- Индексы таблицы `store_photos`
--
ALTER TABLE `store_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_photos__store_id` (`_store_id`),
  ADD KEY `fk_store_photos__entered_by` (`_entered_by`);

--
-- Индексы таблицы `store_products_or_services`
--
ALTER TABLE `store_products_or_services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_products_or_services__store_id` (`_store_id`);

--
-- Индексы таблицы `store_products_or_services_new`
--
ALTER TABLE `store_products_or_services_new`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_products_or_services__store_id` (`_store_id`);

--
-- Индексы таблицы `store_sales_channels`
--
ALTER TABLE `store_sales_channels`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_sales_channels__store_id` (`_store_id`);

--
-- Индексы таблицы `store_staff`
--
ALTER TABLE `store_staff`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_store_staff__store_id` (`_store_id`),
  ADD KEY `fk_store_staff__entered_by` (`_entered_by`),
  ADD KEY `fk_store_staff__staff_user_id` (`_staff_user_id`);

--
-- Индексы таблицы `store_sub_categories`
--
ALTER TABLE `store_sub_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_storeid_subcategory` (`_store_id`,`_sub_category_id`),
  ADD KEY `fk_store_sub_categories__store_id` (`_store_id`),
  ADD KEY `fk_store_sub_categories__category_id` (`_category_id`),
  ADD KEY `fk_store_sub_categories__sub_category_id` (`_sub_category_id`);

--
-- Индексы таблицы `store_sub_categories_new`
--
ALTER TABLE `store_sub_categories_new`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_storeid_subcategory` (`_store_id`,`_sub_category_id`),
  ADD KEY `fk_store_sub_categories__store_id` (`_store_id`),
  ADD KEY `fk_store_sub_categories__category_id` (`_category_id`),
  ADD KEY `fk_store_sub_categories__sub_category_id` (`_sub_category_id`);

--
-- Индексы таблицы `store_suggestions`
--
ALTER TABLE `store_suggestions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`,`address`,`zipcode`);

--
-- Индексы таблицы `superpages_raw`
--
ALTER TABLE `superpages_raw`
  ADD KEY `indx1_name` (`name`),
  ADD KEY `indx1_cat` (`category`),
  ADD KEY `indx1_state` (`state`),
  ADD FULLTEXT KEY `indx2_name` (`name`);

--
-- Индексы таблицы `surveys`
--
ALTER TABLE `surveys`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_surveys__store_id` (`_store_id`),
  ADD KEY `fk_surveys__last_updated_by` (`_last_updated_by`),
  ADD KEY `fk_surveys__entered_by` (`_entered_by`);

--
-- Индексы таблицы `survey_answers`
--
ALTER TABLE `survey_answers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_survey_answers__question_id` (`_question_id`);

--
-- Индексы таблицы `survey_categories`
--
ALTER TABLE `survey_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_survey_categories__survey_id` (`_survey_id`),
  ADD KEY `fk_survey_categories__sub_category_id` (`_sub_category_id`);

--
-- Индексы таблицы `survey_questions`
--
ALTER TABLE `survey_questions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_survey_questions__survey_id` (`_survey_id`);

--
-- Индексы таблицы `survey_responses`
--
ALTER TABLE `survey_responses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_survey_responses__user_id` (`_user_id`),
  ADD KEY `fk_survey_responses__question_id` (`_question_id`),
  ADD KEY `fk_survey_responses__answer_id` (`_answer_id`);

--
-- Индексы таблицы `system_content`
--
ALTER TABLE `system_content`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `transactions_raw_TEMP_JC`
--
ALTER TABLE `transactions_raw_TEMP_JC`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `transaction_id` (`transaction_id`,`_user_id`,`_bank_id`),
  ADD FULLTEXT KEY `payee_name` (`payee_name`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email_address` (`email_address`),
  ADD FULLTEXT KEY `first_name_index` (`first_name`);
ALTER TABLE `users`
  ADD FULLTEXT KEY `last_name_index` (`last_name`);

--
-- Индексы таблицы `user_facebook_data`
--
ALTER TABLE `user_facebook_data`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `facebook_id` (`facebook_id`);

--
-- Индексы таблицы `user_geo_tracking`
--
ALTER TABLE `user_geo_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_geo_tracking__user_id` (`_user_id`),
  ADD KEY `fk_user_geo_tracking__checkin_store_id` (`_checkin_store_id`),
  ADD KEY `fk_user_geo_tracking__checkin_offer_id` (`_checkin_offer_id`);

--
-- Индексы таблицы `user_locations`
--
ALTER TABLE `user_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`latitude`,`longitude`,`ip_address`,`source`);

--
-- Индексы таблицы `user_search_learned_phrases`
--
ALTER TABLE `user_search_learned_phrases`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `user_search_tracking`
--
ALTER TABLE `user_search_tracking`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_user_search_tracking__user_id` (`_user_id`);

--
-- Индексы таблицы `user_security_settings`
--
ALTER TABLE `user_security_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`),
  ADD KEY `fk_user_security_settings__user_id` (`_user_id`),
  ADD KEY `fk_user_security_settings__last_updated_by` (`_last_updated_by`);

--
-- Индексы таблицы `user_social_media`
--
ALTER TABLE `user_social_media`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_user_id` (`_user_id`,`social_media_name`,`user_name`);

--
-- Индексы таблицы `vip_levels`
--
ALTER TABLE `vip_levels`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `_store_id` (`_store_id`,`level_name`);

--
-- Индексы таблицы `vip_level_categories`
--
ALTER TABLE `vip_level_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `category_name` (`category_name`,`_vip_level_id`);

--
-- Индексы таблицы `yellowpages_links`
--
ALTER TABLE `yellowpages_links`
  ADD PRIMARY KEY (`id`);

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
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=23;
--
-- AUTO_INCREMENT для таблицы `advertisements`
--
ALTER TABLE `advertisements`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `agents`
--
ALTER TABLE `agents`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `agent_experience`
--
ALTER TABLE `agent_experience`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `archived_photos`
--
ALTER TABLE `archived_photos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `brands`
--
ALTER TABLE `brands`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `cacheview__default_search_suggestions`
--
ALTER TABLE `cacheview__default_search_suggestions`
  MODIFY `table_id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=74;
--
-- AUTO_INCREMENT для таблицы `cacheview__search_tracking_by_user_summary`
--
ALTER TABLE `cacheview__search_tracking_by_user_summary`
  MODIFY `table_id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `cacheview__search_tracking_summary`
--
ALTER TABLE `cacheview__search_tracking_summary`
  MODIFY `table_id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `categories_level_1`
--
ALTER TABLE `categories_level_1`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `categories_level_2`
--
ALTER TABLE `categories_level_2`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `categories_level_2_naics_mapping`
--
ALTER TABLE `categories_level_2_naics_mapping`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=563670;
--
-- AUTO_INCREMENT для таблицы `categories_level_2_naics_mapping_new`
--
ALTER TABLE `categories_level_2_naics_mapping_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `categories_level_2_sic_mapping`
--
ALTER TABLE `categories_level_2_sic_mapping`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=206760;
--
-- AUTO_INCREMENT для таблицы `categories_level_2_sic_mapping_new`
--
ALTER TABLE `categories_level_2_sic_mapping_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=211945;
--
-- AUTO_INCREMENT для таблицы `categories_level_2_suggestions`
--
ALTER TABLE `categories_level_2_suggestions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT для таблицы `chains`
--
ALTER TABLE `chains`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `chains_new`
--
ALTER TABLE `chains_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `chain_categories`
--
ALTER TABLE `chain_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29;
--
-- AUTO_INCREMENT для таблицы `chain_references`
--
ALTER TABLE `chain_references`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT для таблицы `changes`
--
ALTER TABLE `changes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=58;
--
-- AUTO_INCREMENT для таблицы `change_flags`
--
ALTER TABLE `change_flags`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=47;
--
-- AUTO_INCREMENT для таблицы `change_log`
--
ALTER TABLE `change_log`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `cities`
--
ALTER TABLE `cities`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `cities_new`
--
ALTER TABLE `cities_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `commissions_status_track`
--
ALTER TABLE `commissions_status_track`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `common_words`
--
ALTER TABLE `common_words`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `contacts`
--
ALTER TABLE `contacts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `contact_addresses`
--
ALTER TABLE `contact_addresses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=57;
--
-- AUTO_INCREMENT для таблицы `contact_subscribe_list`
--
ALTER TABLE `contact_subscribe_list`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `countries`
--
ALTER TABLE `countries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `currencies`
--
ALTER TABLE `currencies`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `flags`
--
ALTER TABLE `flags`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT для таблицы `help`
--
ALTER TABLE `help`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `keys`
--
ALTER TABLE `keys`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `languages`
--
ALTER TABLE `languages`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `list_actions`
--
ALTER TABLE `list_actions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT для таблицы `naics_codes`
--
ALTER TABLE `naics_codes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `payment_accepted`
--
ALTER TABLE `payment_accepted`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `plaid_categories`
--
ALTER TABLE `plaid_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `promotions`
--
ALTER TABLE `promotions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT для таблицы `promotions_categories_levels`
--
ALTER TABLE `promotions_categories_levels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=522;
--
-- AUTO_INCREMENT для таблицы `promotions_custom_categories`
--
ALTER TABLE `promotions_custom_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=315;
--
-- AUTO_INCREMENT для таблицы `promotions_custom_levels`
--
ALTER TABLE `promotions_custom_levels`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=100;
--
-- AUTO_INCREMENT для таблицы `queries`
--
ALTER TABLE `queries`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=407;
--
-- AUTO_INCREMENT для таблицы `referrals`
--
ALTER TABLE `referrals`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT для таблицы `referral_url_ids`
--
ALTER TABLE `referral_url_ids`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT для таблицы `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=13;
--
-- AUTO_INCREMENT для таблицы `share_actions`
--
ALTER TABLE `share_actions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `share_buttons`
--
ALTER TABLE `share_buttons`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `sic_codes`
--
ALTER TABLE `sic_codes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `states`
--
ALTER TABLE `states`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `stores`
--
ALTER TABLE `stores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `stores_new`
--
ALTER TABLE `stores_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `stores_new_prd`
--
ALTER TABLE `stores_new_prd`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `stores_OLD`
--
ALTER TABLE `stores_OLD`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `stores_scraper`
--
ALTER TABLE `stores_scraper`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=74000023;
--
-- AUTO_INCREMENT для таблицы `store_chains`
--
ALTER TABLE `store_chains`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=764;
--
-- AUTO_INCREMENT для таблицы `store_competitors`
--
ALTER TABLE `store_competitors`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `store_competitors_dev`
--
ALTER TABLE `store_competitors_dev`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `store_favorites`
--
ALTER TABLE `store_favorites`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=19;
--
-- AUTO_INCREMENT для таблицы `store_features`
--
ALTER TABLE `store_features`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `store_hours`
--
ALTER TABLE `store_hours`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1769583;
--
-- AUTO_INCREMENT для таблицы `store_hours_new`
--
ALTER TABLE `store_hours_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=1769583;
--
-- AUTO_INCREMENT для таблицы `store_match_patterns`
--
ALTER TABLE `store_match_patterns`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8336;
--
-- AUTO_INCREMENT для таблицы `store_offer_requests`
--
ALTER TABLE `store_offer_requests`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=15;
--
-- AUTO_INCREMENT для таблицы `store_owners`
--
ALTER TABLE `store_owners`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6;
--
-- AUTO_INCREMENT для таблицы `store_owner_stores`
--
ALTER TABLE `store_owner_stores`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `store_photos`
--
ALTER TABLE `store_photos`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT для таблицы `store_products_or_services`
--
ALTER TABLE `store_products_or_services`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6094766;
--
-- AUTO_INCREMENT для таблицы `store_products_or_services_new`
--
ALTER TABLE `store_products_or_services_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=6094766;
--
-- AUTO_INCREMENT для таблицы `store_sales_channels`
--
ALTER TABLE `store_sales_channels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `store_staff`
--
ALTER TABLE `store_staff`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT для таблицы `store_sub_categories`
--
ALTER TABLE `store_sub_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `store_sub_categories_new`
--
ALTER TABLE `store_sub_categories_new`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=5128;
--
-- AUTO_INCREMENT для таблицы `store_suggestions`
--
ALTER TABLE `store_suggestions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT для таблицы `surveys`
--
ALTER TABLE `surveys`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT для таблицы `survey_answers`
--
ALTER TABLE `survey_answers`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `survey_categories`
--
ALTER TABLE `survey_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT для таблицы `survey_questions`
--
ALTER TABLE `survey_questions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT для таблицы `survey_responses`
--
ALTER TABLE `survey_responses`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=8;
--
-- AUTO_INCREMENT для таблицы `system_content`
--
ALTER TABLE `system_content`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `transactions_raw_TEMP_JC`
--
ALTER TABLE `transactions_raw_TEMP_JC`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=29869;
--
-- AUTO_INCREMENT для таблицы `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=92;
--
-- AUTO_INCREMENT для таблицы `user_facebook_data`
--
ALTER TABLE `user_facebook_data`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `user_geo_tracking`
--
ALTER TABLE `user_geo_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=11;
--
-- AUTO_INCREMENT для таблицы `user_locations`
--
ALTER TABLE `user_locations`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT для таблицы `user_search_learned_phrases`
--
ALTER TABLE `user_search_learned_phrases`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `user_search_tracking`
--
ALTER TABLE `user_search_tracking`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `user_security_settings`
--
ALTER TABLE `user_security_settings`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=70;
--
-- AUTO_INCREMENT для таблицы `user_social_media`
--
ALTER TABLE `user_social_media`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT для таблицы `vip_levels`
--
ALTER TABLE `vip_levels`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `vip_level_categories`
--
ALTER TABLE `vip_level_categories`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `yellowpages_links`
--
ALTER TABLE `yellowpages_links`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT для таблицы `zipcodes`
--
ALTER TABLE `zipcodes`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT,AUTO_INCREMENT=49188;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
