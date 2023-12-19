import { PostgresSQL } from '../../../filters';
import { readSQL } from '../../../helper';

const parser = new PostgresSQL();

const features = {
    selects: readSQL(__dirname, 'select.sql'),
};

describe('PgSQL Select Syntax Tests', () => {
    features.selects.forEach((select) => {
        it(select, () => {
            expect(parser.validate(select).length).toBe(0);
        });
    });
});
