component {

  public any function init() {
    return this;
  }

  public any function parseXmlResponse( required string response, required string rootElement ) {
    var start = getTickCount();
    var result = [ ];
    var elementNodes = xmlSearch( xmlParse( response ), "//*[ local-name() = '#rootElement#' ]" );
    for ( var thisNode in elementNodes ) {
      result.append( parseXmlNode( thisNode ) );
    }
    return result.len() ? ( result.len() > 1 ? result : result[ 1 ] ) : '';
  }

  public any function parseXmlNode( required xml xmlNode ) {
    var result = { };

    for ( var key in structKeyArray( xmlNode.xmlAttributes ) ) {
      result[ key ] = xmlNode.xmlAttributes[ key ];
    }

    for ( var thisChild in xmlNode.xmlChildren ) {
      var thisValue = ( len( thisChild.XmlText ) || !thisChild.xmlChildren.len() ) ? thisChild.XmlText : parseXmlNode( thisChild );
      if ( !result.keyExists( thisChild.XmlName ) ) {
        result[ thisChild.XmlName ] = thisValue;
      } else {
        if ( !isArray( result[ thisChild.XmlName ] ) ) result[ thisChild.XmlName ] = [ result[ thisChild.XmlName ] ];
        result[ thisChild.XmlName ].append( thisValue );
      }
    }

    var resultKeys = result.keyArray();
    if ( resultKeys.len() == 1 && isArray( result[ resultKeys[ 1 ] ] ) ) return result[ resultKeys[ 1 ] ];
    return result;
  }

  public string function parseKey( required string paramKey ) {
    var key = [ ];
    for ( var character in paramKey.listToArray( '' ) ) {
      if ( arrayLen( key ) && asc( character ) != asc( lcase( character ) ) ) key.append( '-' );
      key.append( lcase( character ) );
    }
    return key.toList( '' );
  }

  public array function parseHeaders( required struct headers ) {
    var sortedKeyArray = headers.keyArray();
    sortedKeyArray.sort( 'textnocase' );
    var processedHeaders = sortedKeyArray.map( function( key ) { return { name: key.lcase(), value: trim( headers[ key ] ) }; } );
    return processedHeaders;
  }

  public string function parseQueryParams( required struct queryParams, boolean encodeQueryParams = true, boolean includeEmptyValues = true ) {
    var sortedKeyArray = queryParams.keyArray();
    sortedKeyArray.sort( 'textnocase' );
    var queryString = arrayReduce( sortedKeyArray, function( queryString, queryParamKey ) {
        var encodedKey = encodeQueryParams ? encodeUrl( queryParamKey ) : queryParamKey;
        var encodedValue = encodeQueryParams && len( queryParams[ queryParamKey ] ) ? encodeUrl( queryParams[ queryParamKey ] ) : queryParams[ queryParamKey ];
        return queryString.listAppend( encodedKey & ( includeEmptyValues || len( encodedValue ) ? ( '=' & encodedValue ) : '' ), '&' );
      }, '' );
    return queryString;
  }

  public string function encodeUrl( required string str, boolean encodeSlash = true ) {
    var result = replacelist( urlEncodedFormat( arguments.str, 'utf-8' ), '%2D,%2E,%5F,%7E', '-,.,_,~' );
    if ( !encodeSlash ) result = replace( result, '%2F', '/', 'all' );
    return result;
  }

  public string function iso8601( date dateToFormat = now() ) {
    return dateTimeFormat( dateToFormat, 'yyyymmdd', 'UTC' ) & 'T' & dateTimeFormat( dateToFormat, 'HHnnss', 'UTC' ) & 'Z';
  }

  public string function iso8601Full( date dateToFormat = now() ) {
    return dateTimeFormat( dateToFormat, 'yyyy-mm-dd', 'UTC' ) & 'T' & dateTimeFormat( dateToFormat,'HH:nn:ss', 'UTC' ) & '.000Z';
  }

}