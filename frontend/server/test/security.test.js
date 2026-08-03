const test = require('node:test');
const assert = require('node:assert/strict');
const { isStrongPassword, hasRequiredRole } = require('../security');

test('rejects weak passwords', () => {
  assert.equal(isStrongPassword('password123'), false);
  assert.equal(isStrongPassword('Password123'), false);
  assert.equal(isStrongPassword('Password123!'), true);
});

test('validates role access', () => {
  assert.equal(hasRequiredRole({ role: 'admin' }, ['admin']), true);
  assert.equal(hasRequiredRole({ role: 'lector' }, ['admin']), false);
});
