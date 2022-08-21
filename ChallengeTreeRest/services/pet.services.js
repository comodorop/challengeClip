const { connection } = require('../repository/connection/index')
const { v4 } = require('uuid');


async function save(body, nameTable){
    body.uuid =v4()
    let knex = await connection()
    return await knex(nameTable).insert(body).returning('uuid')
}

async function get(nameTable, name) {
    let knex = await connection()
    return await knex().select('*').from(nameTable).where({name: name})
}


module.exports= {
    save,
    get
}