from csv import DictReader
from datetime import datetime
from pprint import pprint

from flask.ext.script import Manager

from taarifa_api import add_document, delete_documents, get_schema
from actuality import app
from actuality.schemas import vehicle_facility, freight_movement_facility


manager = Manager(app)


def check(response, success=201, print_status=True):
    data, _, _, status = response
    if status == success:
        if print_status:
            print " Succeeded"
        return True

    print "Failed with status", status
    pprint(data)
    return False


@manager.option("resource", help="Resource to show the schema for")
def show_schema(resource):
    """Show the schema for a given resource."""
    pprint(get_schema(resource))


@manager.command
def list_routes():
    """List all routes defined for the application."""
    import urllib
    for rule in sorted(app.url_map.iter_rules(), key=lambda r: r.endpoint):
        methods = ','.join(rule.methods)
        print urllib.unquote("{:40s} {:40s} {}".format(rule.endpoint, methods,
                                                       rule))


@manager.command
def create_facilities():
    """Create facilities for vehicles and freight movements."""
    check(add_document('facilities', vehicle_facility))
    check(add_document('facilities', freight_movement_facility))


@manager.command
def delete_vehicles():
    """Delete all vehicles."""
    check(delete_documents('vehicles'), 200)


@manager.command
def delete_movements():
    """Delete all movements."""
    check(delete_documents('movements'), 200)


@manager.command
def delete_facilities():
    """Delete all facilities."""
    check(delete_documents('facilities'), 200)


@manager.command
def ensure_indexes():
    """Make sure all important database indexes are created."""
    print "Ensuring resources:location 2dsphere index is created ..."
    app.data.driver.db['resources'].ensure_index([('location', '2dsphere')])
    print "Done!"

if __name__ == "__main__":
    manager.run()
