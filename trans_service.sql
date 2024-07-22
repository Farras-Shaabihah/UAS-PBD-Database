-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 22, 2024 at 05:23 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `trans_service`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crew_salary_condition` (IN `id` INT, OUT `salary_level` VARCHAR(10))   BEGIN
	SET @salary = (SELECT salary FROM crew WHERE crew_id = id);
	IF (@salary <= 2000000) THEN SET salary_level = 'Low';
    ELSEIF (@salary <= 2500000) THEN SET salary_level = 'Medium';
    ELSEIF (@salary > 2500000) THEN SET salary_level = 'High';
    ELSE SET salary_level = 'NA';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_trip_detail` ()   BEGIN
	SELECT tl.trip_log_id, tl.bus_id, s.route_id, s.driver, s.conductor, tl.start_time, tl.end_time, tl.total_passenger, tl.total_distance,
    CASE
    	WHEN tl.total_passenger <= 25 THEN 'Low Quota Met'
        WHEN tl.total_passenger <= 50 THEN 'Average Quota Met'
        WHEN tl.total_passenger > 50 THEN 'High Quota Met'
        ELSE 'Not Identified'
    END AS level_passenger
    FROM trip_log AS tl
    JOIN bus AS b USING(bus_id)
    JOIN scedule AS s USING(scedule_id)
    ORDER BY tl.trip_log_id;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `f_all_bus_status_inactive` () RETURNS INT(11)  BEGIN
	DECLARE insertedID INT;
	UPDATE bus_status SET status = 'Inactive' WHERE status != 'Not Available Anymore';
	SET insertedID = 1;
	RETURN insertedID;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `f_salary_change` (`id` INT, `new_salary` INT) RETURNS VARCHAR(7) CHARSET utf8mb4 COLLATE utf8mb4_general_ci  BEGIN
	DECLARE execution varchar(7);
    UPDATE crew SET salary = new_salary WHERE crew_id = id;
    SET execution = 'Success';
    RETURN execution;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bus`
--

CREATE TABLE `bus` (
  `bus_id` varchar(20) NOT NULL,
  `manufacture_id` varchar(20) NOT NULL,
  `start_operating_date` date NOT NULL,
  `machine_type` varchar(20) NOT NULL,
  `km_count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bus`
--

INSERT INTO `bus` (`bus_id`, `manufacture_id`, `start_operating_date`, `machine_type`, `km_count`) VALUES
('B1', 'M1', '2024-07-07', 'W04D-TN', 99),
('B2', 'M1', '2024-07-08', 'W04D-TN', 0),
('B3', 'M2', '2024-06-04', 'W04D-TN', 256),
('B4', 'M3', '2024-03-01', 'W04D-TN', 5065),
('B5', 'M1', '2024-06-20', 'W04D-TN', 1349),
('B6', 'M4', '2024-07-10', 'W04D-TN', 276);

--
-- Triggers `bus`
--
DELIMITER $$
CREATE TRIGGER `insert_new_bus_status` AFTER INSERT ON `bus` FOR EACH ROW BEGIN
	INSERT INTO bus_status(bus_id, status) VALUES (new.bus_id, 'Available');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `nonactive_bus_status` AFTER DELETE ON `bus` FOR EACH ROW BEGIN
	UPDATE bus_status SET status = 'Not Available Anymore' WHERE bus_id = old.bus_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `reset_bus_status` BEFORE UPDATE ON `bus` FOR EACH ROW BEGIN
	IF EXISTS(SELECT * FROM bus WHERE km_count > 5000) THEN
	UPDATE bus_status SET status = "Need Service" WHERE bus_id = new.bus_id;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `bus_status`
--

CREATE TABLE `bus_status` (
  `bus_id` varchar(20) NOT NULL,
  `status` varchar(25) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `bus_status`
--

INSERT INTO `bus_status` (`bus_id`, `status`) VALUES
('B1', 'Need Service'),
('B2', 'In Sevice'),
('B3', 'Available'),
('B4', 'Need Service'),
('B5', 'Available'),
('B6', 'Available'),
('B7', 'Not Available Anymore'),
('B8', 'Not Available Anymore'),
('B9', 'Not Available Anymore'),
('B10', 'Not Available Anymore');

-- --------------------------------------------------------

--
-- Table structure for table `crew`
--

CREATE TABLE `crew` (
  `crew_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `gender` char(1) NOT NULL,
  `age` int(11) NOT NULL,
  `years_worked` int(11) NOT NULL,
  `salary` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `crew`
--

INSERT INTO `crew` (`crew_id`, `name`, `gender`, `age`, `years_worked`, `salary`) VALUES
(1, 'Jono', 'M', 28, 3, 2200000),
(2, 'Paijo', 'M', 25, 1, 1900000),
(3, 'Anisa', 'F', 27, 7, 3000000),
(4, 'Udin', 'M', 30, 4, 2450000),
(5, 'Indah', 'F', 22, 2, 2700000);

--
-- Triggers `crew`
--
DELIMITER $$
CREATE TRIGGER `delete_crew_contact` BEFORE DELETE ON `crew` FOR EACH ROW BEGIN
	DELETE FROM crew_contact WHERE crew_id = old.crew_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `crew_contact`
--

CREATE TABLE `crew_contact` (
  `crew_id` int(11) NOT NULL,
  `hp_number` varchar(20) NOT NULL,
  `address` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `crew_contact`
--

INSERT INTO `crew_contact` (`crew_id`, `hp_number`, `address`) VALUES
(1, '081234567890', 'Condong Catur'),
(2, '087846895382', 'Giwangan'),
(3, '082439476258', 'Giwangan'),
(4, '089435791351', 'Lempuyangan'),
(5, '083931591043', 'Jombor');

-- --------------------------------------------------------

--
-- Table structure for table `manufacture`
--

CREATE TABLE `manufacture` (
  `manufacture_id` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  `hp_number` varchar(20) NOT NULL,
  `address` varchar(100) NOT NULL,
  `email` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `manufacture`
--

INSERT INTO `manufacture` (`manufacture_id`, `name`, `hp_number`, `address`, `email`) VALUES
('M1', 'PT. Hino Motors Sales Indonesia', '084826147192', 'Dangdeur', 'hino@gmail.com'),
('M2', 'PT. Duta Cemerlang Motor', '083895619689', 'Masaran', 'dcm@gmail.com'),
('M3', 'PT. Bus Indonesia', '081947986149', 'Ngabean', 'busindonesia@gmail.com'),
('M4', 'PT. Motor Bersinar', '089468278946', 'Dangdeur', 'motorbersinar@gmail.com'),
('M5', 'PT. Pundi Pundi Negara', '084189347584', 'Ngabean', 'pundinegara@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `route`
--

CREATE TABLE `route` (
  `route_id` varchar(5) NOT NULL,
  `start_point` varchar(100) NOT NULL,
  `end_point` varchar(100) NOT NULL,
  `start_operational_time` time NOT NULL,
  `end_operational_time` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `route`
--

INSERT INTO `route` (`route_id`, `start_point`, `end_point`, `start_operational_time`, `end_operational_time`) VALUES
('10', 'Park Gamping', 'Stadion Kridosono', '05:30:00', '21:30:00'),
('11', 'Lowanu', 'Condong catur', '05:30:00', '21:30:00'),
('13', 'Terminal Ngabean (A)', 'Pusat Kuliner Belut Godean', '05:30:00', '21:30:00'),
('14', 'Halte TJ Bandara Adisucipto', 'Terminal Pakem', '05:30:00', '21:30:00'),
('15', 'Terminal Ngabean (A)', 'Terminal Palbapang (B)', '05:30:00', '21:30:00'),
('1B', 'Condong Catur', 'Bandara Adi Sutjipto', '05:30:00', '21:30:00'),
('2B', 'Condong Catur', 'Terminal Ngabean', '05:30:00', '21:30:00'),
('3A', 'Terminal Giwangan', 'Condong Catur', '05:30:00', '21:30:00'),
('3B', 'Terminal Giwangan', 'Condong Catur', '05:30:00', '21:30:00'),
('4A', 'Terminal Giwangan', 'RSUP Sardjito', '05:30:00', '21:30:00'),
('4B', 'Terminal Giwangan', 'UGM', '05:30:00', '21:30:00'),
('5A', 'Terminal Jombor', 'Ambarukmo', '05:30:00', '21:30:00'),
('5B', 'Terminal Jombor', 'Bandara Adi Sutjipto', '05:30:00', '21:30:00'),
('6A', 'Park Gamping', 'Pasar Ngabean', '05:30:00', '21:30:00'),
('6B', 'Park Gamping', 'Pasar Ngabean', '05:30:00', '21:30:00'),
('7', 'Terminal Giwangan', 'Babarsari', '05:30:00', '21:30:00'),
('8', 'Terminal Jombor', 'Jogokaryan', '05:30:00', '21:30:00'),
('9', 'Terminal Giwangan', 'Terminal Jombor', '05:30:00', '21:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `scedule`
--

CREATE TABLE `scedule` (
  `scedule_id` int(11) NOT NULL,
  `bus_id` varchar(20) NOT NULL,
  `route_id` varchar(5) NOT NULL,
  `driver` int(11) NOT NULL,
  `conductor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `scedule`
--

INSERT INTO `scedule` (`scedule_id`, `bus_id`, `route_id`, `driver`, `conductor`) VALUES
(6, 'B1', '3B', 1, 2),
(7, 'B2', '3A', 3, 4),
(8, 'B5', '10', 5, 3),
(9, 'B3', '1B', 4, 5),
(10, 'B4', '3A', 1, 4),
(11, 'B6', '3B', 2, 5);

-- --------------------------------------------------------

--
-- Table structure for table `service_log`
--

CREATE TABLE `service_log` (
  `service_id` int(11) NOT NULL,
  `bus_id` varchar(20) NOT NULL,
  `provider_id` varchar(5) NOT NULL,
  `start_date` date NOT NULL,
  `complete_date` date NOT NULL,
  `cost` int(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `service_log`
--

INSERT INTO `service_log` (`service_id`, `bus_id`, `provider_id`, `start_date`, `complete_date`, `cost`) VALUES
(1, 'B2', 'P1', '2024-08-02', '2024-08-04', 1200000),
(2, 'B3', 'P2', '2024-06-30', '2024-07-10', 8000000),
(3, 'B1', 'P1', '2024-07-08', '2024-07-09', 750000),
(4, 'B4', 'P3', '2024-06-01', '2024-06-03', 1200000),
(5, 'B5', 'P1', '2024-07-03', '2024-07-05', 1200000),
(6, 'B6', 'P4', '2024-07-11', '2024-07-14', 1250000),
(7, 'B8', 'P1', '2024-07-11', '2024-07-12', 0),
(9, 'B2', 'P1', '2024-07-14', '2024-07-14', 200000),
(10, 'B9', 'P1', '2024-07-14', '2024-07-14', 300000),
(11, 'B2', 'P1', '2024-06-20', '2024-06-23', 1450000),
(12, 'B2', 'P1', '2024-07-22', '2024-07-23', 200000),
(13, 'B10', 'P2', '2024-07-27', '2024-07-30', 1350000);

--
-- Triggers `service_log`
--
DELIMITER $$
CREATE TRIGGER `update_bus_status` AFTER INSERT ON `service_log` FOR EACH ROW BEGIN
	UPDATE bus_status SET status = 'In Service' WHERE bus_id = new.bus_id;
    UPDATE bus SET km_count = 0 WHERE bus_id = new.bus_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `service_provider`
--

CREATE TABLE `service_provider` (
  `provider_id` varchar(5) NOT NULL,
  `name` varchar(50) NOT NULL,
  `address` varchar(100) NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `email` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `service_provider`
--

INSERT INTO `service_provider` (`provider_id`, `name`, `address`, `contact_number`, `email`) VALUES
('P1', 'PT. Hino Motors Sales Indonesia', 'Dangdeur', '084826147192', 'hino@gmail.com'),
('P2', 'PT. Duta Cemerlang Motor', 'Masaran', '083895619689', 'dcm@gmail.com'),
('P3', 'PT. Bus Indonesia', 'Ngabean', '081947986149', 'busindonesia@gmail.com'),
('P4', 'PT. Motor Bersinar', 'Dangdeur', '089468278946', 'motorbersinar@gmail.com'),
('P5', 'PT. Pundi Pundi Negara', 'Ngabean', '084189347584', 'pundinegara@gmail.com');

-- --------------------------------------------------------

--
-- Table structure for table `trip_log`
--

CREATE TABLE `trip_log` (
  `trip_log_id` int(11) NOT NULL,
  `bus_id` varchar(20) NOT NULL,
  `scedule_id` int(11) NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `total_passenger` int(11) NOT NULL,
  `total_distance` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `trip_log`
--

INSERT INTO `trip_log` (`trip_log_id`, `bus_id`, `scedule_id`, `start_time`, `end_time`, `total_passenger`, `total_distance`) VALUES
(1, 'B2', 7, '07:00:00', '08:10:00', 60, 30),
(2, 'B5', 8, '12:30:00', '13:45:00', 75, 30),
(3, 'B1', 6, '12:30:00', '13:35:00', 45, 30),
(4, 'B3', 9, '09:25:00', '10:35:00', 95, 30),
(5, 'B4', 10, '15:30:00', '16:55:00', 20, 30),
(6, 'B6', 11, '07:00:00', '08:30:00', 53, 34),
(7, 'B6', 11, '10:00:00', '11:35:00', 48, 30),
(8, 'B1', 6, '11:00:00', '12:35:00', 49, 30),
(50, 'B1', 6, '08:00:00', '09:10:00', 56, 60),
(51, 'B1', 6, '10:00:00', '11:30:00', 60, 28),
(52, 'B1', 6, '09:35:00', '11:15:00', 48, 39),
(53, 'B1', 6, '14:20:00', '16:05:00', 56, 32);

--
-- Triggers `trip_log`
--
DELIMITER $$
CREATE TRIGGER `revise_km_count` AFTER UPDATE ON `trip_log` FOR EACH ROW BEGIN
	UPDATE bus SET km_count = km_count - old.total_distance + new.total_distance WHERE bus_id = new.bus_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `update_km_count` BEFORE INSERT ON `trip_log` FOR EACH ROW BEGIN
	UPDATE bus SET km_count = km_count + new.total_distance WHERE bus_id = new.bus_id;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_giwangan_start`
-- (See below for the actual view)
--
CREATE TABLE `v_giwangan_start` (
`route_id` varchar(5)
,`start_point` varchar(100)
,`end_point` varchar(100)
,`start_operational_time` time
,`end_operational_time` time
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_giwangan_start_condongcatur_end`
-- (See below for the actual view)
--
CREATE TABLE `v_giwangan_start_condongcatur_end` (
`route_id` varchar(5)
,`start_point` varchar(100)
,`end_point` varchar(100)
,`start_operational_time` time
,`end_operational_time` time
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_route_initial`
-- (See below for the actual view)
--
CREATE TABLE `v_route_initial` (
`route_id` varchar(5)
);

-- --------------------------------------------------------

--
-- Structure for view `v_giwangan_start`
--
DROP TABLE IF EXISTS `v_giwangan_start`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_giwangan_start`  AS SELECT `route`.`route_id` AS `route_id`, `route`.`start_point` AS `start_point`, `route`.`end_point` AS `end_point`, `route`.`start_operational_time` AS `start_operational_time`, `route`.`end_operational_time` AS `end_operational_time` FROM `route` WHERE `route`.`start_point` = 'Terminal Giwangan' ;

-- --------------------------------------------------------

--
-- Structure for view `v_giwangan_start_condongcatur_end`
--
DROP TABLE IF EXISTS `v_giwangan_start_condongcatur_end`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_giwangan_start_condongcatur_end`  AS SELECT `v_giwangan_start`.`route_id` AS `route_id`, `v_giwangan_start`.`start_point` AS `start_point`, `v_giwangan_start`.`end_point` AS `end_point`, `v_giwangan_start`.`start_operational_time` AS `start_operational_time`, `v_giwangan_start`.`end_operational_time` AS `end_operational_time` FROM `v_giwangan_start` WHERE `v_giwangan_start`.`end_point` = 'Condong Catur'WITH CASCADED CHECK OPTION  ;

-- --------------------------------------------------------

--
-- Structure for view `v_route_initial`
--
DROP TABLE IF EXISTS `v_route_initial`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_route_initial`  AS SELECT `route`.`route_id` AS `route_id` FROM `route` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bus`
--
ALTER TABLE `bus`
  ADD PRIMARY KEY (`bus_id`),
  ADD KEY `manufacture_id` (`manufacture_id`),
  ADD KEY `start_operating_date` (`start_operating_date`,`machine_type`);

--
-- Indexes for table `crew`
--
ALTER TABLE `crew`
  ADD PRIMARY KEY (`crew_id`),
  ADD KEY `order_crew` (`name`,`gender`);

--
-- Indexes for table `crew_contact`
--
ALTER TABLE `crew_contact`
  ADD KEY `crew_id` (`crew_id`);

--
-- Indexes for table `manufacture`
--
ALTER TABLE `manufacture`
  ADD PRIMARY KEY (`manufacture_id`),
  ADD KEY `name` (`name`,`address`);

--
-- Indexes for table `route`
--
ALTER TABLE `route`
  ADD PRIMARY KEY (`route_id`);

--
-- Indexes for table `scedule`
--
ALTER TABLE `scedule`
  ADD PRIMARY KEY (`scedule_id`),
  ADD KEY `bus_id` (`bus_id`),
  ADD KEY `route_id` (`route_id`),
  ADD KEY `driver` (`driver`),
  ADD KEY `conductor` (`conductor`);

--
-- Indexes for table `service_log`
--
ALTER TABLE `service_log`
  ADD PRIMARY KEY (`service_id`),
  ADD KEY `bus_id` (`bus_id`),
  ADD KEY `provider_id` (`provider_id`);

--
-- Indexes for table `service_provider`
--
ALTER TABLE `service_provider`
  ADD PRIMARY KEY (`provider_id`);

--
-- Indexes for table `trip_log`
--
ALTER TABLE `trip_log`
  ADD PRIMARY KEY (`trip_log_id`),
  ADD KEY `bus_id` (`bus_id`),
  ADD KEY `scedule_id` (`scedule_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `crew`
--
ALTER TABLE `crew`
  MODIFY `crew_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `scedule`
--
ALTER TABLE `scedule`
  MODIFY `scedule_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `service_log`
--
ALTER TABLE `service_log`
  MODIFY `service_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `trip_log`
--
ALTER TABLE `trip_log`
  MODIFY `trip_log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `bus`
--
ALTER TABLE `bus`
  ADD CONSTRAINT `bus_ibfk_1` FOREIGN KEY (`manufacture_id`) REFERENCES `manufacture` (`manufacture_id`);

--
-- Constraints for table `bus_status`
--
ALTER TABLE `bus_status`
  ADD CONSTRAINT `bus_status_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `bus` (`bus_id`);

--
-- Constraints for table `crew_contact`
--
ALTER TABLE `crew_contact`
  ADD CONSTRAINT `crew_contact_ibfk_1` FOREIGN KEY (`crew_id`) REFERENCES `crew` (`crew_id`);

--
-- Constraints for table `scedule`
--
ALTER TABLE `scedule`
  ADD CONSTRAINT `scedule_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `bus` (`bus_id`),
  ADD CONSTRAINT `scedule_ibfk_2` FOREIGN KEY (`route_id`) REFERENCES `route` (`route_id`),
  ADD CONSTRAINT `scedule_ibfk_3` FOREIGN KEY (`driver`) REFERENCES `crew` (`crew_id`),
  ADD CONSTRAINT `scedule_ibfk_4` FOREIGN KEY (`conductor`) REFERENCES `crew` (`crew_id`);

--
-- Constraints for table `service_log`
--
ALTER TABLE `service_log`
  ADD CONSTRAINT `service_log_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `bus` (`bus_id`),
  ADD CONSTRAINT `service_log_ibfk_2` FOREIGN KEY (`provider_id`) REFERENCES `service_provider` (`provider_id`);

--
-- Constraints for table `trip_log`
--
ALTER TABLE `trip_log`
  ADD CONSTRAINT `trip_log_ibfk_1` FOREIGN KEY (`bus_id`) REFERENCES `bus` (`bus_id`),
  ADD CONSTRAINT `trip_log_ibfk_2` FOREIGN KEY (`scedule_id`) REFERENCES `scedule` (`scedule_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
