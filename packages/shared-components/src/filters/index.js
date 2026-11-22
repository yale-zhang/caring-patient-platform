import { formatDate, formatPhone } from '../utils/format'

export function dateFilter(value, format) {
  return formatDate(value, format)
}

export function phoneFilter(value) {
  return formatPhone(value)
}
