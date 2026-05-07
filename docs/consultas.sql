SELECT s.sequence_id, o.scientific_name, s.length, q.avg_phred, q.q30_percent
FROM sequence s
JOIN sample sm ON sm.sample_id = s.sample_id
JOIN organism o ON o.organism_id = sm.organism_id
JOIN sequence_quality q ON q.sequence_id = s.sequence_id
WHERE q.avg_phred >= 30 AND q.q30_percent >= 90
ORDER BY q.avg_phred DESC;

SELECT r.run_id, sm.sample_code, rq.avg_phred, rq.q30_percent, rq.adapter_percent
FROM sequencing_run r
JOIN sample sm ON sm.sample_id = r.sample_id
JOIN run_quality rq ON rq.run_id = r.run_id
WHERE rq.q30_percent < 80 OR rq.adapter_percent > 5
ORDER BY rq.q30_percent ASC;

SELECT s.sequence_id, s.format, s.length, s.gc_percent
FROM sequence s
JOIN sample sm ON sm.sample_id = s.sample_id
JOIN organism o ON o.organism_id = sm.organism_id
WHERE o.taxonomy_id = 9606
ORDER BY s.length DESC;

SELECT rs.readset_id, rs.read_count, rs.read_length, f.uri
FROM readset rs
JOIN sequencing_run r ON r.run_id = rs.run_id
JOIN file_asset f ON f.readset_id = rs.readset_id
WHERE r.sample_id = 1 AND f.format = 'FASTQ';

SELECT s.sequence_id, a.feature, a.start_pos, a.end_pos, a.note
FROM sequence s
JOIN annotation a ON a.sequence_id = s.sequence_id
WHERE s.format = 'GENBANK' AND a.feature ILIKE 'gene' AND a.note ILIKE '%cox1%';

SELECT s.sequence_id, s.length, q.avg_phred, q.q30_percent
FROM sequence s
JOIN sequence_quality q ON q.sequence_id = s.sequence_id
WHERE s.length >= 10000 AND s.gc_percent BETWEEN 45 AND 55
ORDER BY s.length DESC;
