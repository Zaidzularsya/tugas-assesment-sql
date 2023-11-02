-- Membuat database 'db_perpustakaan'
CREATE DATABASE db_perpustakaan;

-- Menggunakan database yang baru dibuat
USE db_perpustakaan;

-- Membuat tabel 'log_buku'
CREATE TABLE log_buku (
  log_id int(11) AUTO_INCREMENT,
  id_buku int(11),
  tgl_log timestamp,
  perubahan_stok int(11),
  keterangan varchar(512),
  PRIMARY KEY (log_id)
);

-- Membuat tabel 'buku'
CREATE TABLE buku (
  id_buku int(11) AUTO_INCREMENT,
  judul varchar(256),
  pengarang varchar(256),
  stok int(11),
  PRIMARY KEY (id_buku)
);

-- Membuat tabel 'anggota'
CREATE TABLE anggota (
  id_anggota int(11) AUTO_INCREMENT,
  nama varchar(128),
  tgl_lahir date,
  alamat varchar(256),
  email varchar(64),
  no_hp varchar(20),
  PRIMARY KEY (id_anggota)
);

-- Membuat tabel 'peminjaman'
CREATE TABLE peminjaman (
  id_peminjaman int(11) AUTO_INCREMENT,
  id_anggota int(11),
  id_buku int(11),
  tgl_pinjam date,
  tgl_jatuh_tempo date,
  tgl_kembali date,
  keterangan varchar(256),
  PRIMARY KEY (id_peminjaman),
  FOREIGN KEY (id_anggota) REFERENCES anggota(id_anggota),
  FOREIGN KEY (id_buku) REFERENCES buku(id_buku)
);


-- Study case nomor 1 
-- Memasukkan data ke tabel 'buku' (minimal 5 row) dengan judul buku dalam bahasa Indonesia
INSERT INTO buku (judul, pengarang, stok)
VALUES
  ('Pulang', 'Tere Liye', 10),
  ('Laskar Pelangi', 'Andrea Hirata', 5),
  ('Negeri 5 Menara', 'Ahmad Fuadi', 8),
  ('Ayat-Ayat Cinta', 'Habiburrahman El Shirazy', 3),
  ('Dilan: Dia Adalah Dilanku Tahun 1990', 'Pidi Baiq', 12);

-- Memasukkan data ke tabel 'anggota' (minimal 2 row) dengan nama, alamat, dan email acak
INSERT INTO anggota (nama, tgl_lahir, alamat, email, no_hp)
VALUES
  ('Mira Putri', '1990-01-15', 'Jl. Merdeka No. 10', 'mira.putri@example.com', '1234567890'),
  ('Adi Prabowo', '1985-05-20', 'Jl. Sukabumi No. 15', 'adi.prabowo@example.com', '9876543210');
 
INSERT INTO peminjaman (id_anggota, id_buku, tgl_pinjam, tgl_jatuh_tempo, tgl_kembali, keterangan)
VALUES
  (1, 1, '2023-01-10', '2023-01-20', '2023-01-15', 'Peminjaman pertama'),
  (1, 2, '2023-02-05', '2023-02-15', '2023-02-10', 'Peminjaman kedua'),
  (1, 3, '2023-03-20', '2023-03-30', '2023-03-25', 'Peminjaman ketiga'),
  (2, 1, '2023-04-15', '2023-04-25', '2023-04-20', 'Peminjaman keempat'),
  (2, 4, '2023-05-01', '2023-05-11', '2023-05-06', 'Peminjaman kelima'),
  (2, 5, '2023-06-10', '2023-06-20', '2023-06-15', 'Peminjaman keenam'),
  (1, 3, '2023-07-03', '2023-07-13', '2023-07-08', 'Peminjaman ketujuh'),
  (2, 2, '2023-08-15', '2023-08-25', '2023-08-20', 'Peminjaman kedelapan'),
  (1, 4, '2023-09-02', '2023-09-12', '2023-09-07', 'Peminjaman kesembilan'),
  (2, 3, '2023-10-10', '2023-10-20', '2023-10-15', 'Peminjaman kesepuluh');
 
 
--  Study case nomor 2 
 DELIMITER //

CREATE PROCEDURE tambah_peminjaman(
  IN in_id_anggota INT,
  IN in_id_buku INT,
  IN in_tgl_pinjam DATE,
  IN in_lama_peminjaman INT,
  IN in_keterangan VARCHAR(256)
)
BEGIN
  DECLARE stok_buku INT;
  DECLARE tgl_jatuh_tempo DATE;
  
  -- Mengambil stok buku
  SELECT stok INTO stok_buku
  FROM buku
  WHERE id_buku = in_id_buku;
  
  -- Mengecek apakah stok buku cukup
  IF stok_buku >= 1 THEN
    -- Menghitung tgl_jatuh_tempo dengan rumus 'tgl_pinjam + lama_peminjaman'
    SET tgl_jatuh_tempo = DATE_ADD(in_tgl_pinjam, INTERVAL in_lama_peminjaman DAY);
    
    -- Menambahkan data peminjaman
    INSERT INTO peminjaman (id_anggota, id_buku, tgl_pinjam, tgl_jatuh_tempo, tgl_kembali, keterangan)
    VALUES (in_id_anggota, in_id_buku, in_tgl_pinjam, tgl_jatuh_tempo, NULL, in_keterangan);
    
    -- Mengurangi stok buku
    UPDATE buku
    SET stok = stok - 1
    WHERE id_buku = in_id_buku;
  ELSE
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Stok buku yang diminta tidak ada.';
  END IF;
  
END //

DELIMITER ;


-- Study case nomor 3
DELIMITER //

CREATE PROCEDURE daftar_peminjaman_anggota(IN in_id_anggota INT)
BEGIN
  SELECT p.id_peminjaman, p.id_buku, b.judul AS judul_buku, p.tgl_pinjam, p.tgl_jatuh_tempo, p.tgl_kembali
  FROM peminjaman p
  INNER JOIN buku b ON p.id_buku = b.id_buku
  WHERE p.id_anggota = in_id_anggota;
END //

DELIMITER ;

-- Cara panggil 
CALL daftar_peminjaman_anggota(1);

-- Study case nomor 4 
CREATE VIEW pivot_view AS
SELECT 
  A.id_anggota,
  A.nama AS 'Nama Anggota',
  COUNT(DISTINCT P.id_peminjaman) AS 'Jumlah Peminjaman',
  SUM(CASE WHEN P.tgl_kembali IS NULL THEN 1 ELSE 0 END) AS 'Buku Masih Dipinjam',
  SUM(CASE WHEN P.tgl_kembali IS NOT NULL THEN 1 ELSE 0 END) AS 'Buku Sudah Dikembalikan'
FROM anggota A
LEFT JOIN peminjaman P ON A.id_anggota = P.id_anggota
GROUP BY A.id_anggota, A.nama;

-- Study case nomor 5
DELIMITER //

CREATE TRIGGER peminjaman_trigger
AFTER INSERT ON peminjaman
FOR EACH ROW
BEGIN
  -- Mengurangkan stok buku ketika ada peminjaman
  UPDATE buku
  SET stok = stok - 1
  WHERE id_buku = NEW.id_buku;
END;

CREATE TRIGGER pengembalian_trigger
AFTER UPDATE ON peminjaman
FOR EACH ROW
BEGIN
  -- Menambahkan stok buku ketika ada pengembalian
  IF NEW.tgl_kembali IS NOT NULL AND OLD.tgl_kembali IS NULL THEN
    UPDATE buku
    SET stok = stok + 1
    WHERE id_buku = NEW.id_buku;
  END IF;
END;

DELIMITER ;

-- Study case nomor 6 
DELIMITER //

CREATE TRIGGER log_buku_trigger
AFTER UPDATE ON buku
FOR EACH ROW
BEGIN
  DECLARE perubahan INT;
  DECLARE keterangan VARCHAR(512);
  
  -- Menghitung selisih perubahan stok
  SET perubahan = NEW.stok - OLD.stok;
  
  -- Menentukan keterangan berdasarkan perubahan stok
  IF perubahan > 0 THEN
    SET keterangan = 'Penambahan Stok';
  ELSE
    SET keterangan = 'Pengurangan Stok';
  END IF;

  -- Memasukkan data ke tabel log_buku
  INSERT INTO log_buku (id_buku, tgl_log, perubahan_stok, keterangan)
  VALUES (NEW.id_buku, NOW(), perubahan, keterangan);
END;

DELIMITER ;

