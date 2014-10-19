vehicle_schema = {
    'license_plate': {
        'type': 'string',
        'input': 'text',
        'label': 'License Plate',
        'unique': True,
    },
    'kind': {
        'type': 'string',
        'input': 'text',
        'label': 'Kind',
        'allowed': ['car',
                    'van',
                    'light truck',
                    'semitrailer truck',
                    'pick-up truck',
                    'dumper truck',
                    'tipper truck',
                    'flatbed truck',
                    'tank truck',
                    'refridgerated truck',
                    'garbage truck',
                    'lumber truck',
                    'military truck',
                    'tractor'],
    },
    'manufacturer': {
        'type': 'string',
        'input': 'text',
        'label': 'Manufacturer',
    },
    'model': {
        'type': 'string',
        'input': 'text',
        'label': 'Model',
    },
    'max_weight': {
        'type': 'number',
        'label': 'Maximum weight',
    },
    'axles': {
        'type': 'integer',
        'input': 'number',
        'label': 'Axles',
    },
    'owner': {
        'type': 'string',
        'input': 'text',
        'label': 'Owner',
    },
    'driver': {
        'type': 'string',
        'input': 'text',
        'label': 'Driver',
    },
    'organization': {
        'type': 'string',
        'input': 'text',
        'label': 'Organization',
    },
    'valid_from': {
        'type': 'datetime',
        'label': 'Valid from',
        'input': 'date',
        'nullable': True,
    },
    'valid_to': {
        'type': 'datetime',
        'label': 'Valid until',
        'input': 'date',
        'nullable': True,
    },
    'date_recorded': {
        'type': 'datetime',
        'label': 'Date recorded',
        'input': 'datetime-local',
    },
    'location': {
        'type': 'point',
        'label': 'Vehicle home base',
    },
    'recorded_by': {
        'type': 'string',
        'input': 'text',
        'label': 'Recorded by',
    },
    'photo_url': {
        'type': 'string',
        'input': 'text',
        'label': 'Photo URL',
    },
    'built': {
        'type': 'datetime',
        'label': 'Built',
        'input': 'date',
        'nullable': True,
    },
}

freight_movement_schema = {
    'status': {
        'type': 'string',
        'input': 'text',
        'label': 'Status',
        'allowed': ['legitimate', 'illegal', 'unknown']
    },
    'report_status': {
        'type': 'string',
        'input': 'text',
        'label': 'Report Status',
        'allowed': ['open', 'closed']
    },
    'license_plate': {
        'type': 'string',
        'input': 'text',
        'label': 'License Plate',
        #'data_relation': {'resource': 'vehicles', 'field': 'license_plate'},
    },
    'location': {
        'type': 'point',
        'label': 'Location of sighting',
    },
    'location_from': {
        'type': 'point',
        'label': 'Location the freight is coming from',
    },
    'location_to': {
        'type': 'point',
        'label': 'Location the freight is going to',
    },
    'date_recorded': {
        'type': 'datetime',
        'label': 'Date and time of the sighting',
        'input': 'datetime-local',
    },
    'description': {
        'type': 'string',
        'input': 'text',
        'label': 'Description of the freight',
    },
    'photo_url': {
        'type': 'string',
        'input': 'text',
        'label': 'Photo URL of the sighting',
    },
}

vehicle_facility = {'facility_code': "vhf001",
                    'facility_name': "Vehicle",
                    # this defines the schema of a resource within this facility
                    'fields': vehicle_schema,
                    'description': "Vehicle",
                    'keywords': ["mobile", "transport", "vehicle"],
                    'group': "transport",
                    'endpoint': "vehicles"}

freight_movement_facility = {'facility_code': "mvf001",
                             'facility_name': "FreightMovement",
                             # this defines the schema of a resource within this facility
                             'fields': freight_movement_schema,
                             'description': "Freight Movement",
                             'keywords': ["mobile", "transport", "vehicle"],
                             'group': "transport",
                             'endpoint': "movements"}
