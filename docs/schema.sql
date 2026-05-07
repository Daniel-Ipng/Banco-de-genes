CREATE TABLE organism (
  organism_id SERIAL PRIMARY KEY,
  scientific_name TEXT NOT NULL,
  common_name TEXT,
  taxonomy_id INT,
  lineage TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE sample (
  sample_id SERIAL PRIMARY KEY,
  organism_id INT NOT NULL REFERENCES organism(organism_id),
  sample_code TEXT NOT NULL UNIQUE,
  collection_date DATE,
  location TEXT,
  tissue TEXT,
  notes TEXT
);

CREATE TABLE sequencing_run (
  run_id SERIAL PRIMARY KEY,
  sample_id INT NOT NULL REFERENCES sample(sample_id),
  platform TEXT NOT NULL,
  instrument TEXT,
  library_prep TEXT,
  run_date DATE,
  read_type TEXT CHECK (read_type IN ('single', 'paired')),
  notes TEXT
);

CREATE TABLE sequence (
  sequence_id SERIAL PRIMARY KEY,
  sample_id INT NOT NULL REFERENCES sample(sample_id),
  run_id INT REFERENCES sequencing_run(run_id),
  format TEXT NOT NULL CHECK (format IN ('FASTA', 'GENBANK')),
  description TEXT,
  length INT NOT NULL,
  gc_percent NUMERIC(5, 2),
  checksum TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE readset (
  readset_id SERIAL PRIMARY KEY,
  run_id INT NOT NULL REFERENCES sequencing_run(run_id),
  format TEXT NOT NULL CHECK (format IN ('FASTQ')),
  read_count BIGINT,
  read_length INT,
  paired BOOLEAN,
  description TEXT
);

CREATE TABLE file_asset (
  file_id SERIAL PRIMARY KEY,
  run_id INT REFERENCES sequencing_run(run_id),
  sequence_id INT REFERENCES sequence(sequence_id),
  readset_id INT REFERENCES readset(readset_id),
  file_type TEXT NOT NULL CHECK (file_type IN ('raw', 'trimmed', 'assembly', 'annotation')),
  format TEXT NOT NULL CHECK (format IN ('FASTA', 'FASTQ', 'GENBANK')),
  uri TEXT NOT NULL,
  size_bytes BIGINT,
  checksum TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE sequence_quality (
  sequence_id INT PRIMARY KEY REFERENCES sequence(sequence_id),
  avg_phred NUMERIC(5, 2),
  q30_percent NUMERIC(5, 2),
  n_percent NUMERIC(5, 2)
);

CREATE TABLE run_quality (
  run_id INT PRIMARY KEY REFERENCES sequencing_run(run_id),
  avg_phred NUMERIC(5, 2),
  q30_percent NUMERIC(5, 2),
  dup_percent NUMERIC(5, 2),
  adapter_percent NUMERIC(5, 2)
);

CREATE TABLE annotation (
  annotation_id SERIAL PRIMARY KEY,
  sequence_id INT NOT NULL REFERENCES sequence(sequence_id),
  source TEXT,
  feature TEXT,
  start_pos INT,
  end_pos INT,
  strand CHAR(1) CHECK (strand IN ('+', '-')),
  note TEXT
);

CREATE INDEX idx_sample_organism ON sample(organism_id);
CREATE INDEX idx_run_sample ON sequencing_run(sample_id);
CREATE INDEX idx_sequence_sample ON sequence(sample_id);
CREATE INDEX idx_sequence_run ON sequence(run_id);
CREATE INDEX idx_annotation_sequence ON annotation(sequence_id);
CREATE INDEX idx_file_asset_run ON file_asset(run_id);
CREATE INDEX idx_file_asset_sequence ON file_asset(sequence_id);
CREATE INDEX idx_file_asset_readset ON file_asset(readset_id);
CREATE INDEX idx_organism_taxonomy ON organism(taxonomy_id);
