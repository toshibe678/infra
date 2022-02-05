function handler(event) {
  var request = event.request;
  var uri = request.uri;
  var newuri = uri;
  var response = {};
  var params = '';

  // remove path name index.html
  if (uri.includes('index.html')) {
    newuri = uri.replace('index.html', '');

    response = {
      statusCode: 302,
      statusDescription: 'Found',
      headers: { "location": { "value": newuri } }
    }

    return response;
  }
  // remove Trailing Slash
  else if(request.uri !== '/' && uri.endsWith('/')) {
    if(('querystring' in request) && (request.querystring.length > 0)) {
      params = '?'+request.querystring;
    }

    response = {
      statusCode: 302,
      statusDescription: 'Found',
      headers: { "location": { "value": request.uri.slice(0, -1) + params } }
    };

    return response;
  }
  // Check whether the URI is missing a file name.
  else if (uri.endsWith('/')) {
    request.uri += 'index.html';
  }
  // Check whether the URI is missing a file extension.
  else if (!uri.includes('.')) {
    request.uri += '/index.html';
  }

  return request;
}
