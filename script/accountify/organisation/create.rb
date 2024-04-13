user = { id: 1 }
tenant = { id: 1 }

organisation = Accountify::Organisation.create(user: user, tenant: tenant, name: 'Big Bin Corp')
Accountify::Organisation.update(user: user, tenant: tenant, id: organisation[:id], name: 'Big Bin Corp updated')
Accountify::Organisation.delete(user: user, tenant: tenant, id: organisation[:id])
