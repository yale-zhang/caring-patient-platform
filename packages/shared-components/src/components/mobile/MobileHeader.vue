<template>
  <header class="caring-mobile-header">
    <button
      v-if="showBack"
      class="caring-mobile-header__back"
      type="button"
      aria-label="Go back"
      @click="$emit('back')"
    >
      <span aria-hidden="true">&lsaquo;</span>
    </button>
    <h1 class="caring-mobile-header__title">{{ title }}</h1>
    <div class="caring-mobile-header__actions">
      <slot name="right" />
    </div>
  </header>
</template>

<script>
export default {
  name: 'MobileHeader',
  props: {
    title: {
      type: String,
      default: ''
    },
    showBack: {
      type: Boolean,
      default: true
    }
  }
}
</script>

<style scoped>
.caring-mobile-header {
  align-items: center;
  background: #fff;
  box-sizing: border-box;
  display: flex;
  height: 48px;
  justify-content: space-between;
  padding: 0 16px;
  position: relative;
}

.caring-mobile-header__back {
  background: transparent;
  border: 0;
  color: inherit;
  cursor: pointer;
  font-size: 28px;
  line-height: 1;
  padding: 0 8px 4px 0;
}

.caring-mobile-header__title {
  flex: 1;
  font-size: 16px;
  font-weight: 500;
  margin: 0;
  overflow: hidden;
  text-align: center;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.caring-mobile-header__actions {
  align-items: center;
  display: flex;
  justify-content: flex-end;
  min-width: 24px;
}
</style>
