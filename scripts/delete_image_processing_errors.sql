DELETE FROM network_1.sample_photo
WHERE expedition_id = 3123
  AND data->>'imageProcessingErrors' IS NOT NULL;
