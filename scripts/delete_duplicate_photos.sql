-- Prune script for expedition_id = 3123
DELETE FROM network_1.sample_photo
WHERE expedition_id = 3123
  AND (data->>'filename', data->>'urn:materialSampleID') IN (
    SELECT data->>'filename' AS filename,
           data->>'urn:materialSampleID' AS materialSampleID
    FROM network_1.sample_photo
    WHERE expedition_id = 3123
      AND data->>'filename' IS NOT NULL
    GROUP BY data->>'filename', data->>'urn:materialSampleID'
    HAVING COUNT(*) > 1
  )
  AND id NOT IN (
    SELECT MIN(id) AS id
    FROM network_1.sample_photo
    WHERE expedition_id = 3123
      AND (data->>'filename', data->>'urn:materialSampleID') IN (
        SELECT data->>'filename' AS filename,
               data->>'urn:materialSampleID' AS materialSampleID
        FROM network_1.sample_photo
        WHERE expedition_id = 3123
          AND data->>'filename' IS NOT NULL
        GROUP BY data->>'filename', data->>'urn:materialSampleID'
        HAVING COUNT(*) > 1
      )
    GROUP BY data->>'filename', data->>'urn:materialSampleID'
  );

