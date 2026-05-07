# Sistema de Gestion de Datos Genomicos

## Objetivo
Disenar un sistema para almacenar y consultar datos de secuenciacion en formatos FASTA, GenBank y FASTQ, con enfasis en trazabilidad, calidad y metadatos biologicos.

## Alcance
- Gestion de metadatos de organismo, muestra, corrida y secuencia.
- Almacenamiento de archivos crudos y derivados mediante referencias (URI).
- Calidad agregada por secuencia y por corrida.
- Anotaciones basicas para secuencias GenBank.
- Consultas tipicas para calidad, longitud, organismo y archivos.

## Modelo de datos (resumen)
Entidades principales:
- Organism: taxonomia y nombre cientifico.
- Sample: metadatos biologicos y de colecta.
- SequencingRun: plataforma, fecha y tipo de lectura.
- Sequence: secuencias ensambladas o anotadas (FASTA, GenBank).
- Readset: conjunto de lecturas FASTQ por corrida.
- FileAsset: ubicacion y checksum de archivos.
- SequenceQuality y RunQuality: metrica de calidad.
- Annotation: features y posiciones en la secuencia.

Relaciones clave:
- Un organism tiene muchas muestras.
- Una muestra genera corridas y secuencias.
- Una corrida tiene readsets y archivos.
- Una secuencia tiene anotaciones y calidad.

## Manejo de formatos
- FASTA y GenBank: se registra la secuencia, longitud, GC y anotaciones; el archivo se guarda como FileAsset.
- FASTQ: se guarda el archivo en FileAsset y la calidad agregada en RunQuality; las lecturas individuales no se almacenan en la base.

## Esquema relacional
Se propone PostgreSQL por soporte a integridad referencial e indices. El esquema se detalla en docs/schema.sql y el diagrama ER en docs/diagrama-er.mmd.

## Consultas propuestas
Ejemplos en docs/consultas.sql:
- Secuencias con alta calidad (avg phred y q30).
- Corridas con baja calidad o alto porcentaje de adaptadores.
- Secuencias de un organismo por taxonomia.
- Archivos FASTQ por muestra y corrida.
- Secuencias GenBank con anotaciones de un gen.

## Indices y rendimiento
- Indices por claves foraneas y taxonomy_id.
- Campos de calidad y longitud se consultan con filtros y ordenamientos.
- Archivos pesados se mantienen fuera de la base; solo metadatos en FileAsset.

## Seguridad y trazabilidad
- Control de acceso por roles (lectura, curacion, admin).
- Campos de checksum para detectar corrupcion.
- Fechas de carga para auditoria.

## Alternativa NoSQL (opcional)
Un modelo documental puede agrupar organism -> samples -> runs -> files.
Ejemplo:
```json
{
  "organism": { "taxonomy_id": 9606, "scientific_name": "Homo sapiens" },
  "samples": [
    {
      "sample_code": "S-1023",
      "runs": [
        {
          "platform": "Illumina",
          "readsets": [
            { "format": "FASTQ", "read_count": 12000000, "files": [ "s3://..." ] }
          ],
          "quality": { "avg_phred": 34.1, "q30_percent": 92.4 }
        }
      ]
    }
  ]
}
```

## Prototipo
El prototipo muestra un dashboard con filtros, metricas y tabla de secuencias, mas un panel de detalle de la secuencia seleccionada. Ver prototype/index.html.

## Entregables
- Diagrama ER: docs/diagrama-er.mmd
- Esquema SQL: docs/schema.sql
- Consultas: docs/consultas.sql
- Prototipo: prototype/index.html y prototype/styles.css
- Documento: docs/documento.md
