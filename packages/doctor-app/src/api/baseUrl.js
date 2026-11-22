const apiUrl = process.env.NODE_ENV === 'development' 
  ? 'https://dev-api.example.com/api' 
  : '/api'

export default apiUrl
