-- set some variables for our new users
\set flingadmin 'flingapp_admin'
\set flingpgql 'flingapp_postgraphql'
\set flinganon 'flingapp_anonymous'
\set flinguser 'flingapp_user'
-- drop the app databse if it already exists
DROP DATABASE IF EXISTS fling;

-- create our database account owner and give it privileges
-- change the password to your own for installation
DROP ROLE IF EXISTS :flingadmin;
CREATE ROLE :flingadmin WITH LOGIN PASSWORD 'FlingAppMakesItEasy';

-- create our awesome app db
CREATE DATABASE fling WITH OWNER :flingadmin;
-- give flingapp all privileges to create the DB
GRANT ALL PRIVILEGES ON DATABASE fling TO :flingadmin;
-- remove all default privileges from public on functions
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM public;

-- create our role that is used to login into postgres with postgraphql
-- change the password to your own for installation
DROP ROLE IF EXISTS :flingpgql;
CREATE ROLE :flingpgql WITH LOGIN PASSWORD 'YourFlingAppPassword';

-- create our role that will be the default user before user logs in
DROP ROLE IF EXISTS :flinganon;
CREATE ROLE :flinganon;
-- create our role that will be the default user after user logs in
DROP ROLE IF EXISTS :flinguser;
CREATE ROLE :flinguser;

-- make sure that the flingadmin can do everything the postgraphql user can do
GRANT :flingpgql to :flingadmin;
-- make sure that postgraphql user can do everything the anonymouse can.
GRANT :flinganon to :flingpgql;
-- make sure that postgraphql user can do everything a user can.
GRANT :flinguser to :flingpgql;

\connect fling
DROP SCHEMA IF EXISTS flingapp;
DROP SCHEMA IF EXISTS flingapp_private;

-- create the app schema and then create tables
begin;
-- must be superuser to add this extension
CREATE EXTENSION IF NOT EXISTS pgcrypto; 
-- add schemas
CREATE SCHEMA IF NOT EXISTS flingapp AUTHORIZATION :flingadmin;
CREATE SCHEMA IF NOT EXISTS flingapp_private AUTHORIZATION :flingadmin;
--  we want the flingapp user to be the role that owns the tables so postgraphql has the correct permissions
SET ROLE :flingadmin;

-- let's make our types 

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
COMMENT ON TYPE flingapp.payment_currency IS 'A list of all the possible text note tyeps';


-- let's make our tables

-- 1. our core app user private account information
CREATE TABLE flingapp_private.user_account(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  email TEXT NOT NULL CHECK (email ~* '^.+@.+\..+$'),
  email_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
  password_hash TEXT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  -- keys
  CONSTRAINT user_account_pkey PRIMARY KEY (id),
  CONSTRAINT user_account_email_key UNIQUE (email)
);
-- comments for user_account
COMMENT ON TABLE flingapp_private.user_account IS 'A human user''s account information with fling app';
COMMENT ON COLUMN flingapp_private.user_account.id IS 'The universally unique ID of a user account of flingapp';
COMMENT ON COLUMN flingapp_private.user_account.email IS 'The unique email address of a user - a user cannot register with the same email twice.';
COMMENT ON COLUMN flingapp_private.user_account.email_confirmed IS 'Whether or not the user has confirmed their email address.';
COMMENT ON COLUMN flingapp_private.user_account.password_hash IS 'The salted password hash of a user account.';
COMMENT ON COLUMN flingapp_private.user_account.created_at IS 'The timestamp when the user was created.';
COMMENT ON COLUMN flingapp_private.user_account.updated_at IS 'The timestamp when the user was last updated';

-- 2. an organization that is using flingapp
CREATE TABLE flingapp.organization(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  admin UUID NOT NULL,
  domain TEXT NOT NULL,
  -- keys
  CONSTRAINT organization_pkey PRIMARY KEY (id),
  CONSTRAINT organization_name_key UNIQUE (name),
  CONSTRAINT organization_domain_key UNIQUE (domain),
  CONSTRAINT organization_user_account_fkey FOREIGN KEY (admin)
    REFERENCES flingapp_private.user_account(id) MATCH SIMPLE
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
-- comments for organization
COMMENT ON TABLE flingapp.organization IS 'An organization that freelancers and users can belong to.';
COMMENT ON COLUMN flingapp.organization.id IS 'The universally unique ID of an organization';
COMMENT ON COLUMN flingapp.organization.name IS 'An organization''s name';
COMMENT ON COLUMN flingapp.organization.admin IS 'A UUID of a user who is the assigned admin of this organization. References users.';
COMMENT ON COLUMN flingapp.organization.domain IS 'A unique FQDN used to help a user find their organization. E.g. example.com'; 

-- 3. our core app user profile information 
CREATE TABLE flingapp.user(
  id UUID NOT NULL,
  first_name TEXT NOT NULL DEFAULT 'Jane',
  last_name TEXT NOT NULL DEFAULT 'Doe',
  display_name TEXT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT timezone('utc'::text, now()),
  -- keys
  CONSTRAINT user_pkey PRIMARY KEY (id),
  CONSTRAINT user_display_name_key UNIQUE (display_name),
  CONSTRAINT user_id_fkey FOREIGN KEY (id)
    REFERENCES flingapp_private.user_account(id) MATCH SIMPLE
    ON DELETE CASCADE
);
-- comments for user
COMMENT ON TABLE flingapp.user IS 'A human user of flingapp';
COMMENT ON COLUMN flingapp.user.id IS 'The universally unique ID of a user of flingapp. References flingapp account.';
COMMENT ON COLUMN flingapp.user.first_name IS 'The first, or given name, of a user of flingapp';
COMMENT ON COLUMN flingapp.user.last_name IS 'The family name, or last name, of a user of flingapp';
COMMENT ON COLUMN flingapp.user.display_name IS 'The username \/ display name of a user of flingapp';
COMMENT ON COLUMN flingapp.user.created_at IS 'The timestamp when the user was created';
COMMENT ON COLUMN flingapp.user.updated_at IS 'The timestamp when the user was last updated';
COMMENT ON COLUMN flingapp.user.organization IS 'The ID of the organization the user belongs to';

-- 4. many-to-many mapping table of organization to users
CREATE TABLE flingapp.user_org_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  user_id UUID NOT NULL,
  -- keys
  CONSTRAINT user_org_map_pkey PRIMARY KEY (organization_id, user_id),
  CONSTRAINT user_org_map_organization_fkey FOREIGN KEY (organization_id)
    REFERENCES flingapp.organization(id) MATCH SIMPLE
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT users_org_map_user_fkey FOREIGN KEY (user_id)
    REFERENCES flingapp_private.user_account(id) MATCH SIMPLE
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
-- comments for user account to organization many-to-many
COMMENT ON TABLE flingapp.user_org_map IS 'A many-to-many mapping of users to organizations';
COMMENT ON COLUMN flingapp.user_org_map.id IS 'The universally unique ID of a user to organization map entry';
COMMENT ON COLUMN flingapp.user_org_map.organization_id IS 'An organization''s name - references organization table';
COMMENT ON COLUMN flingapp.user_org_map.user_id IS 'A UUID of a user. References users.';

-- 5. core freelancer entity
CREATE TABLE flingapp.freelancer(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL DEFAULT 'John',
  last_name TEXT NOT NULL DEFAULT 'Doe',
  is_native_speaker BOOLEAN NOT NULL DEFAULT true,
  fl_assessment_submitted BOOLEAN NOT NULL DEFAULT false,
  fl_assessment_passed BOOLEAN NOT NULL DEFAULT false,
  location flingapp.country NOT NULL,
  timezone flingapp.timezone NOT NULL DEFAULT 'UTC +00:00 (+00:00)',
  primary_language flingapp.language NOT NULL,
  employment_status flingapp.employment_status NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
   CONSTRAINT freelancer_pkey PRIMARY KEY (id)
);
-- comments for postgraphQL docs
COMMENT ON TABLE flingapp.freelancer IS 'A freelancer added to fling; Can be attached to a project and workhistory.';
COMMENT ON COLUMN flingapp.freelancer.id IS 'The universally unique ID of a freelancer in the flingapp db';
COMMENT ON COLUMN flingapp.freelancer.first_name IS 'A freelancer''s first, or given name';
COMMENT ON COLUMN flingapp.freelancer.last_name IS 'A freelancer''s last, or family name';
COMMENT ON COLUMN flingapp.freelancer.is_native_speaker IS 'Whether or not the freelancer is a native speaker of organization''s primary language.';
COMMENT ON COLUMN flingapp.freelancer.fl_assessment_submitted IS 'Whether the freelancer has successfully submitted a freelancer assessment.';
COMMENT ON COLUMN flingapp.freelancer.fl_assessment_passed IS 'Whether the freelancer successfully passed a freelancer assessment.';
COMMENT ON COLUMN flingapp.freelancer.location IS 'Where the freelancer is located. Is a country enum type.'; 
COMMENT ON COLUMN flingapp.freelancer.timezone IS 'Which timezone the freelancer is in. Is a tz database (https://www.iana.org/time-zones) timezone enum type.'; 
COMMENT ON COLUMN flingapp.freelancer.primary_language IS 'Which languages a freelancer primarily communicates in. Is a language enum type';  
COMMENT ON COLUMN flingapp.freelancer.created_at IS 'The time at which the freelancer record was created';  
COMMENT ON COLUMN flingapp.freelancer.updated_at IS 'The time at which the freelancer record was last updated';  

-- unique roles for any freelancers within your organization
CREATE TABLE flingapp.freelancer_role(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  role TEXT NOT NULL UNIQUE,
  CONSTRAINT freelancer_role_pkey PRIMARY KEY (id),
  CONSTRAINT freelancer_role_role_key UNIQUE (role)
);
-- comments for the freelancer roles
COMMENT ON TABLE flingapp.freelancer_role IS 'A role that a freelancer can be assigned';
COMMENT ON COLUMN flingapp.freelancer_role.id IS 'The universally unique ID of a role';
COMMENT ON COLUMN flingapp.freelancer_role.role IS 'The text description of a role';

-- many-to-many mapping between freelancers and roles within your org
CREATE TABLE flingapp.freelancer_role_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  role UUID NOT NULL,
  freelancer UUID NOT NULL,
  CONSTRAINT freelancer_role_map_pkey PRIMARY KEY (role, freelancer),
  CONSTRAINT freelancer_role_map_role_fkey FOREIGN KEY (role) 
    REFERENCES flingapp.freelancer_role (id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_role_map_freelancer_fkey FOREIGN KEY (freelancer) 
    REFERENCES flingapp.freelancer (id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to roles
COMMENT ON TABLE flingapp.freelancer_role_map IS 'A role that a freelancer can be assigned';
COMMENT ON COLUMN flingapp.freelancer_role_map.id IS 'The universally unique ID of a entry in the freelancer to role mapping';
COMMENT ON COLUMN flingapp.freelancer_role_map.role IS 'The universally unique ID of a role in the freelancer to role mapping';
COMMENT ON COLUMN flingapp.freelancer_role_map.freelancer IS 'The universally unique ID of a freelancer in the freelancer to role mapping';

-- many-to-many mapping between languages and freelancers. Different to primary language -- this is the other languages freelancers can speak
CREATE TABLE flingapp.freelancer_language_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  language flingapp.language NOT NULL,
  freelancer UUID NOT NULL, 
  CONSTRAINT freelancer_language_map_pkey PRIMARY KEY (language, freelancer),
  CONSTRAINT freelancer_language_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer (id) MATCH SIMPLE 
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to languages
COMMENT ON TABLE flingapp.freelancer_language_map IS 'A mapping of all languages a freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_language_map.id IS 'The universally unique ID of a entry in the freelancer to language mapping';
COMMENT ON COLUMN flingapp.freelancer_language_map.language IS 'A language enum type that the freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_language_map.freelancer IS 'The universally unique ID of a freelancer in the freelancer to language mapping';

-- many-to-many mapping of freelancer and employment status */
CREATE TABLE flingapp.freelancer_employment_status_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  status flingapp.employment_status NOT NULL,
  freelancer UUID NOT NULL,
  CONSTRAINT freelancer_employment_status_map_pkey PRIMARY KEY (status, freelancer),
  CONSTRAINT freelancer_employment_status_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer (id)
);
-- comments for the mapping of freelancers to employment status
COMMENT ON TABLE flingapp.freelancer_employment_status_map IS 'A mapping of all employment statuses of a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.id IS 'The universally unique ID of a entry in the freelancer to employment status mapping';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.status IS 'A employment status enum type that the freelancer can speak';
COMMENT ON COLUMN flingapp.freelancer_employment_status_map.freelancer IS 'The universally unique ID of a freelancer in the freelancer to employment status mapping';

-- many-to-many mapping of freelancer and external links
CREATE TABLE flingapp.freelancer_external_links_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  link TEXT NOT NULL,
  freelancer UUID NOT NULL,
  CONSTRAINT freelancer_external_links_map_pkey PRIMARY KEY (link, freelancer),
  CONSTRAINT freelancer_external_links_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer(id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for the mapping of freelancers to external links
COMMENT ON TABLE flingapp.freelancer_external_links_map IS 'A mapping of all external links of a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.id IS 'The universally unique ID of a entry in the freelancer to external link mapping status mapping';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.link IS 'URL of external link for freelancer';
COMMENT ON COLUMN flingapp.freelancer_external_links_map.freelancer IS 'The universally unique ID of a freelancer in the freelancer to external links mapping';


-- core file store
CREATE TABLE flingapp_private.file_store(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  file_data BYTEA NOT NULL,
  file_name TEXT NOT NULL,
  created_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMP WITHOUT TIME ZONE DEFAULT timezone('utc'::text, now()),
  owner UUID NOT NULL,
  organization UUID NOT NULL,
  CONSTRAINT file_store_pkey PRIMARY KEY (id),
  CONSTRAINT file_store_owner_fkey FOREIGN KEY (owner)
    REFERENCES flingapp_private.user_account(id)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT file_store_organization_fkey FOREIGN KEY (organization)
    REFERENCES flingapp.organization(id)
    ON DELETE CASCADE
);
-- comments for file store
COMMENT ON TABLE flingapp_private.file_store IS 'The central file store of flingapp.';
COMMENT ON COLUMN flingapp_private.file_store.id IS 'The universally unique ID of each file in the file store';
COMMENT ON COLUMN flingapp_private.file_store.file_data IS 'The binary data of the files stored in the flingapp db';
COMMENT ON COLUMN flingapp_private.file_store.file_name IS 'The file name of the a file stored in the flingapp db';
COMMENT ON COLUMN flingapp_private.file_store.created_at IS 'The timestamp of when the file was created.';
COMMENT ON COLUMN flingapp_private.file_store.updated_at IS 'The timestamp of when the file was last updated.';
COMMENT ON COLUMN flingapp_private.file_store.owner IS 'The universally unique ID of a flingapp user who owns the file.';


-- many-to-many mapping of files to freelancers
CREATE TABLE flingapp.freelancer_file_store_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  file UUID NOT NULL,
  freelancer UUID NOT NULL,
  doc_type TEXT NOT NULL,
  CONSTRAINT freelancer_file_store_map_pkey PRIMARY KEY (file, freelancer),
  CONSTRAINT freelancer_file_store_map_file_fkey FOREIGN KEY (file)
    REFERENCES flingapp_private.file_store (id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_file_store_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer(id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for file store mapping to freelancers
COMMENT ON TABLE flingapp.freelancer_file_store_map IS 'The mapping of files in the file store to a freelancer.';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.id IS 'The universally unique ID of each file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.file IS 'The universally unique ID of a file in the in the file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.freelancer IS 'The universally unique ID of a freelancer in the file to freelancer map';
COMMENT ON COLUMN flingapp.freelancer_file_store_map.doc_type IS 'A label for the type of file stored. E.g. ''Text''';


-- core project store
CREATE TABLE flingapp.project(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  description TEXT,
  organization UUID NOT NULL,
  CONSTRAINT project_pkey PRIMARY KEY (id),
  CONSTRAINT project_organization_fkey FOREIGN KEY (organization)
    REFERENCES flingapp.organization (id)
    ON DELETE RESTRICT
);
-- comments for project store
COMMENT ON TABLE flingapp.project IS 'A store for all projects registered for an organization.';
COMMENT ON COLUMN flingapp.project.id IS 'The universally unique ID of each project in the store.';
COMMENT ON COLUMN flingapp.project.name IS 'The name of an organization''s project.';
COMMENT ON COLUMN flingapp.project.start_date IS 'The start date of an organization''s project';
COMMENT ON COLUMN flingapp.project.end_date IS 'The end date of an organization''s project';
COMMENT ON COLUMN flingapp.project.description IS 'A text description of an organization''s project.';
COMMENT ON COLUMN flingapp.project.organization IS 'The universally unique ID of an organization that run/ran this project.';


-- many-to-many mapping of project to freelancer 
CREATE TABLE flingapp.project_freelancer_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  freelancer UUID NOT NULL,
  project UUID NOT NULL,
  CONSTRAINT project_freelancer_map_pkey PRIMARY KEY (freelancer, project),
  CONSTRAINT project_freelancer_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer (id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT project_freelancer_map_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.project (id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comments for project to freelancer map
COMMENT ON TABLE flingapp.project_freelancer_map IS 'A mapping of freelancers to projects.';
COMMENT ON COLUMN flingapp.project_freelancer_map.id IS 'The universally unique ID of a project to freelancer map.';
COMMENT ON COLUMN flingapp.project_freelancer_map.freelancer IS 'The universally unique ID of a freelancer mapped to a project.';
COMMENT ON COLUMN flingapp.project_freelancer_map.project IS 'The universally unique ID of a project mapped to a freelancer.';

-- many-to-many mapping of file to project
CREATE TABLE flingapp.project_file_store_map(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  file UUID NOT NULL,
  project UUID NOT NULL,
  doc_type TEXT NOT NULL,
  CONSTRAINT project_file_store_map_pkey PRIMARY KEY (file, project),
  CONSTRAINT project_file_store_map_file_fkey FOREIGN KEY (file)
    REFERENCES flingapp_private.file_store (id)
    ON DELETE RESTRICT,
  CONSTRAINT project_file_store_map_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.project (id)
    ON DELETE RESTRICT
);
-- comments for file store mapping to project
COMMENT ON TABLE flingapp.project_file_store_map IS 'The mapping of files in the file store to a project.';
COMMENT ON COLUMN flingapp.project_file_store_map.id IS 'The universally unique ID of a file to project map';
COMMENT ON COLUMN flingapp.project_file_store_map.file IS 'The universally unique ID of a file mapped to a project';
COMMENT ON COLUMN flingapp.project_file_store_map.project IS 'The universally unique ID of a project mapped to a file.';
COMMENT ON COLUMN flingapp.project_file_store_map.doc_type IS 'A label for the type of file stored. E.g. ''Text''';


-- many-to-many mapping of role to project
CREATE TABLE flingapp.project_role_map(
  id UUID DEFAULT gen_random_uuid(),
  role UUID UNIQUE NOT NULL,
  project UUID UNIQUE NOT NULL,
  CONSTRAINT project_role_map_pkey PRIMARY KEY (role, project),
  CONSTRAINT project_role_map_role_fkey FOREIGN KEY (role)
    REFERENCES flingapp.freelancer_role (id)
    ON DELETE RESTRICT,
  CONSTRAINT project_role_map_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.project (id)
    ON DELETE RESTRICT
);
-- comments for role mapping to project
COMMENT ON TABLE flingapp.project_role_map IS 'The mapping of roles to a project.';
COMMENT ON COLUMN flingapp.project_role_map.id IS 'The universally unique ID of a role to project map';
COMMENT ON COLUMN flingapp.project_role_map.role IS 'The universally unique ID of a role to a project';
COMMENT ON COLUMN flingapp.project_role_map.project IS 'The universally unique ID of a project mapped to a role.';


-- core work item types for project
CREATE TABLE flingapp.work_item(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  CONSTRAINT work_item_pkey PRIMARY KEY (id)
);
-- comments for work item types
COMMENT ON TABLE flingapp.work_item IS 'The store of work items in flingapp db.';
COMMENT ON COLUMN flingapp.work_item.id IS 'The universally unique ID of a work item type';
COMMENT ON COLUMN flingapp.work_item.name IS 'The name of the work item';
COMMENT ON COLUMN flingapp.work_item.description IS 'The description of the work item';


-- many-to-many mapping of work items to projects
CREATE TABLE flingapp.project_work_item_map(
  id UUID DEFAULT gen_random_uuid(),
  work_item UUID NOT NULL,
  project UUID NOT NULL,
  CONSTRAINT project_work_item_map_pkey PRIMARY KEY (work_item, project),
  CONSTRAINT project_work_item_map_work_item_fkey FOREIGN KEY (work_item)
    REFERENCES flingapp.work_item (id)
    ON DELETE RESTRICT,
  CONSTRAINT project_work_item_map_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.project (id)
    ON DELETE RESTRICT
);
-- comments for work item mapping to project
COMMENT ON TABLE flingapp.project_role_map IS 'The mapping of work items to a project.';
COMMENT ON COLUMN flingapp.project_role_map.id IS 'The universally unique ID of a work item to project map';
COMMENT ON COLUMN flingapp.project_role_map.role IS 'The universally unique ID of a work item mapped to a project';
COMMENT ON COLUMN flingapp.project_role_map.project IS 'The universally unique ID of a project mapped to a work item.';


-- many-to-many mapping of freelancers to projects 
CREATE TABLE flingapp.work_history(
  id UUID NOT NULL DEFAULT gen_random_uuid(),
  freelancer UUID NOT NULL,
  project UUID NOT NULL,
  role UUID NOT NULL,
  payment_currency flingapp.payment_currency NOT NULL default 'USD',
  payment_rate NUMERIC NOT NULL DEFAULT 0.00,
  main_work_item UUID NOT NULL,
  start_date DATE NOT NULL,
  finish_date DATE NOT NULL,
  performance SMALLINT NOT NULL,
  did_complete BOOLEAN NOT NULL DEFAULT false,
  reason_for_dropout TEXT,
  -- keys
  CONSTRAINT work_history_pkey PRIMARY KEY (id),
  CONSTRAINT work_history_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer (id)
    ON DELETE RESTRICT,
  CONSTRAINT work_history_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.project (id)
    ON DELETE RESTRICT,
  CONSTRAINT work_history_role_fkey FOREIGN KEY (role)
    REFERENCES flingapp.freelancer_role(id)
    ON DELETE RESTRICT, 
  CONSTRAINT work_history_main_work_item_fkey FOREIGN KEY (main_work_item)
    REFERENCES flingapp.work_item (id)
    ON DELETE RESTRICT
);
-- comments for work history store
COMMENT ON TABLE flingapp.work_history IS 'The store of all freelancers work experience with an organization.';
COMMENT ON COLUMN flingapp.work_history.id IS 'The universally unique ID of piece of work experience in work history store.';
COMMENT ON COLUMN flingapp.work_history.freelancer IS 'The universally unique ID of freelancer who owns the experience';
COMMENT ON COLUMN flingapp.work_history.project IS 'The universally unique ID of a project that generated the work experience.';
COMMENT ON COLUMN flingapp.work_history.role IS 'The universally unique ID of a role that the freelancer took on the work experience.';
COMMENT ON COLUMN flingapp.work_history.payment_currency IS 'The payment currency for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.payment_rate IS 'The payment rate for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.main_work_item IS 'The main work item for a piece of work experience';
COMMENT ON COLUMN flingapp.work_history.start_date IS 'The start date of a freelancer''s work experience';
COMMENT ON COLUMN flingapp.work_history.finish_date IS 'The start date of a freelancer''s work experience';
COMMENT ON COLUMN flingapp.work_history.performance IS 'A whole number integer rating of the freelancer''s performance';
COMMENT ON COLUMN flingapp.work_history.did_complete IS 'Whether the freelancer completed the project';
COMMENT ON COLUMN flingapp.work_history.reason_for_dropout IS 'A reason why the freelancer didn''t complete a project';

-- many-to-many mapping of files to work history 
CREATE TABLE flingapp.work_history_file_map(
  id UUID DEFAULT gen_random_uuid(),
  file UUID NOT NULL ,
  experience UUID NOT NULL,
  doc_type TEXT NOT NULL,
  -- keys
  CONSTRAINT work_history_file_map_pkkey PRIMARY KEY (file, experience),
  CONSTRAINT work_history_file_map_file_fkey FOREIGN KEY (file)
    REFERENCES flingapp_private.file_store (id) MATCH SIMPLE
    ON DELETE RESTRICT,
  CONSTRAINT work_history_file_map_experience_fkey FOREIGN KEY (experience)
    REFERENCES flingapp.work_history (id) MATCH SIMPLE
    ON DELETE RESTRICT
);
-- comment on file store to work history map
COMMENT ON TABLE flingapp.work_history_file_map IS 'A map of work history to files';
COMMENT ON COLUMN flingapp.work_history_file_map.id IS 'The universally unique ID of a map of a file to a piece of work experience';
COMMENT ON COLUMN flingapp.work_history_file_map.file IS 'The universally unique ID of a file mapped to some work experience.';
COMMENT ON COLUMN flingapp.work_history_file_map.experience IS 'The universally unique ID of some work experience mapped to a file.';
COMMENT ON COLUMN flingapp.work_history_file_map.doc_type IS 'The type of document mapped to the work experience. E.g ''text''';


-- core tag / note / comment store
CREATE TABLE flingapp.text_note(
  id UUID DEFAULT gen_random_uuid(),
  body TEXT NOT NULL,
  type flingapp.text_note_types NOT NULL,
  owner UUID NOT NULL,
  CONSTRAINT text_note_pkey PRIMARY KEY (id),
  CONSTRAINT text_note_owner_fkey FOREIGN KEY (owner)
    REFERENCES flingapp_private.user_account (id)
    ON DELETE RESTRICT
);
-- comment on text notes store
COMMENT ON TABLE flingapp.text_note IS 'A store of all textual notes in the flingapp db';
COMMENT ON COLUMN flingapp.text_note.id IS 'The universally unique ID of a text note';
COMMENT ON COLUMN flingapp.text_note.body IS 'The body text of a text note';
COMMENT ON COLUMN flingapp.text_note.type IS 'The type of the text note e.g. ''tag''';
COMMENT ON COLUMN flingapp.text_note.owner IS 'The universally unique ID of the owner of the text note';


-- many-to-many mapping of freelancers to text notes
CREATE TABLE flingapp.freelancer_text_note_map(
  id UUID DEFAULT gen_random_uuid(),
  freelancer UUID NOT NULL,
  text_note UUID NOT NULL,
  CONSTRAINT freelancer_text_note_map_pkey PRIMARY KEY (freelancer, text_note),
  CONSTRAINT freelancer_text_note_map_freelancer_fkey FOREIGN KEY (freelancer)
    REFERENCES flingapp.freelancer (id)
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_text_note_map_text_note_fkey FOREIGN KEY (text_note)
    REFERENCES flingapp.text_note (id)
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.freelancer_text_note_map IS 'A store of all mappings of text notes to freelancers';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.id IS 'The universally unique ID of a mapping between a text note and a freelancer';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.freelancer IS 'The universally unique ID of a freelancer mapped to a text note';
COMMENT ON COLUMN flingapp.freelancer_text_note_map.text_note IS 'The universally unique ID of a text note mapped to a freelancer';

-- many-to-many mapping of projects to text notes
CREATE TABLE flingapp.project_text_note_map(
  id UUID DEFAULT gen_random_uuid(),
  project UUID NOT NULL,
  text_note UUID NOT NULL,
  CONSTRAINT project_text_note_map_pkey PRIMARY KEY (project, text_note),
  CONSTRAINT project_text_note_map_project_fkey FOREIGN KEY (project)
    REFERENCES flingapp.freelancer (id)
    ON DELETE RESTRICT,
  CONSTRAINT freelancer_text_note_map_text_note_fkey FOREIGN KEY (text_note)
    REFERENCES flingapp.text_note (id)
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.project_text_note_map IS 'A store of all mappings of text notes to projects';
COMMENT ON COLUMN flingapp.project_text_note_map.id IS 'The universally unique ID of a mapping between a text note and a project';
COMMENT ON COLUMN flingapp.project_text_note_map.project IS 'The universally unique ID of a project mapped to a text note';
COMMENT ON COLUMN flingapp.project_text_note_map.text_note IS 'The universally unique ID of a text note mapped to a project';


-- many-to-many mapping of work history to text notes
CREATE TABLE flingapp.work_history_text_note_map(
  id UUID DEFAULT gen_random_uuid(),
  work_history UUID NOT NULL,
  text_note UUID NOT NULL,
  CONSTRAINT work_history_text_note_map_pkey PRIMARY KEY (work_history, text_note),
  CONSTRAINT work_history_text_note_map_work_history_fkey FOREIGN KEY (work_history)
    REFERENCES flingapp.work_history (id)
    ON DELETE RESTRICT,
  CONSTRAINT work_history_text_note_map_text_note_fkey FOREIGN KEY (text_note)
    REFERENCES flingapp.text_note (id)
    ON DELETE CASCADE
);
-- comment on freelancers to text notes
COMMENT ON TABLE flingapp.work_history_text_note_map IS 'A store of all mappings of text notes to work history';
COMMENT ON COLUMN flingapp.work_history_text_note_map.id IS 'The universally unique ID of a mapping between a text note and work history';
COMMENT ON COLUMN flingapp.work_history_text_note_map.work_history IS 'The universally unique ID of work history mapped to a text note';
COMMENT ON COLUMN flingapp.work_history_text_note_map.text_note IS 'The universally unique ID of a text note mapped to work history';

commit;


-- let's create the functions that allow us to do stuff in our DB

-- register a user
CREATE FUNCTION flingapp.register_user(
  first_name text,
  last_name text,
  display_name text,
  email text,
  password text
) returns flingapp.user as $$
DECLARE
  user flingapp.user;
  user_account flingapp_private.user_account;
BEGIN
  INSERT INTO flingapp_private.user_account (email, password_hash) VALUES
    (email, crypt(password, gen_salt('bf', 8)))
    RETURNING * into user_account;

  INSERT INTO flingapp.user (id, first_name, last_name, display_name) VALUEs
    (user_account.id, first_name, last_name, display_name)
    RETURNING * into user;

  RETURN user;
END;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;
COMMENT ON FUNCTION flingapp.register_user(text, text, text, text, text) IS 'Registers a single user and creates an account in flingapp.';




-- create privileges for each account
-- SCHEMA GRANTS
GRANT USAGE ON SCHEMA flingapp TO :flinganon, :flinguser;

-- TABLE GRANTS
GRANT SELECT ON TABLE flingapp.freelancer to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_employment_status_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_employment_status_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_external_links_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_external_links_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_file_store_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_file_store_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_language_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_language_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_role to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_role to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_role_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_role_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.freelancer_text_note_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.freelancer_text_note_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.organization to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.organization to :flinguser ;

GRANT SELECT ON TABLE flingapp.project to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project to :flinguser ;

GRANT SELECT ON TABLE flingapp.project_file_store_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project_file_store_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.project_freelancer_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project_freelancer_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.project_role_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project_role_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.project_text_note_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project_text_note_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.project_work_item_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.project_work_item_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.text_note to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.text_note to :flinguser ;

GRANT SELECT ON TABLE flingapp.user to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.user to :flinguser ;

GRANT SELECT ON TABLE flingapp.user_org_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.user_org_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.work_history to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history to :flinguser ;

GRANT SELECT ON TABLE flingapp.work_history_file_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history_file_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.work_history_text_note_map to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.work_history_text_note_map to :flinguser ;

GRANT SELECT ON TABLE flingapp.work_item to :flinganon, :flinguser;
GRANT UPDATE, DELETE ON TABLE flingapp.work_item to :flinguser ;

-- FUNCTION GRANTS
GRANT EXECUTE ON FUNCTION flingapp.register_user(text, text, text, text, text) to :flinganon;




