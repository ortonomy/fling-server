end;
-- drop the app databse if it already exists
DROP DATABASE IF EXISTS fling;




-- set some variables for our new users
\set flingadmin 'flingapp_admin'
\set flingpgql 'flingapp_postgraphql'
\set flinganon 'flingapp_anonymous'
\set flinguser 'flingapp_user'




-- drop all roles if they exist in postgres instance
DROP ROLE IF EXISTS :flingadmin;
DROP ROLE IF EXISTS :flingpgql;
DROP ROLE IF EXISTS :flinganon;
DROP ROLE IF EXISTS :flinguser;




-- set up your passwords here
\set adminpass 'FlingAppMakesItEasy'
\set pgqlpass 'YourFlingAppPassword'




-- create our database account owner and give it privileges
-- change the password to your own for installation
CREATE ROLE :flingadmin WITH LOGIN PASSWORD :'adminpass';

-- create our role that is used to login into postgres with postgraphql
-- change the password to your own for installation
CREATE ROLE :flingpgql WITH LOGIN PASSWORD :'pgqlpass';

-- create our role that will be the default user before user logs in
CREATE ROLE :flinganon;

-- create our role that will be the default user after user logs in
CREATE ROLE :flinguser;




-- create our awesome app db
CREATE DATABASE fling WITH OWNER :flingadmin;




-- grants
-- give flingapp all privileges to create the DB
GRANT ALL PRIVILEGES ON DATABASE fling TO :flingadmin;

-- make sure that the flingadmin can do everything the postgraphql user can do
GRANT :flingpgql to :flingadmin;

-- make sure that postgraphql user can do everything the anonymouse can.
GRANT :flinganon to :flingpgql;

-- make sure that postgraphql user can do everything a user can.
GRANT :flinguser to :flingpgql;



-- connect
\connect fling




-- db crypto setup for password hashing and salting
-- must be superuser to add this extension
CREATE EXTENSION IF NOT EXISTS pgcrypto; 




-- set role of future everything
--  we want the flingapp user to be the role that owns the tables so postgraphql has the correct permissions
SET ROLE :flingadmin;




-- SCHEMAS

-- remove the schemas if they exist
DROP SCHEMA IF EXISTS flingapp_private;
DROP SCHEMA IF EXISTS flingapp_custom;
DROP SCHEMA IF EXISTS flingapp;

-- create the app schema and then create tables
-- add schemas
CREATE SCHEMA IF NOT EXISTS flingapp AUTHORIZATION :flingadmin;
CREATE SCHEMA IF NOT EXISTS flingapp_private AUTHORIZATION :flingadmin;
CREATE SCHEMA IF NOT EXISTS flingapp_custom AUTHORIZATION :flingadmin;




-- TYPES

-- freelancer location. 
DROP TYPE IF EXISTS flingapp.country CASCADE;
CREATE TYPE flingapp.country AS ENUM(
  'Afghanistan',
  'Albania',
  'Algeria',
  'Andorra',
  'Angola',
  'Antigua & Deps',
  'Argentina',
  'Armenia',
  'Australia',
  'Austria',
  'Azerbaijan',
  'Bahamas',
  'Bahrain',
  'Bangladesh',
  'Barbados',
  'Belarus',
  'Belgium',
  'Belize',
  'Benin',
  'Bhutan',
  'Bolivia',
  'Bosnia Herzegovina',
  'Botswana',
  'Brazil',
  'Brunei',
  'Bulgaria',
  'Burkina',
  'Burundi',
  'Cambodia',
  'Cameroon',
  'Canada',
  'Cape Verde',
  'Central African Rep',
  'Chad',
  'Chile',
  'China',
  'Colombia',
  'Comoros',
  'Congo',
  'Congo (Democratic Republic of)',
  'Costa Rica',
  'Croatia',
  'Cuba',
  'Cyprus',
  'Czech Republic',
  'Denmark',
  'Djibouti',
  'Dominica',
  'Dominican Republic',
  'East Timor',
  'Ecuador',
  'Egypt',
  'El Salvador',
  'Equatorial Guinea',
  'Eritrea',
  'Estonia',
  'Ethiopia',
  'Fiji',
  'Finland',
  'France',
  'Gabon',
  'Gambia',
  'Georgia',
  'Germany',
  'Ghana',
  'Greece',
  'Grenada',
  'Guatemala',
  'Guinea',
  'Guinea-Bissau',
  'Guyana',
  'Haiti',
  'Honduras',
  'Hungary',
  'Iceland',
  'India',
  'Indonesia',
  'Iran',
  'Iraq',
  'Ireland (Republic of)',
  'Israel',
  'Italy',
  'Ivory Coast',
  'Jamaica',
  'Japan',
  'Jordan',
  'Kazakhstan',
  'Kenya',
  'Kiribati',
  'Korea North',
  'Korea South',
  'Kosovo',
  'Kuwait',
  'Kyrgyzstan',
  'Laos',
  'Latvia',
  'Lebanon',
  'Lesotho',
  'Liberia',
  'Libya',
  'Liechtenstein',
  'Lithuania',
  'Luxembourg',
  'Macedonia',
  'Madagascar',
  'Malawi',
  'Malaysia',
  'Maldives',
  'Mali',
  'Malta',
  'Marshall Islands',
  'Mauritania',
  'Mauritius',
  'Mexico',
  'Micronesia',
  'Moldova',
  'Monaco',
  'Mongolia',
  'Montenegro',
  'Morocco',
  'Mozambique',
  'Myanmar (Burma)',
  'Namibia',
  'Nauru',
  'Nepal',
  'Netherlands',
  'New Zealand',
  'Nicaragua',
  'Niger',
  'Nigeria',
  'Norway',
  'Oman',
  'Pakistan',
  'Palau',
  'Palestine',
  'Panama',
  'Papua New Guinea',
  'Paraguay',
  'Peru',
  'Philippines',
  'Poland',
  'Portugal',
  'Qatar',
  'Romania',
  'Russian Federation',
  'Rwanda',
  'St Kitts & Nevis',
  'St Lucia',
  'Saint Vincent & the Grenadines',
  'Samoa',
  'San Marino',
  'Sao Tome & Principe',
  'Saudi Arabia',
  'Senegal',
  'Serbia',
  'Seychelles',
  'Sierra Leone',
  'Singapore',
  'Slovakia',
  'Slovenia',
  'Solomon Islands',
  'Somalia',
  'South Africa',
  'South Sudan',
  'Spain',
  'Sri Lanka',
  'Sudan',
  'Suriname',
  'Swaziland',
  'Sweden',
  'Switzerland',
  'Syria',
  'Taiwan',
  'Tajikistan',
  'Tanzania',
  'Thailand',
  'Togo',
  'Tonga',
  'Trinidad & Tobago',
  'Tunisia',
  'Turkey',
  'Turkmenistan',
  'Tuvalu',
  'Uganda',
  'Ukraine',
  'United Arab Emirates',
  'United Kingdom',
  'United States',
  'Uruguay',
  'Uzbekistan',
  'Vanuatu',
  'Vatican City',
  'Venezuela',
  'Vietnam',
  'Yemen',
  'Zambia',
  'Zimbabwe'
);
-- comments for country 
COMMENT ON TYPE flingapp.country IS 'A type listing all the countries in the world';





-- languages that the freelancer can deploy
DROP TYPE IF EXISTS flingapp.language CASCADE;
CREATE TYPE flingapp.language AS ENUM(
  'Arfikaans',
  'Arabic',
  'Bengali',
  'Chinese (Mandarin)',
  'Chinese (Cantonese)',
  'Danish',
  'Dutch',  
  'English (Australia)',
  'English (UK)',
  'English (Canada)',
  'English (South Africa)',
  'English (New Zealand)',
  'English (US)',
  'Finnish',
  'French',
  'German',
  'Greek',
  'Hindi',
  'Indonesian',
  'Italian',
  'Japanse',
  'Javanese',
  'Korean',
  'Lahnda',
  'Malay',
  'Marathi',
  'Norwegian',
  'Polish',
  'Portuguese (Portugal)',
  'Portuguese (Brazil)',
  'Russian',
  'Spanish (Mexico)',
  'Spanish (Spain)',
  'Swedish',
  'Tamil',
  'Telugu',
  'Thai',
  'Turkish',
  'Urdu',
  'Vietnamese'
);
-- comments for languages
COMMENT ON TYPE flingapp.language IS 'A type listing all languages (within reason) that a freelancer can speak.';




-- timezone type
DROP TYPE IF EXISTS flingapp.timezone CASCADE;
CREATE TYPE flingapp.timezone AS ENUM(
  'Africa/Abidjan +00:00 (+00:00)',
  'Africa/Accra +00:00 (+00:00)',
  'Africa/Addis Ababa +03:00 (+03:00)',
  'Africa/Algiers +01:00 (+01:00)',
  'Africa/Asmara +03:00 (+03:00)',
  'Africa/Bamako +00:00 (+00:00)',
  'Africa/Bangui +01:00 (+01:00)',
  'Africa/Banjul +00:00 (+00:00)',
  'Africa/Bissau +00:00 (+00:00)',
  'Africa/Blantyre +02:00 (+02:00)',
  'Africa/Brazzaville +01:00 (+01:00)',
  'Africa/Bujumbura +02:00 (+02:00)',
  'Africa/Cairo +02:00 (+02:00)',
  'Africa/Casablanca +00:00 (+01:00)',
  'Africa/Ceuta +01:00 (+02:00)',
  'Africa/Conakry +00:00 (+00:00)',
  'Africa/Dakar +00:00 (+00:00)',
  'Africa/Dar es Salaam +03:00 (+03:00)',
  'Africa/Djibouti +03:00 (+03:00)',
  'Africa/Douala +01:00 (+01:00)',
  'Africa/El Aaiun +00:00 (+01:00)',
  'Africa/Freetown +00:00 (+00:00)',
  'Africa/Gaborone +02:00 (+02:00)',
  'Africa/Harare +02:00 (+02:00)',
  'Africa/Johannesburg +02:00 (+02:00)',
  'Africa/Juba +03:00 (+03:00)',
  'Africa/Kampala +03:00 (+03:00)',
  'Africa/Khartoum +03:00 (+03:00)',
  'Africa/Kigali +02:00 (+02:00)',
  'Africa/Kinshasa +01:00 (+01:00)',
  'Africa/Lagos +01:00 (+01:00)',
  'Africa/Libreville +01:00 (+01:00)',
  'Africa/Lome +00:00 (+00:00)',
  'Africa/Luanda +01:00 (+01:00)',
  'Africa/Lubumbashi +02:00 (+02:00)',
  'Africa/Lusaka +02:00 (+02:00)',
  'Africa/Malabo +01:00 (+01:00)',
  'Africa/Maputo +02:00 (+02:00)',
  'Africa/Maseru +02:00 (+02:00)',
  'Africa/Mbabane +02:00 (+02:00)',
  'Africa/Mogadishu +03:00 (+03:00)',
  'Africa/Monrovia +00:00 (+00:00)',
  'Africa/Nairobi +03:00 (+03:00)',
  'Africa/Ndjamena +01:00 (+01:00)',
  'Africa/Niamey +01:00 (+01:00)',
  'Africa/Nouakchott +00:00 (+00:00)',
  'Africa/Ouagadougou +00:00 (+00:00)',
  'Africa/Porto-Novo +01:00 (+01:00)',
  'Africa/Sao Tome +00:00 (+00:00)',
  'Africa/Timbuktu +00:00 (+00:00)',
  'Africa/Tripoli +02:00 (+02:00)',
  'Africa/Tunis +01:00 (+01:00)',
  'Africa/Windhoek +01:00 (+02:00)',
  'America/Adak -10:00 (-09:00)',
  'America/Anchorage -09:00 (-08:00)',
  'America/Anguilla -04:00 (-04:00)',
  'America/Antigua -04:00 (-04:00)',
  'America/Araguaina -03:00 (-03:00)',
  'America/Argentina/Buenos Aires -03:00 (-03:00)',
  'America/Argentina/Catamarca -03:00 (-03:00)',
  'America/Argentina/ComodRivadavia -03:00 (-03:00)',
  'America/Argentina/Cordoba -03:00 (-03:00)',
  'America/Argentina/Jujuy -03:00 (-03:00)',
  'America/Argentina/La Rioja -03:00 (-03:00)',
  'America/Argentina/Mendoza -03:00 (-03:00)',
  'America/Argentina/Rio Gallegos -03:00 (-03:00)',
  'America/Argentina/Salta -03:00 (-03:00)',
  'America/Argentina/San Juan -03:00 (-03:00)',
  'America/Argentina/San Luis -03:00 (-03:00)',
  'America/Argentina/Tucuman -03:00 (-03:00)',
  'America/Argentina/Ushuaia -03:00 (-03:00)',
  'America/Aruba -04:00 (-04:00)',
  'America/Asuncion -04:00 (-03:00)',
  'America/Atikokan -05:00 (-05:00)',
  'America/Atka -10:00 (-09:00)',
  'America/Bahia -03:00 (-03:00)',
  'America/Bahia Banderas -06:00 (-05:00)',
  'America/Barbados -04:00 (-04:00)',
  'America/Belem -03:00 (-03:00)',
  'America/Belize -06:00 (-06:00)',
  'America/Blanc-Sablon -04:00 (-04:00)',
  'America/Boa Vista -04:00 (-04:00)',
  'America/Bogota -05:00 (-05:00)',
  'America/Boise -07:00 (-06:00)',
  'America/Buenos Aires -03:00 (-03:00)',
  'America/Cambridge Bay -07:00 (-06:00)',
  'America/Campo Grande -04:00 (-03:00)',
  'America/Cancun -05:00 (-05:00)',
  'America/Caracas -04:00 (-04:00)',
  'America/Catamarca -03:00 (-03:00)',
  'America/Cayenne -03:00 (-03:00)',
  'America/Cayman -05:00 (-05:00)',
  'America/Chicago -06:00 (-05:00)',
  'America/Chihuahua -07:00 (-06:00)',
  'America/Coral Harbour -05:00 (-05:00)',
  'America/Cordoba -03:00 (-03:00)',
  'America/Costa Rica -06:00 (-06:00)',
  'America/Creston -07:00 (-07:00)',
  'America/Cuiaba -04:00 (-03:00)',
  'America/Curacao -04:00 (-04:00)',
  'America/Danmarkshavn +00:00 (+00:00)',
  'America/Dawson -08:00 (-07:00)',
  'America/Dawson Creek -07:00 (-07:00)',
  'America/Denver -07:00 (-06:00)',
  'America/Detroit -05:00 (-04:00)',
  'America/Dominica -04:00 (-04:00)',
  'America/Edmonton -07:00 (-06:00)',
  'America/Eirunepe -05:00 (-05:00)',
  'America/El Salvador -06:00 (-06:00)',
  'America/Ensenada -08:00 (-07:00)',
  'America/Fort Nelson -07:00 (-07:00)',
  'America/Fort Wayne -05:00 (-04:00)',
  'America/Fortaleza -03:00 (-03:00)',
  'America/Glace Bay -04:00 (-03:00)',
  'America/Godthab -03:00 (-02:00)',
  'America/Goose Bay -04:00 (-03:00)',
  'America/Grand Turk -04:00 (-04:00)',
  'America/Grenada -04:00 (-04:00)',
  'America/Guadeloupe -04:00 (-04:00)',
  'America/Guatemala -06:00 (-06:00)',
  'America/Guayaquil -05:00 (-05:00)',
  'America/Guyana -04:00 (-04:00)',
  'America/Halifax -04:00 (-03:00)',
  'America/Havana -05:00 (-04:00)',
  'America/Hermosillo -07:00 (-07:00)',
  'America/Indiana/Indianapolis -05:00 (-04:00)',
  'America/Indiana/Knox -06:00 (-05:00)',
  'America/Indiana/Marengo -05:00 (-04:00)',
  'America/Indiana/Petersburg -05:00 (-04:00)',
  'America/Indiana/Tell City -06:00 (-05:00)',
  'America/Indiana/Vevay -05:00 (-04:00)',
  'America/Indiana/Vincennes -05:00 (-04:00)',
  'America/Indiana/Winamac -05:00 (-04:00)',
  'America/Indianapolis -05:00 (-04:00)',
  'America/Inuvik -07:00 (-06:00)',
  'America/Iqaluit -05:00 (-04:00)',
  'America/Jamaica -05:00 (-05:00)',
  'America/Jujuy -03:00 (-03:00)',
  'America/Juneau -09:00 (-08:00)',
  'America/Kentucky/Louisville -05:00 (-04:00)',
  'America/Kentucky/Monticello -05:00 (-04:00)',
  'America/Knox IN -06:00 (-05:00)',
  'America/Kralendijk -04:00 (-04:00)',
  'America/La Paz -04:00 (-04:00)',
  'America/Lima -05:00 (-05:00)',
  'America/Los Angeles -08:00 (-07:00)',
  'America/Louisville -05:00 (-04:00)',
  'America/Lower Princes -04:00 (-04:00)',
  'America/Maceio -03:00 (-03:00)',
  'America/Managua -06:00 (-06:00)',
  'America/Manaus -04:00 (-04:00)',
  'America/Marigot -04:00 (-04:00)',
  'America/Martinique -04:00 (-04:00)',
  'America/Matamoros -06:00 (-05:00)',
  'America/Mazatlan -07:00 (-06:00)',
  'America/Mendoza -03:00 (-03:00)',
  'America/Menominee -06:00 (-05:00)',
  'America/Merida -06:00 (-05:00)',
  'America/Metlakatla -09:00 (-08:00)',
  'America/Mexico City -06:00 (-05:00)',
  'America/Miquelon -03:00 (-02:00)',
  'America/Moncton -04:00 (-03:00)',
  'America/Monterrey -06:00 (-05:00)',
  'America/Montevideo -03:00 (-03:00)',
  'America/Montreal -05:00 (-04:00)',
  'America/Montserrat -04:00 (-04:00)',
  'America/Nassau -05:00 (-04:00)',
  'America/New York -05:00 (-04:00)',
  'America/Nipigon -05:00 (-04:00)',
  'America/Nome -09:00 (-08:00)',
  'America/Noronha -02:00 (-02:00)',
  'America/North Dakota/Beulah -06:00 (-05:00)',
  'America/North Dakota/Center -06:00 (-05:00)',
  'America/North Dakota/New Salem -06:00 (-05:00)',
  'America/Ojinaga -07:00 (-06:00)',
  'America/Panama -05:00 (-05:00)',
  'America/Pangnirtung -05:00 (-04:00)',
  'America/Paramaribo -03:00 (-03:00)',
  'America/Phoenix -07:00 (-07:00)',
  'America/Port of Spain -04:00 (-04:00)',
  'America/Port-au-Prince -05:00 (-04:00)',
  'America/Porto Acre -05:00 (-05:00)',
  'America/Porto Velho -04:00 (-04:00)',
  'America/Puerto Rico -04:00 (-04:00)',
  'America/Punta Arenas -03:00 (-03:00)',
  'America/Rainy River -06:00 (-05:00)',
  'America/Rankin Inlet -06:00 (-05:00)',
  'America/Recife -03:00 (-03:00)',
  'America/Regina -06:00 (-06:00)',
  'America/Resolute -06:00 (-05:00)',
  'America/Rio Branco -05:00 (-05:00)',
  'America/Rosario -03:00 (-03:00)',
  'America/Santa Isabel -08:00 (-07:00)',
  'America/Santarem -03:00 (-03:00)',
  'America/Santiago -04:00 (-03:00)',
  'America/Santo Domingo -04:00 (-04:00)',
  'America/Sao Paulo -03:00 (-02:00)',
  'America/Scoresbysund -01:00 (+00:00)',
  'America/Shiprock -07:00 (-06:00)',
  'America/Sitka -09:00 (-08:00)',
  'America/St Barthelemy -04:00 (-04:00)',
  'America/St Johns -03:30 (-02:30)',
  'America/St Kitts -04:00 (-04:00)',
  'America/St Lucia -04:00 (-04:00)',
  'America/St Thomas -04:00 (-04:00)',
  'America/St Vincent -04:00 (-04:00)',
  'America/Swift Current -06:00 (-06:00)',
  'America/Tegucigalpa -06:00 (-06:00)',
  'America/Thule -04:00 (-03:00)',
  'America/Thunder Bay -05:00 (-04:00)',
  'America/Tijuana -08:00 (-07:00)',
  'America/Toronto -05:00 (-04:00)',
  'America/Tortola -04:00 (-04:00)',
  'America/Vancouver -08:00 (-07:00)',
  'America/Virgin -04:00 (-04:00)',
  'America/Whitehorse -08:00 (-07:00)',
  'America/Winnipeg -06:00 (-05:00)',
  'America/Yakutat -09:00 (-08:00)',
  'America/Yellowknife -07:00 (-06:00)',
  'Antarctica/Casey +11:00 (+11:00)',
  'Antarctica/Davis +07:00 (+07:00)',
  'Antarctica/DumontDUrville +10:00 (+10:00)',
  'Antarctica/Macquarie +11:00 (+11:00)',
  'Antarctica/Mawson +05:00 (+05:00)',
  'Antarctica/McMurdo +12:00 (+13:00)',
  'Antarctica/Palmer -03:00 (-03:00)',
  'Antarctica/Rothera -03:00 (-03:00)',
  'Antarctica/South Pole +12:00 (+13:00)',
  'Antarctica/Syowa +03:00 (+03:00)',
  'Antarctica/Troll +00:00 (+02:00)',
  'Antarctica/Vostok +06:00 (+06:00)',
  'Arctic/Longyearbyen +01:00 (+02:00)',
  'Asia/Aden +03:00 (+03:00)',
  'Asia/Almaty +06:00 (+06:00)',
  'Asia/Amman +02:00 (+03:00)',
  'Asia/Anadyr +12:00 (+12:00)',
  'Asia/Aqtau +05:00 (+05:00)',
  'Asia/Aqtobe +05:00 (+05:00)',
  'Asia/Ashgabat +05:00 (+05:00)',
  'Asia/Ashkhabad +05:00 (+05:00)',
  'Asia/Atyrau +05:00 (+05:00)',
  'Asia/Baghdad +03:00 (+03:00)',
  'Asia/Bahrain +03:00 (+03:00)',
  'Asia/Baku +04:00 (+04:00)',
  'Asia/Bangkok +07:00 (+07:00)',
  'Asia/Barnaul +07:00 (+07:00)',
  'Asia/Beirut +02:00 (+03:00)',
  'Asia/Bishkek +06:00 (+06:00)',
  'Asia/Brunei +08:00 (+08:00)',
  'Asia/Calcutta +05:30 (+05:30)',
  'Asia/Chita +09:00 (+09:00)',
  'Asia/Choibalsan +08:00 (+08:00)',
  'Asia/Chongqing +08:00 (+08:00)',
  'Asia/Chungking +08:00 (+08:00)',
  'Asia/Colombo +05:30 (+05:30)',
  'Asia/Dacca +06:00 (+06:00)',
  'Asia/Damascus +02:00 (+03:00)',
  'Asia/Dhaka +06:00 (+06:00)',
  'Asia/Dili +09:00 (+09:00)',
  'Asia/Dubai +04:00 (+04:00)',
  'Asia/Dushanbe +05:00 (+05:00)',
  'Asia/Famagusta +03:00 (+03:00)',
  'Asia/Gaza +02:00 (+03:00)',
  'Asia/Harbin +08:00 (+08:00)',
  'Asia/Hebron +02:00 (+03:00)',
  'Asia/Ho Chi Minh +07:00 (+07:00)',
  'Asia/Hong Kong +08:00 (+08:00)',
  'Asia/Hovd +07:00 (+07:00)',
  'Asia/Irkutsk +08:00 (+08:00)',
  'Asia/Istanbul +03:00 (+03:00)',
  'Asia/Jakarta +07:00 (+07:00)',
  'Asia/Jayapura +09:00 (+09:00)',
  'Asia/Jerusalem +02:00 (+03:00)',
  'Asia/Kabul +04:30 (+04:30)',
  'Asia/Kamchatka +12:00 (+12:00)',
  'Asia/Karachi +05:00 (+05:00)',
  'Asia/Kashgar +06:00 (+06:00)',
  'Asia/Kathmandu +05:45 (+05:45)',
  'Asia/Katmandu +05:45 (+05:45)',
  'Asia/Khandyga +09:00 (+09:00)',
  'Asia/Kolkata +05:30 (+05:30)',
  'Asia/Krasnoyarsk +07:00 (+07:00)',
  'Asia/Kuala Lumpur +08:00 (+08:00)',
  'Asia/Kuching +08:00 (+08:00)',
  'Asia/Kuwait +03:00 (+03:00)',
  'Asia/Macao +08:00 (+08:00)',
  'Asia/Macau +08:00 (+08:00)',
  'Asia/Magadan +11:00 (+11:00)',
  'Asia/Makassar +08:00 (+08:00)',
  'Asia/Manila +08:00 (+08:00)',
  'Asia/Muscat +04:00 (+04:00)',
  'Asia/Nicosia +02:00 (+03:00)',
  'Asia/Novokuznetsk +07:00 (+07:00)',
  'Asia/Novosibirsk +07:00 (+07:00)',
  'Asia/Omsk +06:00 (+06:00)',
  'Asia/Oral +05:00 (+05:00)',
  'Asia/Phnom Penh +07:00 (+07:00)',
  'Asia/Pontianak +07:00 (+07:00)',
  'Asia/Pyongyang +08:30 (+08:30)',
  'Asia/Qatar +03:00 (+03:00)',
  'Asia/Qyzylorda +06:00 (+06:00)',
  'Asia/Rangoon +06:30 (+06:30)',
  'Asia/Riyadh +03:00 (+03:00)',
  'Asia/Saigon +07:00 (+07:00)',
  'Asia/Sakhalin +11:00 (+11:00)',
  'Asia/Samarkand +05:00 (+05:00)',
  'Asia/Seoul +09:00 (+09:00)',
  'Asia/Shanghai +08:00 (+08:00)',
  'Asia/Singapore +08:00 (+08:00)',
  'Asia/Srednekolymsk +11:00 (+11:00)',
  'Asia/Taipei +08:00 (+08:00)',
  'Asia/Tashkent +05:00 (+05:00)',
  'Asia/Tbilisi +04:00 (+04:00)',
  'Asia/Tehran +03:30 (+04:30)',
  'Asia/Tel Aviv +02:00 (+03:00)',
  'Asia/Thimbu +06:00 (+06:00)',
  'Asia/Thimphu +06:00 (+06:00)',
  'Asia/Tokyo +09:00 (+09:00)',
  'Asia/Tomsk +07:00 (+07:00)',
  'Asia/Ujung Pandang +08:00 (+08:00)',
  'Asia/Ulaanbaatar +08:00 (+08:00)',
  'Asia/Ulan Bator +08:00 (+08:00)',
  'Asia/Urumqi +06:00 (+06:00)',
  'Asia/Ust-Nera +10:00 (+10:00)',
  'Asia/Vientiane +07:00 (+07:00)',
  'Asia/Vladivostok +10:00 (+10:00)',
  'Asia/Yakutsk +09:00 (+09:00)',
  'Asia/Yangon +06:30 (+06:30)',
  'Asia/Yekaterinburg +05:00 (+05:00)',
  'Asia/Yerevan +04:00 (+04:00)',
  'Atlantic/Azores -01:00 (+00:00)',
  'Atlantic/Bermuda -04:00 (-03:00)',
  'Atlantic/Canary +00:00 (+01:00)',
  'Atlantic/Cape Verde -01:00 (-01:00)',
  'Atlantic/Faeroe +00:00 (+01:00)',
  'Atlantic/Faroe +00:00 (+01:00)',
  'Atlantic/Jan Mayen +01:00 (+02:00)',
  'Atlantic/Madeira +00:00 (+01:00)',
  'Atlantic/Reykjavik +00:00 (+00:00)',
  'Atlantic/South Georgia -02:00 (-02:00)',
  'Atlantic/St Helena +00:00 (+00:00)',
  'Atlantic/Stanley -03:00 (-03:00)',
  'Australia/ACT +10:00 (+11:00)',
  'Australia/Adelaide +09:30 (+10:30)',
  'Australia/Brisbane +10:00 (+10:00)',
  'Australia/Broken Hill +09:30 (+10:30)',
  'Australia/Canberra +10:00 (+11:00)',
  'Australia/Currie +10:00 (+11:00)',
  'Australia/Darwin +09:30 (+09:30)',
  'Australia/Eucla +08:45 (+08:45)',
  'Australia/Hobart +10:00 (+11:00)',
  'Australia/LHI +10:30 (+11:00)',
  'Australia/Lindeman +10:00 (+10:00)',
  'Australia/Lord Howe +10:30 (+11:00)',
  'Australia/Melbourne +10:00 (+11:00)',
  'Australia/North +09:30 (+09:30)',
  'Australia/NSW +10:00 (+11:00)',
  'Australia/Perth +08:00 (+08:00)',
  'Australia/Queensland +10:00 (+10:00)',
  'Australia/South +09:30 (+10:30)',
  'Australia/Sydney +10:00 (+11:00)',
  'Australia/Tasmania +10:00 (+11:00)',
  'Australia/Victoria +10:00 (+11:00)',
  'Australia/West +08:00 (+08:00)',
  'Australia/Yancowinna +09:30 (+10:30)',
  'Brazil/Acre -05:00 (-05:00)',
  'Brazil/DeNoronha -02:00 (-02:00)',
  'Brazil/East -03:00 (-02:00)',
  'Brazil/West -04:00 (-04:00)',
  'Canada/Atlantic -04:00 (-03:00)',
  'Canada/Central -06:00 (-05:00)',
  'Canada/East-Saskatchewan -06:00 (-06:00)',
  'Canada/Eastern -05:00 (-04:00)',
  'Canada/Mountain -07:00 (-06:00)',
  'Canada/Newfoundland -03:30 (-02:30)',
  'Canada/Pacific -08:00 (-07:00)',
  'Canada/Saskatchewan -06:00 (-06:00)',
  'Canada/Yukon -08:00 (-07:00)',
  'Chile/Continental -04:00 (-03:00)',
  'Chile/EasterIsland -06:00 (-05:00)',
  'Europe/Amsterdam +01:00 (+02:00)',
  'Europe/Andorra +01:00 (+02:00)',
  'Europe/Astrakhan +04:00 (+04:00)',
  'Europe/Athens +02:00 (+03:00)',
  'Europe/Belfast +00:00 (+01:00)',
  'Europe/Belgrade +01:00 (+02:00)',
  'Europe/Berlin +01:00 (+02:00)',
  'Europe/Bratislava +01:00 (+02:00)',
  'Europe/Brussels +01:00 (+02:00)',
  'Europe/Bucharest +02:00 (+03:00)',
  'Europe/Budapest +01:00 (+02:00)',
  'Europe/Busingen +01:00 (+02:00)',
  'Europe/Chisinau +02:00 (+03:00)',
  'Europe/Copenhagen +01:00 (+02:00)',
  'Europe/Dublin +00:00 (+01:00)',
  'Europe/Gibraltar +01:00 (+02:00)',
  'Europe/Guernsey +00:00 (+01:00)',
  'Europe/Helsinki +02:00 (+03:00)',
  'Europe/Isle of Man +00:00 (+01:00)',
  'Europe/Istanbul +03:00 (+03:00)',
  'Europe/Jersey +00:00 (+01:00)',
  'Europe/Kaliningrad +02:00 (+02:00)',
  'Europe/Kiev +02:00 (+03:00)',
  'Europe/Kirov +03:00 (+03:00)',
  'Europe/Lisbon +00:00 (+01:00)',
  'Europe/Ljubljana +01:00 (+02:00)',
  'Europe/London +00:00 (+01:00)',
  'Europe/Luxembourg +01:00 (+02:00)',
  'Europe/Madrid +01:00 (+02:00)',
  'Europe/Malta +01:00 (+02:00)',
  'Europe/Mariehamn +02:00 (+03:00)',
  'Europe/Minsk +03:00 (+03:00)',
  'Europe/Monaco +01:00 (+02:00)',
  'Europe/Moscow +03:00 (+03:00)',
  'Europe/Nicosia +02:00 (+03:00)',
  'Europe/Oslo +01:00 (+02:00)',
  'Europe/Paris +01:00 (+02:00)',
  'Europe/Podgorica +01:00 (+02:00)',
  'Europe/Prague +01:00 (+02:00)',
  'Europe/Riga +02:00 (+03:00)',
  'Europe/Rome +01:00 (+02:00)',
  'Europe/Samara +04:00 (+04:00)',
  'Europe/San Marino +01:00 (+02:00)',
  'Europe/Sarajevo +01:00 (+02:00)',
  'Europe/Saratov +04:00 (+04:00)',
  'Europe/Simferopol +03:00 (+03:00)',
  'Europe/Skopje +01:00 (+02:00)',
  'Europe/Sofia +02:00 (+03:00)',
  'Europe/Stockholm +01:00 (+02:00)',
  'Europe/Tallinn +02:00 (+03:00)',
  'Europe/Tirane +01:00 (+02:00)',
  'Europe/Tiraspol +02:00 (+03:00)',
  'Europe/Ulyanovsk +04:00 (+04:00)',
  'Europe/Uzhgorod +02:00 (+03:00)',
  'Europe/Vaduz +01:00 (+02:00)',
  'Europe/Vatican +01:00 (+02:00)',
  'Europe/Vienna +01:00 (+02:00)',
  'Europe/Vilnius +02:00 (+03:00)',
  'Europe/Volgograd +03:00 (+03:00)',
  'Europe/Warsaw +01:00 (+02:00)',
  'Europe/Zagreb +01:00 (+02:00)',
  'Europe/Zaporozhye +02:00 (+03:00)',
  'Europe/Zurich +01:00 (+02:00)',
  'Indian/Antananarivo +03:00 (+03:00)',
  'Indian/Chagos +06:00 (+06:00)',
  'Indian/Christmas +07:00 (+07:00)',
  'Indian/Cocos +06:30 (+06:30)',
  'Indian/Comoro +03:00 (+03:00)',
  'Indian/Kerguelen +05:00 (+05:00)',
  'Indian/Mahe +04:00 (+04:00)',
  'Indian/Maldives +05:00 (+05:00)',
  'Indian/Mauritius +04:00 (+04:00)',
  'Indian/Mayotte +03:00 (+03:00)',
  'Indian/Reunion +04:00 (+04:00)',
  'Pacific/Apia +13:00 (+14:00)',
  'Pacific/Auckland +12:00 (+13:00)',
  'Pacific/Bougainville +11:00 (+11:00)',
  'Pacific/Chatham +12:45 (+13:45)',
  'Pacific/Chuuk +10:00 (+10:00)',
  'Pacific/Easter -06:00 (-05:00)',
  'Pacific/Efate +11:00 (+11:00)',
  'Pacific/Enderbury +13:00 (+13:00)',
  'Pacific/Fakaofo +13:00 (+13:00)',
  'Pacific/Fiji +12:00 (+13:00)',
  'Pacific/Funafuti +12:00 (+12:00)',
  'Pacific/Galapagos -06:00 (-06:00)',
  'Pacific/Gambier -09:00 (-09:00)',
  'Pacific/Guadalcanal +11:00 (+11:00)',
  'Pacific/Guam +10:00 (+10:00)',
  'Pacific/Honolulu -10:00 (-10:00)',
  'Pacific/Johnston -10:00 (-10:00)',
  'Pacific/Kiritimati +14:00 (+14:00)',
  'Pacific/Kosrae +11:00 (+11:00)',
  'Pacific/Kwajalein +12:00 (+12:00)',
  'Pacific/Majuro +12:00 (+12:00)',
  'Pacific/Marquesas -09:30 (-09:30)',
  'Pacific/Midway -11:00 (-11:00)',
  'Pacific/Nauru +12:00 (+12:00)',
  'Pacific/Niue -11:00 (-11:00)',
  'Pacific/Norfolk +11:00 (+11:00)',
  'Pacific/Noumea +11:00 (+11:00)',
  'Pacific/Pago Pago -11:00 (-11:00)',
  'Pacific/Palau +09:00 (+09:00)',
  'Pacific/Pitcairn -08:00 (-08:00)',
  'Pacific/Pohnpei +11:00 (+11:00)',
  'Pacific/Ponape +11:00 (+11:00)',
  'Pacific/Port Moresby +10:00 (+10:00)',
  'Pacific/Rarotonga -10:00 (-10:00)',
  'Pacific/Saipan +10:00 (+10:00)',
  'Pacific/Samoa -11:00 (-11:00)',
  'Pacific/Tahiti -10:00 (-10:00)',
  'Pacific/Tarawa +12:00 (+12:00)',
  'Pacific/Tongatapu +13:00 (+14:00)',
  'Pacific/Truk +10:00 (+10:00)',
  'Pacific/Wake +12:00 (+12:00)',
  'Pacific/Wallis +12:00 (+12:00)',
  'Pacific/Yap +10:00 (+10:00)',
  'UTC +00:00 (+00:00)'
);
-- comments for timezone
COMMENT ON TYPE flingapp.timezone IS 'A type listing all the timezones on Earth including DST adjustments (if any)';




-- freelancer employment status 
DROP TYPE IF EXISTS flingapp.employment_status CASCADE;
CREATE TYPE flingapp.employment_status AS ENUM(
  'full-time fixed schedule',
  'part-time fixed schedule',
  'full-time flexible schedule',
  'part-time flexible schedule',
  'flexible schedule'
);
COMMENT ON TYPE flingapp.employment_status IS 'A list of all the employment statuses for freelancers';




-- currency types for project payments
DROP TYPE IF EXISTS flingapp.payment_currency CASCADE;
CREATE TYPE flingapp.payment_currency AS ENUM(
  'CNY',
  'EUR',
  'GBP',
  'USD'
);
COMMENT ON TYPE flingapp.payment_currency IS 'A list of all the possible payment currencies';




--  text note types
DROP TYPE IF EXISTS flingapp.text_note_types CASCADE;
CREATE TYPE flingapp.text_note_types AS ENUM(
  'tag',
  'comment',
  'note'
);
COMMENT ON TYPE flingapp.payment_currency IS 'A list of all the possible text note types';




-- user type
DROP TYPE IF EXISTS flingapp.user_type CASCADE;
CREATE TYPE flingapp.user_type AS ENUM(
  'USER',
  'FREELANCER'
);
COMMENT ON TYPE flingapp.user_type IS 'A list of all the possible interactive user types';




-- TABLES

-- 1. our core app user private account information
CREATE TABLE flingapp_private.user_account(
  user_acc_id UUID NOT NULL DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL CHECK (user_email ~* '^.+@.+\..+$'),
  user_email_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
  user_email_confirm_token_selector TEXT DEFAULT NULL,
  user_email_confirm_token_verifier_hash TEXT DEFAULT NULL,
  user_password_hash TEXT NOT NULL,
  user_password_reset_requested BOOLEAN NOT NULL DEFAULT FALSE,
  user_password_reset_token_selector TEXT DEFAULT NULL,
  user_password_reset_token_verifier_hash TEXT DEFAULT NULL,
  user_password_reset_token_expiry TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  -- keys
  CONSTRAINT user_user_acc_pkey PRIMARY KEY (user_acc_id),
  CONSTRAINT user_account_user_email_key UNIQUE (user_email)
);
-- comments for user_account
COMMENT ON TABLE flingapp_private.user_account IS 'A human user''s account information with fling app';
COMMENT ON COLUMN flingapp_private.user_account.user_acc_id IS 'The universally unique ID of a user account of flingapp';
COMMENT ON COLUMN flingapp_private.user_account.user_email IS 'The unique email address of a user - a user cannot register with the same email twice.';
COMMENT ON COLUMN flingapp_private.user_account.user_email_confirmed IS 'Whether or not the user has confirmed their email address.';
COMMENT ON COLUMN flingapp_private.user_account.user_email_confirm_token_selector IS 'The first part (selector) of the split token for email verifications';
COMMENT ON COLUMN flingapp_private.user_account.user_email_confirm_token_verifier_hash IS 'The salted hash of the second part (verifier) of the split token for email verifications';
COMMENT ON COLUMN flingapp_private.user_account.user_password_hash IS 'The salted password hash of a user account.';
COMMENT ON COLUMN flingapp_private.user_account.user_password_reset_requested IS 'Is a password reset request active or not?';
COMMENT ON COLUMN flingapp_private.user_account.user_password_reset_token_selector IS 'The first part (selector) of the split token for password resets';
COMMENT ON COLUMN flingapp_private.user_account.user_password_reset_token_verifier_hash IS 'The salted hash of the second part (verifier) of the split token for password resets';
COMMENT ON COLUMN flingapp_private.user_account.user_password_reset_token_expiry IS 'The timestamp for when the password reset expires.';
COMMENT ON COLUMN flingapp_private.user_account.created_at IS 'The timestamp when the user was created.';
COMMENT ON COLUMN flingapp_private.user_account.updated_at IS 'The timestamp when the user was last updated';




-- 2. our core app user profile information 
CREATE TABLE flingapp_custom.user(
  user_id UUID NOT NULL,
  user_first_name TEXT NOT NULL,
  user_last_name TEXT NOT NULL,
  user_org UUID DEFAULT NULL,
  user_type flingapp.user_type NOT NULL DEFAULT 'USER',
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
  -- keys
  CONSTRAINT user_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_id_fkey FOREIGN KEY (user_id)
    REFERENCES flingapp_private.user_account(user_acc_id) MATCH SIMPLE
    ON DELETE CASCADE
);
-- comments for user
COMMENT ON TABLE flingapp_custom.user IS 'A human user of flingapp';
COMMENT ON COLUMN flingapp_custom.user.user_id IS 'The universally unique ID of a user of flingapp. References flingapp account.';
COMMENT ON COLUMN flingapp_custom.user.user_first_name IS 'The first, or given name, of a user of flingapp';
COMMENT ON COLUMN flingapp_custom.user.user_last_name IS 'The family name, or last name, of a user of flingapp';
COMMENT ON COLUMN flingapp_custom.user.user_org IS 'The universally unique ID of an organization that the user belongs to';
COMMENT ON COLUMN flingapp_custom.user.user_type IS 'The type of user, default: USER';
COMMENT ON COLUMN flingapp_custom.user.created_at IS 'The timestamp when the user was created';
COMMENT ON COLUMN flingapp_custom.user.updated_at IS 'The timestamp when the user was last updated';

-- 3. an organization that is using flingapp
CREATE TABLE flingapp.organization(
  org_id UUID NOT NULL DEFAULT gen_random_uuid(),
  org_name TEXT NOT NULL,
  org_admin UUID NOT NULL,
  org_domain TEXT DEFAULT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  -- keys
  CONSTRAINT organization_pkey PRIMARY KEY (org_id),
  CONSTRAINT organization_org_name UNIQUE (org_name),
  CONSTRAINT organization_org_admin_key UNIQUE (org_admin),
  CONSTRAINT organization_org_domain_key UNIQUE (org_domain),
  CONSTRAINT organization_org_admin_fkey FOREIGN KEY (org_admin)
    REFERENCES flingapp_custom.user(user_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for organization
COMMENT ON TABLE flingapp.organization IS 'An organization that freelancers and users can belong to.';
COMMENT ON COLUMN flingapp.organization.org_id IS 'The universally unique ID of an organization';
COMMENT ON COLUMN flingapp.organization.org_name IS 'An organization''s name';
COMMENT ON COLUMN flingapp.organization.org_name IS 'A UUID of a user who is the assigned admin of this organization. References users.';
COMMENT ON COLUMN flingapp.organization.org_domain IS 'A unique FQDN used to help a user find their organization. E.g. example.com'; 
COMMENT ON COLUMN flingapp.organization.created_at IS 'The timestamp when the organization was created.'; 
COMMENT ON COLUMN flingapp.organization.updated_at IS 'The timestamp when the organization was last updated.'; 


-- quick fix for table #2 only existing after creation
ALTER TABLE IF EXISTS flingapp_custom.user
  ADD CONSTRAINT user_org_fkey FOREIGN KEY (user_org)
    REFERENCES flingapp.organization(org_id) MATCH SIMPLE;


-- -- 4. many-to-many mapping table of organization to users
-- CREATE TABLE flingapp.user_org_map(
--   user_org_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
--   user_org_map_org_id UUID NOT NULL,
--   user_org_map_user_id UUID NOT NULL,
--   user_org_map_user_type flingapp.user_type NOT NULL DEFAULT 'FREELANCER',
--   user_org_map_org_access BOOLEAN NOT NULL DEFAULT FALSE,
--   user_org_map_org_access_requested BOOLEAN NOT NULL DEFAULT FALSE,
--   user_org_map_org_access_key_selector TEXT DEFAULT NULL,
--   user_org_map_org_access_key_verifier_hash TEXT DEFAULT NULL,
--   -- keys
--   CONSTRAINT user_org_map_id_pkey PRIMARY KEY (user_org_map_id),
--   CONSTRAINT user_org_map_ukey UNIQUE (user_org_map_org_id, user_org_map_user_id),
--   CONSTRAINT user_org_map_organization_fkey FOREIGN KEY (user_org_map_org_id)
--     REFERENCES flingapp.organization(org_id) MATCH SIMPLE
--     ON DELETE RESTRICT,
--   CONSTRAINT users_org_map_user_fkey FOREIGN KEY (user_org_map_user_id)
--     REFERENCES flingapp_custom.user(user_id) MATCH SIMPLE
--     ON DELETE CASCADE
-- );
-- -- comments for user account to organization many-to-many
-- COMMENT ON TABLE flingapp.user_org_map IS 'A many-to-many mapping of users to organizations';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_id IS 'The universally unique ID of a user to organization map entry';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_org_id IS 'An organization''s name - references organization table';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_user_id IS 'A UUID of a user. References users.';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_user_type IS 'A type for the user - organization user or a freelancer';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_org_access IS 'Does the user have access to this org yet?';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_org_access_requested IS 'Whether the user has requested access to this org';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_org_access_key_selector IS 'The first part (selector) of the split token for requesting access to an organization';
-- COMMENT ON COLUMN flingapp.user_org_map.user_org_map_org_access_key_verifier_hash IS 'The salted hash of the second part (verifier) of the split token for requesting access to an organization';

-- 5. core freelancer entity
CREATE TABLE flingapp.freelancer(
  fl_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_first_name TEXT NOT NULL DEFAULT 'John',
  fl_last_name TEXT NOT NULL DEFAULT 'Doe',
  fl_is_native_speaker BOOLEAN NOT NULL DEFAULT true,
  fl_assessment_submitted BOOLEAN NOT NULL DEFAULT false,
  fl_assessment_passed BOOLEAN NOT NULL DEFAULT false,
  fl_location flingapp.country NOT NULL,
  fl_timezone flingapp.timezone NOT NULL DEFAULT 'UTC +00:00 (+00:00)',
  fl_primary_language flingapp.language NOT NULL,
  fl_employment_status flingapp.employment_status NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  CONSTRAINT freelancer_fl_id_pkey PRIMARY KEY (fl_id)
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.freelancer IS 'A freelancer added to fling; Can be attached to a project and workhistory.';
COMMENT ON COLUMN flingapp.freelancer.fl_id IS 'The universally unique ID of a freelancer in the flingapp db';
COMMENT ON COLUMN flingapp.freelancer.fl_first_name IS 'A freelancer''s first, or given name';
COMMENT ON COLUMN flingapp.freelancer.fl_last_name IS 'A freelancer''s last, or family name';
COMMENT ON COLUMN flingapp.freelancer.fl_is_native_speaker IS 'Whether or not the freelancer is a native speaker of organization''s primary language.';
COMMENT ON COLUMN flingapp.freelancer.fl_assessment_submitted IS 'Whether the freelancer has successfully submitted a freelancer assessment.';
COMMENT ON COLUMN flingapp.freelancer.fl_assessment_passed IS 'Whether the freelancer successfully passed a freelancer assessment.';
COMMENT ON COLUMN flingapp.freelancer.fl_location IS 'Where the freelancer is located. Is a country enum type.'; 
COMMENT ON COLUMN flingapp.freelancer.fl_timezone IS 'Which timezone the freelancer is in. Is a tz database (https://www.iana.org/time-zones) timezone enum type.'; 
COMMENT ON COLUMN flingapp.freelancer.fl_primary_language IS 'Which languages a freelancer primarily communicates in. Is a language enum type.';  
COMMENT ON COLUMN flingapp.freelancer.fl_employment_status IS 'How is the freelancer currently employed. Is an employment status enum type.';  
COMMENT ON COLUMN flingapp.freelancer.created_at IS 'The time at which the freelancer record was created';  
COMMENT ON COLUMN flingapp.freelancer.updated_at IS 'The time at which the freelancer record was last updated';  

-- 6. unique roles for any freelancers within your organization
CREATE TABLE flingapp.freelancer_role(
  fl_role_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_role TEXT NOT NULL UNIQUE,
  CONSTRAINT freelancer_role_pkey PRIMARY KEY (fl_role_id),
  CONSTRAINT freelancer_role_role_key UNIQUE (fl_role)
);
-- comments for the freelancer roles
COMMENT ON TABLE flingapp.freelancer_role IS 'A role that a freelancer can be assigned';
COMMENT ON COLUMN flingapp.freelancer_role.fl_role_id IS 'The universally unique ID of a role';
COMMENT ON COLUMN flingapp.freelancer_role.fl_role IS 'The text description of a role';

-- 7. many-to-many mapping between freelancers and roles within your org
CREATE TABLE flingapp.freelancer_role_map(
  fl_role_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_role_map_role UUID NOT NULL,
  fl_role_map_freelancer UUID NOT NULL,
  CONSTRAINT freelancer_role_map_key UNIQUE (fl_role_map_id),
  CONSTRAINT freelancer_role_map_pkey PRIMARY KEY (fl_role_map_role, fl_role_map_freelancer),
  CONSTRAINT freelancer_role_map_role_fkey FOREIGN KEY (fl_role_map_role) 
    REFERENCES flingapp.freelancer_role (fl_role_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_role_map_freelancer_fkey FOREIGN KEY (fl_role_map_freelancer) 
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to roles
COMMENT ON TABLE flingapp.freelancer_role_map IS 'A role that a freelancer can be assigned';
COMMENT ON COLUMN flingapp.freelancer_role_map.fl_role_map_id IS 'The universally unique ID of a entry in the freelancer to role mapping';
COMMENT ON COLUMN flingapp.freelancer_role_map.fl_role_map_role IS 'The universally unique ID of a role in the freelancer to role mapping';
COMMENT ON COLUMN flingapp.freelancer_role_map.fl_role_map_freelancer IS 'The universally unique ID of a freelancer in the freelancer to role mapping';

-- 8. many-to-many mapping between languages and freelancers. Different to primary language -- this is the other languages freelancers can speak
CREATE TABLE flingapp.freelancer_language_map(
  fl_lang_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_lang_map_language flingapp.language NOT NULL,
  fl_lang_map_freelancer UUID NOT NULL, 
  CONSTRAINT freelancer_language_map_key UNIQUE (fl_lang_map_id),
  CONSTRAINT freelancer_language_map_pkey PRIMARY KEY (fl_lang_map_language, fl_lang_map_freelancer),
  CONSTRAINT freelancer_language_map_freelancer_fkey FOREIGN KEY (fl_lang_map_freelancer)
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE 
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to languages
COMMENT ON TABLE flingapp.freelancer_language_map IS 'A mapping of all languages a freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_language_map.fl_lang_map_id IS 'The universally unique ID of a entry in the freelancer to language mapping';
COMMENT ON COLUMN flingapp.freelancer_language_map.fl_lang_map_language IS 'A language enum type that the freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_language_map.fl_lang_map_freelancer IS 'The universally unique ID of a freelancer in the freelancer to language mapping';

-- 9. many-to-many mapping of freelancer and employment status */
CREATE TABLE flingapp.freelancer_employment_status_map(
  fl_emp_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_emp_map_status flingapp.employment_status NOT NULL,
  fl_emp_map_freelancer UUID NOT NULL,
  CONSTRAINT freelancer_employment_status_map_key UNIQUE (fl_emp_map_id),
  CONSTRAINT freelancer_employment_status_map_pkey PRIMARY KEY (fl_emp_map_status, fl_emp_map_freelancer),
  CONSTRAINT freelancer_employment_status_map_freelancer_fkey FOREIGN KEY (fl_emp_map_freelancer)
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE
);
-- comments for the mapping of freelancers to employment status
COMMENT ON TABLE flingapp.freelancer_employment_status_map IS 'A mapping of all employment statuses of a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.fl_emp_map_id IS 'The universally unique ID of a entry in the freelancer to employment status mapping';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.fl_emp_map_status IS 'A employment status enum type that the freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.fl_emp_map_freelancer IS 'The universally unique ID of a freelancer in the freelancer to employment status mapping';

-- 10. many-to-many mapping of freelancer and external links
CREATE TABLE flingapp.freelancer_external_links_map(
  fl_exlnk_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_exlnk_map_link TEXT NOT NULL,
  fl_exlnk_map_freelancer UUID NOT NULL,
  CONSTRAINT freelancer_external_links_map_key UNIQUE (fl_exlnk_map_id),
  CONSTRAINT freelancer_external_links_map_pkey PRIMARY KEY (fl_exlnk_map_link, fl_exlnk_map_freelancer),
  CONSTRAINT freelancer_external_links_map_freelancer_fkey FOREIGN KEY (fl_exlnk_map_freelancer)
    REFERENCES flingapp.freelancer(fl_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to external links
COMMENT ON TABLE flingapp.freelancer_external_links_map IS 'A mapping of all external links of a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.fl_exlnk_map_id IS 'The universally unique ID of a entry in the freelancer to external link mapping status mapping';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.fl_exlnk_map_link IS 'URL of external link for freelancer';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.fl_exlnk_map_freelancer IS 'The universally unique ID of a freelancer in the freelancer to external links mapping';

-- 11. core file store
CREATE TABLE flingapp_private.file_store(
  fs_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fs_file_data BYTEA NOT NULL,
  fs_file_name TEXT NOT NULL,
  fs_owner UUID,
  fs_organization UUID,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  CONSTRAINT file_store_pkey PRIMARY KEY (fs_id),
  CONSTRAINT file_store_owner_fkey FOREIGN KEY (fs_owner)
    REFERENCES flingapp_custom.user(user_id)
    ON DELETE SET NULL,
  CONSTRAINT file_store_organization_fkey FOREIGN KEY (fs_organization)
    REFERENCES flingapp.organization(org_id)
    ON DELETE SET NULL
);
-- comments for file store
COMMENT ON TABLE flingapp_private.file_store IS 'The central file store of flingapp.';
COMMENT ON COLUMN flingapp_private.file_store.fs_id IS 'The universally unique ID of each file in the file store';
COMMENT ON COLUMN flingapp_private.file_store.fs_file_data IS 'The binary data of the files stored in the flingapp db';
COMMENT ON COLUMN flingapp_private.file_store.fs_file_name IS 'The file name of the a file stored in the flingapp db';
COMMENT ON COLUMN flingapp_private.file_store.fs_owner IS 'The universally unique ID of a flingapp user who owns the file.';
COMMENT ON COLUMN flingapp_private.file_store.fs_organization IS 'The universally unique ID of a flingapp user who owns the file.';
COMMENT ON COLUMN flingapp_private.file_store.created_at IS 'The timestamp of when the file was created.';
COMMENT ON COLUMN flingapp_private.file_store.updated_at IS 'The timestamp of when the file was last updated.';

-- 12. many-to-many mapping of files to freelancers
CREATE TABLE flingapp.freelancer_file_store_map(
  fl_fs_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  fl_fs_map_file UUID NOT NULL,
  fl_fs_map_freelancer UUID NOT NULL,
  fl_fs_map_doc_type TEXT NOT NULL,
  CONSTRAINT freelancer_file_store_map_key UNIQUE (fl_fs_map_id),
  CONSTRAINT freelancer_file_store_map_pkey PRIMARY KEY (fl_fs_map_file, fl_fs_map_freelancer),
  CONSTRAINT freelancer_file_store_map_file_fkey FOREIGN KEY (fl_fs_map_file)
    REFERENCES flingapp_private.file_store (fs_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_file_store_map_freelancer_fkey FOREIGN KEY (fl_fs_map_freelancer)
    REFERENCES flingapp.freelancer(fl_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for file store mapping to freelancers
COMMENT ON TABLE flingapp.freelancer_file_store_map IS 'The mapping of files in the file store to a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.fl_fs_map_id IS 'The universally unique ID of each file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.fl_fs_map_file IS 'The universally unique ID of a file in the in the file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.fl_fs_map_freelancer IS 'The universally unique ID of a freelancer in the file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.fl_fs_map_doc_type IS 'A label for the type of file stored. E.g. ''Text''';


-- 13. core project store
CREATE TABLE flingapp.project(
  proj_id UUID NOT NULL DEFAULT gen_random_uuid(),
  proj_name TEXT NOT NULL,
  proj_start_date DATE NOT NULL,
  proj_end_date DATE NOT NULL,
  proj_description TEXT,
  proj_organization UUID NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  CONSTRAINT project_pkey PRIMARY KEY (proj_id),
  CONSTRAINT project_organization_fkey FOREIGN KEY (proj_organization)
    REFERENCES flingapp.organization (org_id)
    ON DELETE RESTRICT
);
-- comments for project store
COMMENT ON TABLE flingapp.project IS 'A store for all projects registered for an organization.';
COMMENT ON COLUMN flingapp.project.proj_id IS 'The universally unique ID of each project in the store.';
COMMENT ON COLUMN flingapp.project.proj_name IS 'The name of an organization''s project.';
COMMENT ON COLUMN flingapp.project.proj_start_date IS 'The start date of an organization''s project';
COMMENT ON COLUMN flingapp.project.proj_end_date IS 'The end date of an organization''s project';
COMMENT ON COLUMN flingapp.project.proj_description IS 'A text description of an organization''s project.';
COMMENT ON COLUMN flingapp.project.proj_organization IS 'The universally unique ID of an organization that run/ran this project.';
COMMENT ON COLUMN flingapp.project.created_at IS 'The timestamp of when the project was created.';
COMMENT ON COLUMN flingapp.project.updated_at IS 'The timestamp of when the project was last updated.';


-- 14. many-to-many mapping of project to freelancer 
CREATE TABLE flingapp.project_freelancer_map(
  proj_fl_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  proj_fl_map_freelancer UUID NOT NULL,
  proj_fl_map_project UUID NOT NULL,
  CONSTRAINT project_freelancer_map_key UNIQUE (proj_fl_map_id),
  CONSTRAINT project_freelancer_map_pkey PRIMARY KEY (proj_fl_map_freelancer, proj_fl_map_project),
  CONSTRAINT project_freelancer_map_freelancer_fkey FOREIGN KEY (proj_fl_map_freelancer)
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT project_freelancer_map_project_fkey FOREIGN KEY (proj_fl_map_project)
    REFERENCES flingapp.project (proj_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for project to freelancer map
COMMENT ON TABLE flingapp.project_freelancer_map IS 'A mapping of freelancers to projects.';
COMMENT ON COLUMN flingapp.project_freelancer_map.proj_fl_map_id IS 'The universally unique ID of a project to freelancer map.';
COMMENT ON COLUMN flingapp.project_freelancer_map.proj_fl_map_freelancer IS 'The universally unique ID of a freelancer mapped to a project.';
COMMENT ON COLUMN flingapp.project_freelancer_map.proj_fl_map_project IS 'The universally unique ID of a project mapped to a freelancer.';

-- 15. many-to-many mapping of file to project
CREATE TABLE flingapp.project_file_store_map(
  proj_fs_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  proj_fs_map_file UUID NOT NULL,
  proj_fs_map_project UUID NOT NULL,
  proj_fs_map_doc_type TEXT NOT NULL,
  CONSTRAINT project_file_store_map_key UNIQUE (proj_fs_map_id),
  CONSTRAINT project_file_store_map_pkey PRIMARY KEY (proj_fs_map_file, proj_fs_map_project),
  CONSTRAINT project_file_store_map_file_fkey FOREIGN KEY (proj_fs_map_file)
    REFERENCES flingapp_private.file_store (fs_id)
    ON DELETE RESTRICT,
  CONSTRAINT project_file_store_map_project_fkey FOREIGN KEY (proj_fs_map_project)
    REFERENCES flingapp.project (proj_id)
    ON DELETE RESTRICT
);
-- comments for file store mapping to project
COMMENT ON TABLE flingapp.project_file_store_map IS 'The mapping of files in the file store to a project.';
COMMENT ON COLUMN flingapp.project_file_store_map.proj_fs_map_id IS 'The universally unique ID of a file to project map';
COMMENT ON COLUMN flingapp.project_file_store_map.proj_fs_map_file IS 'The universally unique ID of a file mapped to a project';
COMMENT ON COLUMN flingapp.project_file_store_map.proj_fs_map_project IS 'The universally unique ID of a project mapped to a file.';
COMMENT ON COLUMN flingapp.project_file_store_map.proj_fs_map_doc_type IS 'A label for the type of file stored. E.g. ''Text''';


-- 16. many-to-many mapping of role to project
CREATE TABLE flingapp.project_role_map(
  pjoj_role_map_id UUID DEFAULT gen_random_uuid(),
  pjoj_role_map_role UUID UNIQUE NOT NULL,
  pjoj_role_map_project UUID UNIQUE NOT NULL,
  CONSTRAINT project_role_map_pkey PRIMARY KEY (pjoj_role_map_role, pjoj_role_map_project),
  CONSTRAINT project_role_map_role_fkey FOREIGN KEY (pjoj_role_map_role)
    REFERENCES flingapp.freelancer_role (fl_role_id)
    ON DELETE RESTRICT,
  CONSTRAINT project_role_map_project_fkey FOREIGN KEY (pjoj_role_map_project)
    REFERENCES flingapp.project (proj_id)
    ON DELETE RESTRICT
);
-- comments for role mapping to project
COMMENT ON TABLE flingapp.project_role_map IS 'The mapping of roles to a project.';
COMMENT ON COLUMN flingapp.project_role_map.pjoj_role_map_id IS 'The universally unique ID of a role to project map';
COMMENT ON COLUMN flingapp.project_role_map.pjoj_role_map_role IS 'The universally unique ID of a role to a project';
COMMENT ON COLUMN flingapp.project_role_map.pjoj_role_map_project IS 'The universally unique ID of a project mapped to a role.';


-- 17. core work item types for project
CREATE TABLE flingapp.work_item(
  witem_id UUID NOT NULL DEFAULT gen_random_uuid(),
  witem_name TEXT NOT NULL UNIQUE,
  witem_description TEXT,
  CONSTRAINT work_item_pkey PRIMARY KEY (witem_id)
);
-- comments for work item types
COMMENT ON TABLE flingapp.work_item IS 'The store of work items in flingapp db.';
COMMENT ON COLUMN flingapp.work_item.witem_id IS 'The universally unique ID of a work item type';
COMMENT ON COLUMN flingapp.work_item.witem_name IS 'The name of the work item';
COMMENT ON COLUMN flingapp.work_item.witem_description IS 'The description of the work item';


-- 18. many-to-many mapping of work items to projects
CREATE TABLE flingapp.project_work_item_map(
  proj_witem_map_id UUID DEFAULT gen_random_uuid(),
  proj_witem_map_work_item UUID NOT NULL,
  proj_witem_map_project UUID NOT NULL,
  CONSTRAINT project_work_item_ma_key UNIQUE (proj_witem_map_id),
  CONSTRAINT project_work_item_map_pkey PRIMARY KEY (proj_witem_map_work_item, proj_witem_map_project),
  CONSTRAINT project_work_item_map_work_item_fkey FOREIGN KEY (proj_witem_map_work_item)
    REFERENCES flingapp.work_item (witem_id)
    ON DELETE RESTRICT,
  CONSTRAINT project_work_item_map_project_fkey FOREIGN KEY (proj_witem_map_project)
    REFERENCES flingapp.project (proj_id)
    ON DELETE RESTRICT
);
-- comments for work item mapping to project
COMMENT ON TABLE flingapp.project_work_item_map IS 'The mapping of work items to a project.';
COMMENT ON COLUMN flingapp.project_work_item_map.proj_witem_map_id IS 'The universally unique ID of a work item to project map';
COMMENT ON COLUMN flingapp.project_work_item_map.proj_witem_map_work_item IS 'The universally unique ID of a work item mapped to a project';
COMMENT ON COLUMN flingapp.project_work_item_map.proj_witem_map_project IS 'The universally unique ID of a project mapped to a work item.';


-- 19. many-to-many mapping of freelancers to projects 
CREATE TABLE flingapp.work_history(
  wh_id UUID NOT NULL DEFAULT gen_random_uuid(),
  wh_freelancer UUID NOT NULL,
  wh_project UUID NOT NULL,
  wh_role UUID NOT NULL,
  wh_payment_currency flingapp.payment_currency NOT NULL default 'USD',
  wh_payment_rate NUMERIC NOT NULL DEFAULT 0.00,
  wh_main_work_item UUID NOT NULL,
  wh_start_date DATE NOT NULL,
  wh_finish_date DATE NOT NULL,
  wh_performance SMALLINT NOT NULL,
  wh_did_complete BOOLEAN NOT NULL DEFAULT false,
  wh_reason_for_dropout TEXT,
  -- keys
  CONSTRAINT work_history_wh_id_key UNIQUE (wh_id),
  CONSTRAINT work_history_pkey PRIMARY KEY (wh_freelancer, wh_project),
  CONSTRAINT work_history_freelancer_fkey FOREIGN KEY (wh_freelancer)
    REFERENCES flingapp.freelancer (fl_id)
    ON DELETE RESTRICT,
  CONSTRAINT work_history_project_fkey FOREIGN KEY (wh_project)
    REFERENCES flingapp.project (proj_id)
    ON DELETE RESTRICT,
  CONSTRAINT work_history_role_fkey FOREIGN KEY (wh_role)
    REFERENCES flingapp.freelancer_role(fl_role_id)
    ON DELETE RESTRICT, 
  CONSTRAINT work_history_main_work_item_fkey FOREIGN KEY (wh_main_work_item)
    REFERENCES flingapp.work_item (witem_id)
    ON DELETE RESTRICT
);
-- comments for work history store
COMMENT ON TABLE flingapp.work_history IS 'The store of all freelancers work experience with an organization.';
COMMENT ON COLUMN flingapp.work_history.wh_id IS 'The universally unique ID of piece of work experience in work history store.';
COMMENT ON COLUMN flingapp.work_history.wh_freelancer IS 'The universally unique ID of freelancer who owns the experience';
COMMENT ON COLUMN flingapp.work_history.wh_project IS 'The universally unique ID of a project that generated the work experience.';
COMMENT ON COLUMN flingapp.work_history.wh_role IS 'The universally unique ID of a role that the freelancer took on the work experience.';
COMMENT ON COLUMN flingapp.work_history.wh_payment_currency IS 'The payment currency for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.wh_payment_rate IS 'The payment rate for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.wh_main_work_item IS 'The main work item for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.wh_finish_date IS 'The start date of a freelancer''s work experience';
COMMENT ON COLUMN flingapp.work_history.wh_finish_date IS 'The start date of a freelancer''s work experience';
COMMENT ON COLUMN flingapp.work_history.wh_performance IS 'A whole number integer rating of the freelancer''s performance';
COMMENT ON COLUMN flingapp.work_history.wh_did_complete IS 'Whether the freelancer completed the project';
COMMENT ON COLUMN flingapp.work_history.wh_reason_for_dropout IS 'A reason why the freelancer didn''t complete a project';

-- 20. many-to-many mapping of files to work history 
CREATE TABLE flingapp.work_history_file_map(
  wh_file_map_id UUID DEFAULT gen_random_uuid(),
  wh_file_map_file UUID NOT NULL ,
  wh_file_map_exp UUID NOT NULL,
  wh_file_map_doc_type TEXT NOT NULL,
  -- keys
  CONSTRAINT work_history_file_map_pkkey PRIMARY KEY (wh_file_map_file, wh_file_map_exp),
  CONSTRAINT work_history_file_map_file_fkey FOREIGN KEY (wh_file_map_file)
    REFERENCES flingapp_private.file_store (fs_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT work_history_file_map_experience_fkey FOREIGN KEY (wh_file_map_exp)
    REFERENCES flingapp.work_history (wh_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comment on file store to work history map
COMMENT ON TABLE flingapp.work_history_file_map IS 'A map of work history to files';
COMMENT ON COLUMN flingapp.work_history_file_map.wh_file_map_id IS 'The universally unique ID of a map of a file to a piece of work experience';
COMMENT ON COLUMN flingapp.work_history_file_map.wh_file_map_file IS 'The universally unique ID of a file mapped to some work experience.';
COMMENT ON COLUMN flingapp.work_history_file_map.wh_file_map_exp IS 'The universally unique ID of some work experience mapped to a file.';
COMMENT ON COLUMN flingapp.work_history_file_map.wh_file_map_doc_type IS 'The type of document mapped to the work experience. E.g ''text''';


-- 21. core tag / note / comment store
-- create table
CREATE TABLE flingapp.text_note(
  txt_note_id UUID DEFAULT gen_random_uuid(),
  txt_note_body TEXT NOT NULL,
  txt_note_type flingapp.text_note_types NOT NULL,
  txt_note_owner UUID NOT NULL,
  CONSTRAINT text_note_pkey PRIMARY KEY (txt_note_id),
  CONSTRAINT text_note_owner_fkey FOREIGN KEY (txt_note_owner)
    REFERENCES flingapp_custom.user (user_id)
    ON DELETE SET NULL
);
-- comment on text notes store
COMMENT ON TABLE flingapp.text_note IS 'A store of all textual notes in the flingapp db';
COMMENT ON COLUMN flingapp.text_note.txt_note_id IS 'The universally unique ID of a text note';
COMMENT ON COLUMN flingapp.text_note.txt_note_body IS 'The body text of a text note';
COMMENT ON COLUMN flingapp.text_note.txt_note_type IS 'The type of the text note e.g. ''tag''';
COMMENT ON COLUMN flingapp.text_note.txt_note_owner IS 'The universally unique ID of the owner of the text note';


-- 22. many-to-many mapping of freelancers to text notes
CREATE TABLE flingapp.freelancer_text_note_map(
  fl_note_map_id UUID DEFAULT gen_random_uuid(),
  fl_note_map_freelancer UUID NOT NULL,
  fl_note_map_text_note UUID NOT NULL,
  CONSTRAINT freelancer_text_note_map_pkey PRIMARY KEY (fl_note_map_freelancer, fl_note_map_text_note),
  CONSTRAINT freelancer_text_note_map_freelancer_fkey FOREIGN KEY (fl_note_map_freelancer)
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_text_note_map_text_note_fkey FOREIGN KEY (fl_note_map_text_note)
    REFERENCES flingapp.text_note (txt_note_id) MATCH SIMPLE
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.freelancer_text_note_map IS 'A store of all mappings of text notes to freelancers';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.fl_note_map_id IS 'The universally unique ID of a mapping between a text note and a freelancer';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.fl_note_map_freelancer IS 'The universally unique ID of a freelancer mapped to a text note';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.fl_note_map_text_note IS 'The universally unique ID of a text note mapped to a freelancer';

-- 23. many-to-many mapping of projects to text notes
CREATE TABLE flingapp.project_text_note_map(
  proj_note_map_id UUID DEFAULT gen_random_uuid(),
  proj_note_map_project UUID NOT NULL,
  proj_note_map_text_note UUID NOT NULL,
  CONSTRAINT project_text_note_map_pkey PRIMARY KEY (proj_note_map_project, proj_note_map_text_note),
  CONSTRAINT project_text_note_map_project_fkey FOREIGN KEY (proj_note_map_project)
    REFERENCES flingapp.project (proj_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_text_note_map_text_note_fkey FOREIGN KEY (proj_note_map_text_note)
    REFERENCES flingapp.text_note (txt_note_id) MATCH SIMPLE
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.project_text_note_map IS 'A store of all mappings of text notes to projects';
COMMENT ON COLUMN flingapp.project_text_note_map.proj_note_map_id IS 'The universally unique ID of a mapping between a text note and a project';
COMMENT ON COLUMN flingapp.project_text_note_map.proj_note_map_project IS 'The universally unique ID of a project mapped to a text note';
COMMENT ON COLUMN flingapp.project_text_note_map.proj_note_map_text_note IS 'The universally unique ID of a text note mapped to a project';





-- 24. many-to-many mapping of work history to text notes
CREATE TABLE flingapp.work_history_text_note_map(
  wh_note_map_id UUID DEFAULT gen_random_uuid(),
  wh_note_map_work_history UUID NOT NULL,
  wh_note_map_text_note UUID NOT NULL,
  CONSTRAINT work_history_text_note_map_pkey PRIMARY KEY (wh_note_map_work_history, wh_note_map_text_note),
  CONSTRAINT work_history_text_note_map_work_history_fkey FOREIGN KEY (wh_note_map_work_history)
    REFERENCES flingapp.work_history (wh_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT work_history_text_note_map_text_note_fkey FOREIGN KEY (wh_note_map_text_note)
    REFERENCES flingapp.text_note (txt_note_id) MATCH SIMPLE
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.work_history_text_note_map IS 'A store of all mappings of text notes to work history';
COMMENT ON COLUMN flingapp.work_history_text_note_map.wh_note_map_id IS 'The universally unique ID of a mapping between a text note and work history';
COMMENT ON COLUMN flingapp.work_history_text_note_map.wh_note_map_work_history IS 'The universally unique ID of work history mapped to a text note';
COMMENT ON COLUMN flingapp.work_history_text_note_map.wh_note_map_text_note IS 'The universally unique ID of a text note mapped to work history';




-- 25. many-to-many mapping of freelancers with an organization
CREATE TABLE flingapp.freelancer_org_map(
  freelancer_org_map_id UUID NOT NULL DEFAULT gen_random_uuid(),
  freelancer_org_map_org UUID NOT NULL,
  freelancer_org_map_freelancer UUID NOT NULL,
  CONSTRAINT fl_org_map_key PRIMARY KEY (freelancer_org_map_id),
  CONSTRAINT fl_org_map_pkey UNIQUE (freelancer_org_map_org, freelancer_org_map_freelancer),
  CONSTRAINT fl_org_map_org_fkey FOREIGN KEY (freelancer_org_map_org) 
    REFERENCES flingapp.organization (org_id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_role_map_freelancer_fkey FOREIGN KEY (freelancer_org_map_freelancer) 
    REFERENCES flingapp.freelancer (fl_id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to roles
COMMENT ON TABLE flingapp.freelancer_org_map IS 'A role that a freelancer can be assigned';
COMMENT ON COLUMN flingapp.freelancer_org_map.freelancer_org_map_id IS 'The universally unique ID of a entry in the freelancer to organization mapping';
COMMENT ON COLUMN flingapp.freelancer_org_map.freelancer_org_map_org IS 'The universally unique ID of an `Organization` in the freelancer to organization mapping';
COMMENT ON COLUMN flingapp.freelancer_org_map.freelancer_org_map_freelancer IS 'The universally unique ID of a `Freelancer` in the freelancer to organization mapping';



-- 26. record access requests to organizations
CREATE TABLE flingapp_private.org_access_request(
  access_req_id UUID NOT NULL DEFAULT gen_random_uuid(),
  org_id UUID NOT NULL,
  requestor_id UUID NOT NULL,
  request_selector TEXT NOT NULL,
  request_validator_hash TEXT NOT NULL,
  request_confirmed BOOLEAN DEFAULT FALSE,
  CONSTRAINT org_access_request_pkey PRIMARY KEY (access_req_id),
  CONSTRAINT org_access_request_key UNIQUE (org_id, requestor_id),
  CONSTRAINT org_access_request_requestor_fkey FOREIGN KEY (requestor_id)
    REFERENCES flingapp_private.user_account (user_acc_id) MATCH SIMPLE,
  CONSTRAINT org_access_request_org_fkey FOREIGN KEY (org_id)
    REFERENCES flingapp.organization (org_id) MATCH SIMPLE
);
-- comments for the org_access_request table
COMMENT ON TABLE flingapp_private.org_access_request IS 'A request to join an organization';
COMMENT ON COLUMN flingapp_private.org_access_request.access_req_id IS 'The universally unique ID of a single `Access Request` to an organization';
COMMENT ON COLUMN flingapp_private.org_access_request.org_id IS 'The universally unique ID of the organization being the request is for.';
COMMENT ON COLUMN flingapp_private.org_access_request.requestor_id IS 'The universally unique ID of a single ``User`` requesting access to the organization';
COMMENT ON COLUMN flingapp_private.org_access_request.request_selector IS 'The selector used to find the request when validating.';
COMMENT ON COLUMN flingapp_private.org_access_request.request_validator_hash IS 'The verifier has verifying the lookup of the request.';
COMMENT ON COLUMN flingapp_private.org_access_request.request_confirmed IS 'An indication of whether the request has been fulfilled.';


-- ***** VIEWS ***** 
-- create any necessary views across different schemas where we need a single or all select function

-- 1. view over users only availalbe to fling app user and with RLS activated
CREATE OR REPLACE VIEW flingapp.simple_user WITH (security_barrier) AS 
  SELECT u_acc.user_acc_id, u_acc.user_email, u_acc.user_email_confirmed, u_acc.user_password_reset_requested, u.user_first_name, u.user_last_name, u.user_org
  FROM flingapp_private.user_account u_acc, flingapp_custom.user u
  WHERE u_acc.user_acc_id = u.user_id AND u.user_id = current_setting('jwt.claims.user_acc_id')::uuid;





-- ***** IN SCRIPT REQUIREMENTS *****
-- make sure we've reset permissions / cleared the white list to execute functions
alter default privileges revoke execute on functions from public;

 


-- ***** JWT IMPLEMENTATION ******

-- all types of users of the API
CREATE TYPE flingapp.app_role as ENUM (
  'flingapp_anonymous',
  'flingapp_user',
  'flingapp_postgraphql'
);


-- for JWT tokens
CREATE TYPE flingapp.jwt_token as (
  role flingapp.app_role,
  user_acc_id UUID
);




-- ***** MISC CUSTOM TYPES ***** 


-- return type for user_register_user
CREATE TYPE flingapp.registered_user as (
  user_id UUID,
  first_name TEXT,
  last_name TEXT,
  email TEXT,
  account_selector TEXT,
  account_verifier TEXT,
  account_activated BOOLEAN
);




-- return type for user CRUD
CREATE TYPE flingapp.full_user_detail AS (
  user_id UUID,
  user_email TEXT,
  user_first_name TEXT,
  user_last_name TEXT
);


-- return type for org request_access_to_org
CREATE TYPE flingapp.access_request AS (
  req_id UUID,
  org_id UUID,
  admin_id UUID,
  admin_email TEXT,
  requestor_id UUID,
  selector TEXT,
  verifier TEXT,
  request_status BOOLEAN
);



-- ***** UTILITY FUNCTIONS *****
-- all custom functions in DB (that are not automatically generated by postgraphql)

-- 1. This is a simple standalone SQL-only function to generate
-- random bytea values. It's fine for generating a few hundred kb.
CREATE OR REPLACE FUNCTION flingapp_private.random_string(
 length integer
) RETURNS TEXT AS $body$
    --SELECT decode(string_agg(lpad(to_hex(width_bucket(random(), 0, 1, 256)-1),2,'0') ,''), 'hex')
    --FROM generate_series(1, $1);
    SELECT substring( encode(gen_random_bytes(length * 3/4 +1), 'base64'), 0, length );
$body$
LANGUAGE sql VOLATILE;
COMMENT ON FUNCTION flingapp_private.random_string(integer) IS 'Generate n random bytes of garbage, returned as text.';




-- 2. set updated_at column on any rows updated
CREATE OR REPLACE FUNCTION flingapp_private.set_updated_at() RETURNS trigger as $$
BEGIN
  new.updated_at := timezone('utc'::text, now());
  return new;
END;
$$ LANGUAGE plpgsql;




-- 3. check if a a value is null or just an empty string
CREATE OR REPLACE FUNCTION flingapp_private.is_empty(TEXT) RETURNS bool AS $$
  SELECT $1 ~ '^[[:space:]]*$'; 
$$ LANGUAGE sql IMMUTABLE;
COMMENT ON FUNCTION flingapp_private.is_empty(TEXT) IS 'Find empty strings or strings containing only whitespace';




-- ***** AUTH *****

-- 1. REGISTER a user
CREATE OR REPLACE FUNCTION flingapp.usr_register_user(
  first_name text,
  last_name text,
  email text,
  password text
) RETURNS flingapp.registered_user as $$
DECLARE
  user_details flingapp_custom.user;
  user_account flingapp_private.user_account;
  account_selector TEXT;
  account_verifier TEXT;
BEGIN

  SELECT flingapp_private.random_string(15) INTO account_selector;
  SELECT flingapp_private.random_string(18) INTO account_verifier;

  INSERT INTO flingapp_private.user_account (user_email, user_password_hash, user_email_confirm_token_selector, user_email_confirm_token_verifier_hash) VALUES
    (email, crypt(password, gen_salt('bf', 8)), account_selector, crypt(account_verifier, gen_salt('bf', 8)))
    RETURNING * into user_account;

  INSERT INTO flingapp_custom.user (user_id, user_first_name, user_last_name) VALUES
    (user_account.user_acc_id, first_name, last_name)
    RETURNING * into user_details;

  RETURN (user_details.user_id, user_details.user_first_name, user_details.user_last_name, user_account.user_email, account_selector, account_verifier, FALSE)::flingapp.registered_user;
END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.usr_register_user(text, text, text, text) IS 'Registers a single `User` and creates an account in flingapp.';




-- 2. Authenticate and return a JWT
-- will only give user access if also confirmed email address.

CREATE OR REPLACE FUNCTION flingapp.authenticate(
  email text,
  password text
) RETURNS flingapp.jwt_token AS $$
DECLARE
  account flingapp_private.user_account;
BEGIN
  SELECT a.* into account
  FROM flingapp_private.user_account AS a
  WHERE a.user_email = email;

  IF account.user_password_hash = crypt(password, account.user_password_hash) AND account.user_email_confirmed = false then
    RETURN ('flingapp_user', account.user_acc_id)::flingapp.jwt_token;
  ELSIF account.user_password_hash = crypt(password, account.user_password_hash) AND account.user_email_confirmed = true  then
    RETURN ('flingapp_postgraphql', account.user_acc_id)::flingapp.jwt_token;
  ELSE
    RETURN null;
  END if;
END;
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.authenticate(text, text) IS 'Creates a JWT token that will securely identify a person and give them certain permissions.';




-- 3. Get current user who is authenticated 
CREATE OR REPLACE FUNCTION flingapp.this_user() 
RETURNS flingapp.simple_user AS $$
DECLARE 
  role UUID;
  result flingapp.simple_user;
BEGIN
  -- second paramter here is 'missing_ok' (not in documentation)
  SELECT current_setting('jwt.claims.user_acc_id', true)::UUID INTO role;
  IF role IS NULL THEN
    RETURN NULL;
  ELSE 
    -- no need to qualify select statement as ``simple_user`` view selects based on UUID from claim;
    SELECT * FROM flingapp.simple_user INTO result;
    RETURN result;
  END IF;

END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;
COMMENT ON FUNCTION  flingapp.this_user() is 'Gets the person who was identified by our JWT.';




-- 4. Activate a user after with their activation tokens
CREATE OR REPLACE FUNCTION flingapp.activate_user(
  selector text,
  verifier text
) RETURNS flingapp.jwt_token AS $$
DECLARE
 account flingapp_private.user_account;
BEGIN
  SELECT pa.* INTO account
  FROM flingapp_private.user_account AS pa
  WHERE selector = pa.user_email_confirm_token_selector;

  IF FOUND THEN 
    IF account.user_email_confirm_token_verifier_hash = crypt(verifier, account.user_email_confirm_token_verifier_hash) 
      THEN
        UPDATE flingapp_private.user_account AS ua
          SET user_email_confirmed = true
          WHERE ua.user_acc_id = account.user_acc_id;

        RETURN ('flingapp_postgraphql', account.user_acc_id)::flingapp.jwt_token;
    ELSE 
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL; 
  END IF;

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.activate_user(text, text) IS 'Activates and verifies single `User` account and email allowing them to do more in the app.';


-- ***** ORG Functions *****

-- insert org functions here

--1. requests access to organization and returns the request with selector and verifier information
CREATE OR REPLACE FUNCTION flingapp.request_access_to_org(
  org_id UUID,
  requestor_id UUID
) RETURNS flingapp.access_request AS $$
DECLARE
  selector TEXT;
  verifier TEXT;
  admin flingapp.simple_user;
  org flingapp.organization;
  upsert_result flingapp_private.org_access_request;
  result flingapp.access_request;
BEGIN

  SELECT flingapp_private.random_string(15) INTO selector;
  SELECT flingapp_private.random_string(18) INTO verifier;

  SELECT * INTO org
  FROM flingapp.organization
  WHERE $1 = flingapp.organization.org_id; 

  SELECT * INTO admin
  FROM flingapp.simple_user 
  WHERE  user_id = org.org_admin;

  INSERT INTO flingapp_private.org_access_request (org_id, requestor_id, request_selector, request_validator_hash) 
    VALUES (
      $1,
      $2,
      selector,
      crypt(verifier, gen_salt('bf', 8))
    )
    ON CONFLICT (org_access_request_key) DO UPDATE SET request_selector = selector, request_validator_hash = crypt(verifier, gen_salt('bf', 8)), request_confirmed = FALSE  WHERE requestor_id = $2
    RETURNING * INTO upsert_result;

  RETURN (upsert_result.access_req_id, $1, admin.user_id, admin.user_email, $2, selector, verifier, FALSE)::flingapp.access_request;

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.request_access_to_org(UUID, UUID) IS 'Registers a request for access to an organizatin by another user and returns the values needed for the validation email';




--2. validates a request to access an organization
CREATE OR REPLACE FUNCTION flingapp.validate_org_access(
  selector TEXT,
  verifier TEXT
) RETURNS flingapp.simple_user AS $$
DECLARE
  user flingapp.simple_user;
  request  flingapp_private.org_access_request;
BEGIN
  SELECT * INTO request
  FROM flingapp_private.org_access_request
  WHERE request_selector = $1;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  IF request.request_validator_hash = crypt(verifier, request.request_validator_hash) THEN
    UPDATE flingapp_private.org_access_request
    SET
      request_confirmed = TRUE
    WHERE access_req_id = request.access_req_id;

    UPDATE flingapp_custom.user
    SET 
      user_org = request.org_id
    WHERE user_acc_id = request.requestor_id;

    SELECT * INTO user
    FROM flingapp.simple_user
    WHERE user_acc_id = request.requestor_id;

    RETURN user;
  ELSE 
    RETURN NULL;
  END IF;

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.validate_org_access(TEXT, TEXT) IS 'Validates a request to access an organization and adds the organization to the user if successful';




-- ***** CUSTOM CRUD *****

-- 2a. UPDATE BY ID
CREATE OR REPLACE FUNCTION flingapp.usr_update_user_by_id(
  user_id_in UUID,
  user_email_in TEXT,
  user_first_name_in TEXT,
  user_last_name_in TEXT,
  user_org_in UUID
) RETURNS flingapp.simple_user AS $$
DECLARE 
  exists flingapp.simple_user;
  partial1 flingapp_private.user_account;
  partial2 flingapp_custom.user;
BEGIN
  
  -- check if user exists
  SELECT * INTO exists
  FROM flingapp.simple_user as u
  WHERE u.user_acc_id = $1;

  -- return null if not found
  IF NOT FOUND THEN 
    RETURN NULL;
  END IF;

  -- update hidden account details
  UPDATE flingapp_private.user_account as pu
    SET
      user_email = user_email_in
    WHERE pu.user_acc_id = user_id_in
    RETURNING * INTO partial1;

  -- update standard user details
  UPDATE flingapp_custom.user as cu
    SET
      user_first_name = user_first_name_in,
      user_last_name = user_last_name_in,
      user_org = user_org_in
    WHERE cu.user_id = user_id_in
    RETURNING * INTO partial2;

  -- returning updated records
  RETURN (partial1.user_acc_id, partial1.user_email, partial1.user_email_confirmed, partial1.user_password_reset_requested, partial2.user_first_name, partial2.user_last_name, partial2.user_org)::flingapp.simple_user;

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.usr_update_user_by_id(UUID, text, text, text, UUID) IS 'Updates a single `User` using the supplied UUID';




-- 2b. UPDATE BY EMAIL
CREATE OR REPLACE FUNCTION flingapp.usr_update_user_by_email(
  user_email_in TEXT,
  user_first_name_in TEXT,
  user_last_name_in TEXT,
  user_org_in UUID
) RETURNS flingapp.simple_user AS $$
DECLARE 
  exists flingapp.simple_user;
  partial flingapp_custom.user;
BEGIN

  -- check if uer exists
  SELECT * INTO exists
  FROM flingapp.simple_user as u
  WHERE u.user_email = $1;

  -- reject if not found
  IF NOT FOUND THEN 
    RETURN NULL;
  END IF;

  UPDATE flingapp_custom.user as cu
    SET
      user_first_name = $2,
      user_last_name = $3,
      user_org = $4
    WHERE cu.user_id = exists.user_acc_id
  RETURNING * INTO partial;

  RETURN (exists.user_acc_id, exists.user_email, exists.user_email_confirmed, exists.user_password_reset_requested, partial.user_first_name, partial.user_last_name, partial.user_org)::flingapp.simple_user;

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.usr_update_user_by_email(text, text, text, UUID) IS 'Updates a single `User` using the supplied email address';




-- 3. delete a user
CREATE OR REPLACE FUNCTION flingapp.usr_delete_user_by_id(
   user_id_in UUID
) RETURNS flingapp_custom.user AS $$
DECLARE
  result flingapp_custom.user;
BEGIN
  DELETE FROM flingapp_private.user_account
  WHERE user_acc_id = user_id_in;

  DELETE FROM flingapp_custom.user
  WHERE user_id = user_id_in
  RETURNING * INTO result;

  RETURN result; 

END;
$$ LANGUAGE plpgsql VOLATILE STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.usr_delete_user_by_id(UUID) IS 'Deletes a single `User` using the supplied UUID';




-- ***** TRIGGERS *****
CREATE TRIGGER user_acc_updated_at BEFORE UPDATE
  ON flingapp_private.user_account
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();





CREATE TRIGGER user_updated_at BEFORE UPDATE
  ON flingapp_custom.user
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();




CREATE TRIGGER org_updated_at BEFORE UPDATE
  ON flingapp.organization
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();




CREATE TRIGGER fl_updated_at BEFORE UPDATE
  ON flingapp.freelancer
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();




CREATE TRIGGER fs_updated_at BEFORE UPDATE
  ON flingapp_private.file_store
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();




CREATE TRIGGER proj_updated_at BEFORE UPDATE
  ON flingapp.project
  FOR EACH ROW
  EXECUTE PROCEDURE flingapp_private.set_updated_at();




-- **** Privileges

-- SCHEMA GRANTS
GRANT USAGE ON SCHEMA flingapp TO :flinganon, :flinguser;




-- TABLE GRANTS

-- 1. user_account: N/A - it's in the private schema




-- 2. user: N/A - it's in the custom schema




-- 3. organization
GRANT SELECT ON TABLE flingapp.organization to :flingpgql;
GRANT INSERT, UPDATE, DELETE ON TABLE flingapp.organization to :flingpgql;




-- 4. user_org_map
-- GRANT SELECT ON TABLE flingapp.user_org_map to :flinguser;
-- GRANT UPDATE, DELETE ON TABLE flingapp.user_org_map to :flinguser ;




-- 5. freelancer
GRANT SELECT ON TABLE flingapp.freelancer to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer to :flingpgql;




-- 6. freelancer_role
GRANT SELECT ON TABLE flingapp.freelancer_role to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_role to :flingpgql ;




-- 7. freelancer_role_map
GRANT SELECT ON TABLE flingapp.freelancer_role_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_role_map to :flingpgql ;




-- 8. freelancer_language_map
GRANT SELECT ON TABLE flingapp.freelancer_language_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_language_map to :flingpgql ;




-- 9. freelancer_employment_status_map
GRANT SELECT ON TABLE flingapp.freelancer_employment_status_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_employment_status_map to :flingpgql ;




-- 10. freelancer_external_links_map
GRANT SELECT ON TABLE flingapp.freelancer_external_links_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_external_links_map to :flingpgql ;




-- 11. file_store: N/A - it's in private schema and postgraphql can't do file uploads




-- 12. freelancer_file_store_map
GRANT SELECT ON TABLE flingapp.freelancer_file_store_map to  :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_file_store_map to :flingpgql;




-- 13. project
GRANT SELECT ON TABLE flingapp.project to  :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project to :flingpgql ;




-- 14. project_freelancer_map
GRANT SELECT ON TABLE flingapp.project_freelancer_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project_freelancer_map to :flingpgql ;




-- 15. project_file_store_map
GRANT SELECT ON TABLE flingapp.project_file_store_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project_file_store_map to :flingpgql ;




-- 16. project_role_map
GRANT SELECT ON TABLE flingapp.project_role_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project_role_map to :flingpgql ;




-- 17. work_item
GRANT SELECT ON TABLE flingapp.work_item to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.work_item to :flingpgql ;




-- 18. project_work_item_map
GRANT SELECT ON TABLE flingapp.project_work_item_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project_work_item_map to :flingpgql ;




-- 19. work_history
GRANT SELECT ON TABLE flingapp.work_history to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history to :flingpgql ;

-- 20. work_history_file_map
GRANT SELECT ON TABLE flingapp.work_history_file_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history_file_map to :flingpgql ;




-- 21. text_note
GRANT SELECT ON TABLE flingapp.text_note to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.text_note to :flingpgql ;




-- 22. freelancer_text_note_map
GRANT SELECT ON TABLE flingapp.freelancer_text_note_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_text_note_map to :flingpgql ;




-- 23. project_text_note_map
GRANT SELECT ON TABLE flingapp.project_text_note_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.project_text_note_map to :flingpgql ;




-- 24. work_history_text_note_map
GRANT SELECT ON TABLE flingapp.work_history_text_note_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history_text_note_map to :flingpgql ;




-- 25. fl_org_map
GRANT SELECT ON TABLE flingapp.freelancer_org_map to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_org_map to :flingpgql;




-- VIEW GRANTS

-- 1. simple_user
GRANT SELECT ON TABLE flingapp.simple_user to :flingpgql;
GRANT UPDATE, DELETE ON TABLE flingapp.simple_user to :flingpgql;




-- FUNCTION GRANTS

GRANT EXECUTE ON FUNCTION flingapp.usr_register_user(text, text, text, text) to :flinganon;
GRANT EXECUTE ON FUNCTION flingapp.usr_update_user_by_id(UUID, text, text, text, UUID) to :flingpgql;
GRANT EXECUTE ON FUNCTION flingapp.usr_update_user_by_email(text, text, text, UUID) to :flingpgql;
GRANT EXECUTE ON FUNCTION flingapp.usr_delete_user_by_id(UUID) to :flingpgql;
GRANT EXECUTE ON FUNCTION flingapp.authenticate(text, text) to :flinganon;
GRANT EXECUTE ON FUNCTION flingapp.activate_user(text, text) to :flinguser;
GRANT EXECUTE ON FUNCTION flingapp.this_user() to :flinganon, :flinguser, :flingpgql;




-- RLS settings
ALTER TABLE flingapp_custom.user ENABLE row level security;
CREATE POLICY select_user ON flingapp_custom.user FOR SELECT TO :flinguser, :flingpgql
  USING (user_id = current_setting('jwt.claims.user_acc_id')::uuid);
CREATE POLICY update_user ON flingapp_custom.user FOR UPDATE TO :flinguser, :flingpgql
  USING (user_id = current_setting('jwt.claims.user_acc_id')::uuid);




ALTER TABLE flingapp_private.user_account ENABLE row level security;
CREATE POLICY select_user ON flingapp_private.user_account FOR SELECT TO :flinguser, :flingpgql
  USING (user_acc_id = current_setting('jwt.claims.user_acc_id')::uuid);
CREATE POLICY update_user ON flingapp_private.user_account FOR UPDATE TO :flinguser, :flingpgql
  USING (user_acc_id = current_setting('jwt.claims.user_acc_id')::uuid);

ALTER TABLE flingapp.organization ENABLE row level security;
CREATE POLICY insert_org ON flingapp.organization FOR INSERT TO :flingpgql
  WITH CHECK (org_admin = current_setting('jwt.claims.user_acc_id')::uuid);
CREATE POLICY select_org ON flingapp.organization FOR SELECT TO :flingpgql
  USING (org_admin = current_setting('jwt.claims.user_acc_id')::uuid);
CREATE POLICY update_org ON flingapp.organization FOR UPDATE TO :flingpgql
  USING (org_admin = current_setting('jwt.claims.user_acc_id')::uuid); 

begin;


