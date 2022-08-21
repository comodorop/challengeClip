require('dotenv').config()
// const knex = require('knex')
const knexConfig = require('../../knexfile');
console.log(knexConfig[process.env.NODE_ENV])

const knex = require('knex')(knexConfig[process.env.NODE_ENV])
let cn;

async function connection() {
    return knex
}

async function getConnection() {
    return cn
}

module.exports = {
    connection,
    getConnection
}

