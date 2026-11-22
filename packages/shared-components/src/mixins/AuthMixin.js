import { getUser, hasPermission, hasRole, isLoggedIn, logout } from '../utils/auth'

export default {
  computed: {
    currentUser() {
      return getUser()
    },
    isLoggedIn() {
      return isLoggedIn()
    }
  },
  methods: {
    hasPermission,
    hasRole,
    logout
  }
}
