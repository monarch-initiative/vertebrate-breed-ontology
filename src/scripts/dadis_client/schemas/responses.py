from typing import Generic, Optional, TypeVar
from pydantic import BaseModel, validator


Data = TypeVar("Data")


class ApiResponse(BaseModel, Generic[Data]):
    status: int
    message: str
    response: Data


class Species(BaseModel):
    id: int
    name: dict[str, str]


class Breed(BaseModel):
    id: str
    name: str
    iso3: str
    speciesId: int
    transboundaryId: str | None
    # updatedAt uses empty str for null values
    updatedAt: int | None

    @validator("updatedAt", pre=True)
    def empty_updated(cls, v):
        if isinstance(v, str):
            return None
        return v


class TransboundaryName(BaseModel):
    id: Optional[str] = None
    speciesId: int
    name: str


BreedResponse = ApiResponse[list[Breed]]

TransboundaryNamesResponse = ApiResponse[list[TransboundaryName]]