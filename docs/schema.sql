CREATE TABLE organism (
  organism_id INT AUTO_INCREMENT PRIMARY KEY,
  scientific_name VARCHAR(255) NOT NULL,
  common_name VARCHAR(255),
  taxonomy_id INT,
  lineage TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sample (
  sample_id INT AUTO_INCREMENT PRIMARY KEY,
  organism_id INT NOT NULL,
  sample_code VARCHAR(64) NOT NULL UNIQUE,
  collection_date DATE,
  location VARCHAR(255),
  tissue VARCHAR(255),
  notes TEXT,
  CONSTRAINT fk_sample_organism
    FOREIGN KEY (organism_id) REFERENCES organism(organism_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sequencing_run (
  run_id INT AUTO_INCREMENT PRIMARY KEY,
  sample_id INT NOT NULL,
  platform VARCHAR(128) NOT NULL,
  instrument VARCHAR(128),
  library_prep VARCHAR(255),
  run_date DATE,
  read_type ENUM('single', 'paired'),
  notes TEXT,
  CONSTRAINT fk_run_sample
    FOREIGN KEY (sample_id) REFERENCES sample(sample_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `sequence` (
  sequence_id INT AUTO_INCREMENT PRIMARY KEY,
  sample_id INT NOT NULL,
  run_id INT,
  format ENUM('FASTA', 'GENBANK') NOT NULL,
  description TEXT,
  length INT NOT NULL,
  gc_percent DECIMAL(5, 2),
  checksum VARCHAR(64),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sequence_sample
    FOREIGN KEY (sample_id) REFERENCES sample(sample_id),
  CONSTRAINT fk_sequence_run
    FOREIGN KEY (run_id) REFERENCES sequencing_run(run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE readset (
  readset_id INT AUTO_INCREMENT PRIMARY KEY,
  run_id INT NOT NULL,
  format ENUM('FASTQ') NOT NULL,
  read_count BIGINT,
  read_length INT,
  paired BOOLEAN,
  description TEXT,
  CONSTRAINT fk_readset_run
    FOREIGN KEY (run_id) REFERENCES sequencing_run(run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE file_asset (
  file_id INT AUTO_INCREMENT PRIMARY KEY,
  run_id INT,
  sequence_id INT,
  readset_id INT,
  file_type ENUM('raw', 'trimmed', 'assembly', 'annotation') NOT NULL,
  format ENUM('FASTA', 'FASTQ', 'GENBANK') NOT NULL,
  uri VARCHAR(2048) NOT NULL,
  size_bytes BIGINT,
  checksum VARCHAR(64),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_file_run
    FOREIGN KEY (run_id) REFERENCES sequencing_run(run_id),
  CONSTRAINT fk_file_sequence
    FOREIGN KEY (sequence_id) REFERENCES `sequence`(sequence_id),
  CONSTRAINT fk_file_readset
    FOREIGN KEY (readset_id) REFERENCES readset(readset_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sequence_quality (
  sequence_id INT PRIMARY KEY,
  avg_phred DECIMAL(5, 2),
  q30_percent DECIMAL(5, 2),
  n_percent DECIMAL(5, 2),
  CONSTRAINT fk_seq_quality
    FOREIGN KEY (sequence_id) REFERENCES `sequence`(sequence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE run_quality (
  run_id INT PRIMARY KEY,
  avg_phred DECIMAL(5, 2),
  q30_percent DECIMAL(5, 2),
  dup_percent DECIMAL(5, 2),
  adapter_percent DECIMAL(5, 2),
  CONSTRAINT fk_run_quality
    FOREIGN KEY (run_id) REFERENCES sequencing_run(run_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE annotation (
  annotation_id INT AUTO_INCREMENT PRIMARY KEY,
  sequence_id INT NOT NULL,
  source VARCHAR(255),
  feature VARCHAR(128),
  start_pos INT,
  end_pos INT,
  strand ENUM('+', '-'),
  note TEXT,
  CONSTRAINT fk_annotation_sequence
    FOREIGN KEY (sequence_id) REFERENCES `sequence`(sequence_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_sample_organism ON sample(organism_id);
CREATE INDEX idx_run_sample ON sequencing_run(sample_id);
CREATE INDEX idx_sequence_sample ON `sequence`(sample_id);
CREATE INDEX idx_sequence_run ON `sequence`(run_id);
CREATE INDEX idx_annotation_sequence ON annotation(sequence_id);
CREATE INDEX idx_file_asset_run ON file_asset(run_id);
CREATE INDEX idx_file_asset_sequence ON file_asset(sequence_id);
CREATE INDEX idx_file_asset_readset ON file_asset(readset_id);
CREATE INDEX idx_organism_taxonomy ON organism(taxonomy_id);
