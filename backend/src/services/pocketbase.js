class PocketBaseClient {
  constructor(baseURL) {
    this.baseURL = baseURL;
    this.adminToken = null;
    this.httpClient = {
      timeout: 10000,
    };
  }

  async request(method, endpoint, body = null, headers = {}) {
    const url = new URL(endpoint, this.baseURL).toString();
    const opts = {
      method,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
      signal: AbortSignal.timeout(this.httpClient.timeout),
    };

    if (body) {
      opts.body = JSON.stringify(body);
    }

    const resp = await fetch(url, opts);
    return resp;
  }

  async authAdmin(email, password) {
    const resp = await this.request('POST', '/api/admins/auth-with-password', {
      identity: email,
      password,
    });

    if (!resp.ok) {
      throw new Error(`fallo la autenticación de admin, status: ${resp.status}`);
    }

    const result = await resp.json();
    this.adminToken = result.token;
  }

  async authUser(email, password) {
    const resp = await this.request('POST', '/api/collections/users/auth-with-password', {
      identity: email,
      password,
    });

    if (!resp.ok) {
      throw new Error(`credenciales inválidas, status: ${resp.status}`);
    }

    const result = await resp.json();
    return {
      token: result.token,
      record: {
        id: result.record.id,
        role: result.record.role,
      },
    };
  }

  async validateToken(token) {
    const resp = await this.request('POST', '/api/collections/users/auth-refresh', null, {
      Authorization: token,
    });

    if (!resp.ok) {
      throw new Error(`token inválido, PocketBase respondió status ${resp.status}`);
    }

    const result = await resp.json();
    return {
      id: result.record.id,
      role: result.record.role,
    };
  }

  async createUser(email, password, passwordConfirm, name, role) {
    const resp = await this.request('POST', '/api/collections/users/records', {
      email,
      password,
      passwordConfirm,
      name,
      role,
    });

    if (!resp.ok) {
      const body = await resp.text();
      throw new Error(`error creando usuario, status: ${resp.status}, response: ${body}`);
    }

    const record = await resp.json();
    return {
      id: record.id,
      role: record.role,
    };
  }

  async getRecord(collection, id) {
    const headers = {};
    if (this.adminToken) {
      headers.Authorization = this.adminToken;
    }

    const resp = await this.request('GET', `/api/collections/${collection}/records/${id}`, null, headers);

    if (!resp.ok) {
      throw new Error(`error obteniendo registro, status: ${resp.status}`);
    }

    return resp.json();
  }

  async listRecords(collection, page = 1, limit = 50, filter = '') {
    let url = `/api/collections/${collection}/records?page=${page}&perPage=${limit}`;
    if (filter) {
      url += `&filter=${encodeURIComponent(filter)}`;
    }

    const headers = {};
    if (this.adminToken) {
      headers.Authorization = this.adminToken;
    }

    const resp = await this.request('GET', url, null, headers);

    if (!resp.ok) {
      throw new Error(`error listando registros, status: ${resp.status}`);
    }

    return resp.json();
  }

  async createRecord(collection, data) {
    const headers = {};
    if (this.adminToken) {
      headers.Authorization = this.adminToken;
    }

    const resp = await this.request('POST', `/api/collections/${collection}/records`, data, headers);

    if (!resp.ok) {
      const body = await resp.text();
      throw new Error(`error creando registro, status: ${resp.status}, response: ${body}`);
    }

    return resp.json();
  }

  async updateRecord(collection, id, data) {
    const headers = {};
    if (this.adminToken) {
      headers.Authorization = this.adminToken;
    }

    const resp = await this.request('PATCH', `/api/collections/${collection}/records/${id}`, data, headers);

    if (!resp.ok) {
      const body = await resp.text();
      throw new Error(`error actualizando registro, status: ${resp.status}, response: ${body}`);
    }

    return resp.json();
  }

  async deleteRecord(collection, id) {
    const headers = {};
    if (this.adminToken) {
      headers.Authorization = this.adminToken;
    }

    const resp = await this.request('DELETE', `/api/collections/${collection}/records/${id}`, null, headers);

    if (!resp.ok) {
      throw new Error(`error eliminando registro, status: ${resp.status}`);
    }
  }
}

module.exports = PocketBaseClient;
