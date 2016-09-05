
customer query for Local SERVER
 //Для Тестов

 
 SELECT _user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name,
 score(_user.id) as score,
 in_store_spending (_user.id) as in_store_spending,
 competitor_spending(_user.id) as competitor_spending,
 category_spending(_user.id) as category_spending,
 related_spending(_user.id) as related_spending,
 (SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
 datatab_user_data.total_linked_accounts as linked_accounts,
 last_activity_ed(_user.id) as activity,
 _user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
 p_custom_cat.category_label as custom_label,
 s_schedule.special_request as notes,

priority(_user.id) as priority,

 (SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,
get_upcoming_date(_user.id,g_tracking.latitude,g_tracking.longitude) as upcoming,
store_distance(g_tracking.latitude,g_tracking.longitude) as distance_store,
DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,


active(_user.id) as action,


other_reser_ed(_user.id) as other_reservations,
CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id  ) as past_checkins,
(SELECT sum(clout_v1_3msg.message_invites.number_of_invitations) FROM clout_v1_3msg.message_invites WHERE _user.id = clout_v1_3msg.message_invites._user_id ) as in_network,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id ) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id ) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_user.address_line_1 as store_address,
_user.country_code as store_country,
_user.city as store_city,
_user.photo_url,
(SELECT sum(clout_v1_3cron.promotions.amount) FROM clout_v1_3cron.promotions where clout_v1_3cron.promotions.owner_id = 1 and clout_v1_3cron.promotions.owner_type = 'person') as promo_spending,

store_last_transaction_ed(_user.id) as store_last_transaction


	 FROM clout_v1_3.users as _user
	  INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
	  LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
	  LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = _user.id
      LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id
      LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _user.id AND promotion.owner_type='store'
      LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._user_id = _user.id








//Готовый запрос для импорта в базу

 SELECT _user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name,
 score(_user.id) as score,
 in_store_spending (_user.id) as in_store_spending,
 competitor_spending(_user.id) as competitor_spending,
 related_spending(_user.id) as related_spending,
 (SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
 datatab_user_data.total_linked_accounts as linked_accounts,
 last_activity_ed(_user.id) as activity,
 _user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
 p_custom_cat.category_label as custom_label,
 s_schedule.special_request as notes,

priority(_user.id) as priority,
 
 (SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,
get_upcoming_date(_user.id,g_tracking.latitude,g_tracking.longitude) as upcoming,
_DISTANCE_                                                          
DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,

active(_user.id) as action,

other_reser_ed(_user.id) as other_reservations,
CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id  ) as past_checkins,
(SELECT sum(clout_v1_3msg.message_invites.number_of_invitations) FROM clout_v1_3msg.message_invites WHERE _user.id = clout_v1_3msg.message_invites._user_id ) as in_network,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id ) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id ) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_user.address_line_1 as store_address,
_user.country_code as store_country,
_user.city as store_city,
_user.photo_url,
(SELECT sum(clout_v1_3cron.promotions.amount) FROM clout_v1_3cron.promotions where clout_v1_3cron.promotions.owner_id = 1 and clout_v1_3cron.promotions.owner_type = 'person') as promo_spending,

store_last_transaction_ed(_user.id) as store_last_transaction


	 FROM clout_v1_3.users as _user
	  INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
	  LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
	  LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = _user.id
      LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id
      LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _user.id AND promotion.owner_type='store'
      LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._user_id = _user.id
       _WHERE_









































customer query for DEW SERVER 









   SELECT _user.id as user_id, CONCAT(_user.first_name, ' ',_user.last_name)as name,
 score(_user.id) as score,
 in_store_spending (_user.id) as in_store_spending,
 competitor_spending(_user.id) as competitor_spending,
 related_spending(_user.id) as related_spending,
 (SELECT SUM(clout_v1_3cron.transactions_raw.amount) FROM clout_v1_3cron.transactions_raw where clout_v1_3cron.transactions_raw._user_id = _user.id) as overall_spending,
 datatab_user_data.total_linked_accounts as linked_accounts,
 last_activity_ed(_user.id) as activity,
 _user.city,_user.state,_user.zipcode as zip, _user.country_code as country,_user.gender, SUBSTRING_INDEX(DATEDIFF(CURRENT_DATE, STR_TO_DATE(_user.birthday, '%Y-%m-%d'))/365, '.', 1)   AS age,
 p_custom_cat.category_label as custom_label,
 s_schedule.special_request as notes,

priority(_user.id) as priority,
 
 (SELECT count(*) FROM clout_v1_3.referrals where clout_v1_3.referrals._user_id = _user.id )as network,
(SELECT count(*) FROM clout_v1_3msg.message_invites where clout_v1_3msg.message_invites._user_id = _user.id) as invites,
get_upcoming_date(_user.id,g_tracking.latitude,g_tracking.longitude) as upcoming,
1 as distance_store,                                                       
DATE_FORMAT(s_schedule.schedule_date,'%r') as time,
promotion.promotion_type as type,
s_schedule.number_in_party as size,
c_transaction.status,

active(_user.id) as action,

other_reser_ed(_user.id) as other_reservations,
CONCAT(g_tracking.tracking_time,'|',g_tracking.source) as last_checkins,
(SELECT count(*) FROM clout_v1_3.user_geo_tracking as _g_tracking WHERE _g_tracking._user_id = _user.id  ) as past_checkins,
(SELECT sum(clout_v1_3msg.message_invites.number_of_invitations) FROM clout_v1_3msg.message_invites WHERE _user.id = clout_v1_3msg.message_invites._user_id ) as in_network,
(SELECT count(*) FROM clout_v1_3cron.transactions_raw as cus_transaction WHERE  cus_transaction._user_id = _user.id)as transactions,
(SELECT count(*) FROM clout_v1_3.reviews as _review where _review._user_id = _user.id ) as reviews,
(SELECT count(*) FROM clout_v1_3.store_favorites as s_favorites where s_favorites._user_id = _user.id ) as favorited,
(SELECT count(*) FROM clout_v1_3msg.message_invites as cus_invites where cus_invites._user_id = _user.id and cus_invites.referral_status = 'accepted') as network_size,
s_schedule.reservation_status as reservation,
s_schedule.schedule_date,
_user.address_line_1 as store_address,
_user.country_code as store_country,
_user.city as store_city,
_user.photo_url,
(SELECT sum(clout_v1_3cron.promotions.amount) FROM clout_v1_3cron.promotions where clout_v1_3cron.promotions.owner_id = 1 and clout_v1_3cron.promotions.owner_type = 'person') as promo_spending,

store_last_transaction_ed(_user.id) as store_last_transaction


	 FROM clout_v1_3.users as _user
	  INNER JOIN clout_v1_3cron.datatable__user_data as datatab_user_data ON datatab_user_data.user_id = _user.id
	  LEFT JOIN clout_v1_3.promotions_custom_categories as p_custom_cat ON p_custom_cat.user_id = _user.id
	  LEFT JOIN clout_v1_3.store_schedule as s_schedule ON s_schedule._store_id = _user.id
      LEFT JOIN clout_v1_3.user_geo_tracking as g_tracking ON g_tracking._user_id = _user.id
      LEFT JOIN clout_v1_3cron.promotions as promotion ON promotion.owner_id = _user.id AND promotion.owner_type='store'
      LEFT JOIN clout_v1_3cron.commissions_transactions as c_transaction ON c_transaction._user_id = _user.id
       _WHERE_