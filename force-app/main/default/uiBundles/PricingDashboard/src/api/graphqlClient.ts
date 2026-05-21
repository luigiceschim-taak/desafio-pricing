/**
 * Thin GraphQL client: createDataSDK + data.graphql with centralized error handling.
 * Use with gql-tagged queries and generated operation types for type-safe calls.
 */
import { createDataSDK, type GraphQLRequest } from '@salesforce/sdk-data';

export async function executeGraphQL<TData, TVariables = Record<string, unknown>>(
  query: string,
  variables?: TVariables
): Promise<TData> {
  const sdk = await createDataSDK();

  const request: GraphQLRequest<TVariables> = { query, ...(variables ? { variables } : {}) };
  const response = await sdk.graphql?.<TData, TVariables>(request);

  if (!response) {
    throw new Error('GraphQL response is undefined');
  }

  if (response.errors?.length) {
    const msg = response.errors.map(e => e.message).join('; ');
    throw new Error(`GraphQL Error: ${msg}`);
  }

  return response.data;
}
