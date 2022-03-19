CREATE TABLE IF NOT EXISTS `business_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `entrantcitizenid` varchar(50) DEFAULT NULL,
  `entrantfirstname` varchar(25) DEFAULT NULL,
  `entrantlastname` varchar(25) DEFAULT NULL,
  `payercitizenid` varchar(50) DEFAULT NULL,
  `payerfirstname` varchar(25) DEFAULT NULL,
  `payerlastname` varchar(25) DEFAULT NULL,
  `businessname` varchar(50) DEFAULT NULL,
  `businessid` int(11) DEFAULT NULL,
  `items` text DEFAULT NULL,
  `date` datetime DEFAULT current_timestamp(),
  `price` int(11) DEFAULT NULL,
  `selfcheckout` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `entrantcitizenid` (`entrantcitizenid`),
  KEY `payercitizenid` (`payercitizenid`),
  KEY `businessid` (`businessid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `business_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `businessid` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `businessid` (`businessid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE IF NOT EXISTS `businesses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

INSERT INTO `businesses` (id, name) VALUES (1, 'uwu');

INSERT INTO `business_items` (name, price, businessid) VALUES
  ('chickenwrap', 100, 1),
  ('frenchtoast', 100, 1),
  ('cupcake', 100, 1),
  ('macarons', 100, 1),
  ('mochichocolate', 100, 1),
  ('mochimint', 100, 1),
  ('mochiraspberry', 100, 1),
  ('mochitangerine', 100, 1),
  ('mochivanilla', 100, 1),
  ('mochiwatermelon', 100, 1),
  ('ramen', 200, 1),
  ('bobaraz', 50, 1),
  ('bobachocolate', 50, 1),
  ('bobamint', 50, 1),
  ('bobastrawberry', 50, 1),
  ('bobavanilla', 50, 1),
  ('bobawatermelon', 50, 1),
  ('chaitea', 50, 1),
  ('waterbottle', 50, 1);