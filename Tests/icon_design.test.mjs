import test from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';

test('icon uses flat industrial broadcast geometry', async () => {
  const source = await readFile(new URL('../Scripts/make_icon.swift', import.meta.url), 'utf8');
  assert.match(source, /tallyOrange/);
  assert.match(source, /prompterScreen/);
  assert.match(source, /script line/i);
  assert.doesNotMatch(source, /play triangle|film-strip|gradient|glow/i);
});
