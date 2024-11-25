import process from 'node:process';
import { copy } from './actions/copy.js';
import { query } from './actions/query.js';
const args = JSON.parse(process.argv[2] ?? '{}');
const { method, parameters } = args;
if (method === 'query') {
    query(parameters[0]);
}
if (method === 'copy') {
    copy(parameters[0]);
}
//# sourceMappingURL=main.js.map