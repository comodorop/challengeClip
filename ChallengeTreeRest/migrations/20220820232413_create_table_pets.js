/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function (knex) {
    return knex.schema
        .createTable('pet', function (table) {
            table.string('uuid', 100).primary();
            table.string('name', 20);
            table.string('owner', 20);
            table.string('species', 20);
            table.specificType('sex', 'char(1)')
        })
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function (knex) {

};
