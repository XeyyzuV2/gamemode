-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 24 Jul 2024 pada 16.25
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `ksamp`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `dataucp`
--

CREATE TABLE `dataucp` (
  `id` int(11) NOT NULL,
  `ucp` varchar(32) NOT NULL,
  `verifikasi` int(11) NOT NULL,
  `aktivasi` int(11) NOT NULL DEFAULT 0,
  `katasandi` varchar(64) DEFAULT '',
  `discord` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(10) NOT NULL,
  `name` varchar(64) NOT NULL,
  `ucp` varchar(64) NOT NULL,
  `health` float NOT NULL DEFAULT 100,
  `armour` float NOT NULL DEFAULT 0,
  `posx` float NOT NULL DEFAULT 1682.61,
  `posy` float NOT NULL DEFAULT -2327.89,
  `posz` float NOT NULL DEFAULT 13.5469,
  `angel` float NOT NULL DEFAULT 3.4335,
  `interior` int(5) NOT NULL DEFAULT 0,
  `virtualworld` int(5) NOT NULL DEFAULT 0,
  `skin` int(5) NOT NULL DEFAULT 98,
  `level` int(3) NOT NULL DEFAULT 0,
  `money` int(10) NOT NULL DEFAULT 0,
  `kills` int(10) NOT NULL DEFAULT 0,
  `deaths` int(10) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci COMMENT='Tabelle für die Spieler-Statistiken';

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `dataucp`
--
ALTER TABLE `dataucp`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `dataucp`
--
ALTER TABLE `dataucp`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
