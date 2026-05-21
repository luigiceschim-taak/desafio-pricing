export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
export type MakeEmpty<T extends { [key: string]: unknown }, K extends keyof T> = { [_ in K]?: never };
export type Incremental<T> = T | { [P in keyof T]?: P extends ' $fragmentName' | '__typename' ? T[P] : never };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: { input: string; output: string; }
  String: { input: string; output: string; }
  Boolean: { input: boolean; output: boolean; }
  Int: { input: number; output: number; }
  Float: { input: number; output: number; }
  Base64: { input: string; output: string; }
  Currency: { input: number | string; output: number; }
  Date: { input: string; output: string; }
  DateTime: { input: string; output: string; }
  Double: { input: number | string; output: number; }
  Email: { input: string; output: string; }
  EncryptedString: { input: string; output: string; }
  /** Can be set to an ID or a Reference to the result of another mutation operation. */
  IdOrRef: { input: string; output: string; }
  Latitude: { input: number | string; output: number; }
  /** A 64-bit signed integer */
  Long: { input: number; output: number; }
  LongTextArea: { input: string; output: string; }
  Longitude: { input: number | string; output: number; }
  MultiPicklist: { input: string; output: string; }
  Percent: { input: number | string; output: number; }
  PhoneNumber: { input: string; output: string; }
  Picklist: { input: string; output: string; }
  RichTextArea: { input: string; output: string; }
  TextArea: { input: string; output: string; }
  Time: { input: string; output: string; }
  Url: { input: string; output: string; }
};

export enum DataType {
  Address = 'ADDRESS',
  Anytype = 'ANYTYPE',
  Base64 = 'BASE64',
  Boolean = 'BOOLEAN',
  Combobox = 'COMBOBOX',
  Complexvalue = 'COMPLEXVALUE',
  Currency = 'CURRENCY',
  Date = 'DATE',
  Datetime = 'DATETIME',
  Double = 'DOUBLE',
  Email = 'EMAIL',
  Encryptedstring = 'ENCRYPTEDSTRING',
  Int = 'INT',
  Json = 'JSON',
  Junctionidlist = 'JUNCTIONIDLIST',
  Location = 'LOCATION',
  Long = 'LONG',
  Multipicklist = 'MULTIPICKLIST',
  Percent = 'PERCENT',
  Phone = 'PHONE',
  Picklist = 'PICKLIST',
  Reference = 'REFERENCE',
  String = 'STRING',
  Textarea = 'TEXTAREA',
  Time = 'TIME',
  Url = 'URL'
}

export enum FieldExtraTypeInfo {
  ExternalLookup = 'EXTERNAL_LOOKUP',
  ImageUrl = 'IMAGE_URL',
  IndirectLookup = 'INDIRECT_LOOKUP',
  Personname = 'PERSONNAME',
  Plaintextarea = 'PLAINTEXTAREA',
  Richtextarea = 'RICHTEXTAREA',
  SwitchablePersonname = 'SWITCHABLE_PERSONNAME'
}

export enum LayoutComponentType {
  Canvas = 'CANVAS',
  CustomLink = 'CUSTOM_LINK',
  EmptySpace = 'EMPTY_SPACE',
  Field = 'FIELD',
  ReportChart = 'REPORT_CHART',
  VisualforcePage = 'VISUALFORCE_PAGE'
}

export enum LayoutMode {
  Create = 'CREATE',
  Edit = 'EDIT',
  View = 'VIEW'
}

export enum LayoutType {
  Compact = 'COMPACT',
  Full = 'FULL'
}

export enum ResultOrder {
  Asc = 'ASC',
  Desc = 'DESC'
}

export enum TabOrder {
  LeftRight = 'LEFT_RIGHT',
  TopDown = 'TOP_DOWN'
}

export enum UiBehavior {
  Edit = 'EDIT',
  Readonly = 'READONLY',
  Required = 'REQUIRED'
}

export type GetOrdersQueryVariables = Exact<{ [key: string]: never; }>;


export type GetOrdersQuery = { uiapi: { query: { Order?: { edges?: Array<{ node?: { Id: string, OrderNumber?: { value?: string | null } | null, Status?: { value?: string | null } | null, EffectiveDate?: { value?: string | null } | null, TotalAmount?: { value?: number | null } | null, Account?: { Name?: { value?: string | null } | null } | null, OrderItems?: { edges?: Array<{ node?: { Id: string, UnitPrice?: { value?: number | null } | null, Quantity?: { value?: number | null } | null, TotalPrice?: { value?: number | null } | null, FreightCost__c?: { value?: number | null } | null, MarginPercentage__c?: { value?: number | null } | null, TaxPercentage__c?: { value?: number | null } | null, ProductionCost__c?: { value?: number | null } | null, TotalSellingPrice__c?: { value?: number | null } | null, IdealPrice__c?: { value?: number | null } | null, Product2?: { Name?: { value?: string | null } | null, ProductCode?: { value?: string | null } | null } | null } | null } | null> | null } | null } | null } | null> | null } | null } } };
