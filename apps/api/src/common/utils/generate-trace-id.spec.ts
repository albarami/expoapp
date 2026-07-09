import { generateTraceId } from './generate-trace-id';

describe('generateTraceId', () => {
  it('returns a non-empty uuid-like string', () => {
    const id = generateTraceId();
    expect(id).toEqual(expect.any(String));
    expect(id.length).toBeGreaterThan(10);
    expect(generateTraceId()).not.toBe(id);
  });
});
