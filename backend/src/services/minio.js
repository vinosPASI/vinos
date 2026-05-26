const Minio = require('minio');

class MinioService {
  constructor(endpoint, accessKey, secretKey, useSSL = false) {
    this.endpoint = endpoint;
    this.useSSL = useSSL;
    this.client = new Minio.Client({
      endPoint: endpoint.split(':')[0],
      port: parseInt(endpoint.split(':')[1] || '9000', 10),
      accessKey,
      secretKey,
      useSSL,
    });
  }

  async ensureBucket(bucket) {
    const exists = await this.client.bucketExists(bucket);
    if (!exists) {
      await this.client.makeBucket(bucket);
    }
  }

  async uploadFile(bucket, objectName, stream, size, contentType) {
    await this.client.putObject(bucket, objectName, stream, size, {
      'Content-Type': contentType,
    });

    const protocol = this.useSSL ? 'https' : 'http';
    const url = `${protocol}://${this.endpoint}/${bucket}/${objectName}`;
    return url;
  }

  async downloadFile(bucket, objectName) {
    const stream = await this.client.getObject(bucket, objectName);
    const chunks = [];
    for await (const chunk of stream) {
      chunks.push(chunk);
    }
    return Buffer.concat(chunks);
  }
}

module.exports = MinioService;
