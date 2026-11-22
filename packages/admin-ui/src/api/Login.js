import axiosApi from './AxiosApi.js'
import { Base64 } from 'js-base64'

const encodeCredential = value => {
  const encoded = Base64.encode(`caring_${value || ''}`)
  return Base64.encode(`A${encoded}B`)
}

const apiList = {
  captcha: '/oauth/anno/captcha',
  login: '/oauth/anno/token',
  router: '/oauth/menu/router',
  resource: '/oauth/resource/visible'
}

export default {
  getCaptcha (randomId) {
    return axiosApi({
      method: 'GET',
      url: apiList.captcha + `?key=${randomId}`,
      responseType: 'arraybuffer',
      meta: {
        "X-isToken": false
      }
    })
  },
  login (data) {
    const requestData = data.grantType === 'refresh_token'
      ? data
      : {
          ...data,
          account: encodeCredential(data.account),
          password: encodeCredential(data.password)
        }

    return axiosApi({
      method: 'POST',
      url: apiList.login,
      data: requestData
    })
  },
  getRouter (data) {
    return axiosApi({
      method: 'GET',
      url: apiList.router,
      data: data || {}
    })
  },
  getResource (data) {
    return axiosApi({
      method: 'GET',
      url: apiList.resource,
      data: data || {}
    })
  }
}
