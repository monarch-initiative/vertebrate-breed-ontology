from requests import Session, Response

from .schemas.responses import ApiResponse, Species, BreedResponse, TransboundaryNamesResponse

DEV_URL = "https://us-central1-fao-dadis-dev.cloudfunctions.net/api/v1/"
PROD_URL = "https://us-central1-dadis-ws.cloudfunctions.net/api/v1/"


class DadisClient:
    _session: Session
    base_url: str

    def __init__(self, *, api_key: str, prod: bool = True):
        if prod:
            self.base_url = PROD_URL
        else:
            self.base_url = DEV_URL
        self._session = Session()
        self._session.headers["Authorization"] = api_key

    def get(self, path, **kwargs) -> Response:
        return self._session.get(self.base_url + path, **kwargs)

    def get_all_species(self) -> ApiResponse[list[Species]]:
        resp = self.get("species")
        return ApiResponse[list[Species]](**resp.json())

    def get_species_by_id(self, species_id: int) -> ApiResponse[Species]:
        resp = self.get(f"species/{species_id}")
        return ApiResponse[Species](**resp.json())

    def get_all_breeds(self) -> BreedResponse:
        resp = self.get("breeds", params={"classification": "all"})
        return BreedResponse(**resp.json())

    def get_all_local_breeds(self) -> BreedResponse:
        resp = self.get("breeds", params={"classification": "local"})
        return BreedResponse(**resp.json())

    def get_all_transboundary_breeds(self) -> BreedResponse:
        resp = self.get("breeds", params={"classification": "transboundary"})
        return BreedResponse(**resp.json())

    def get_all_transboundary_names(self) -> TransboundaryNamesResponse:
        resp = self.get("transboundary")
        return TransboundaryNamesResponse(**resp.json())
