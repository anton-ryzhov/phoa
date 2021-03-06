// This file contains:  definitions for data types, data structures, error codes, and function
// prototypes used in the Intel(R) JPEG Library (IJLib).
// Version:     1.51
unit phIJLIntf;
{$Z+,A+} // Caution! It must be 8-byte alignment structures.

interface

uses
  Windows, GR32, Classes, Graphics, SysUtils, TntSysUtils;

type
  PShort = ^Short;
  IJL_INT64  = TLargeInteger;
  IJL_UINT64 = TULargeInteger;

const
  IJL_NONE  = 0;
  IJL_OTHER = 255;
  JBUFSIZE  = 4096;    // Size of file I/O buffer (4K).



// Name:        IJLibVersion
//
// Purpose:     Stores library version info.
//
// Context:
//
// Fields:
//  major           -
//  minor           -
//  build           -
//  Name            -
//  Version         -
//  InternalVersion -
//  BuildDate       -
//  CallConv        -
//


type
  PIJLibVersion = ^TIJLibVersion;
  TIJLibVersion = record
    Major          : Integer;
    Minor          : Integer;
    Build          : Integer;
    Name           : PChar;
    Version        : PChar;
    InternalVersion: PChar;
    BuildDate      : PChar;
    CallConv       : PChar;
  end;


   // Purpose: Keep coordinates for rectangle region of image
   // Context: Used to specify roi
  PIJL_RECT = ^TIJL_RECT;
  TIJL_RECT = record
    Left  : Longint;
    Top   : Longint;
    Right : Longint;
    Bottom: Longint;
  end;

   // Purpose: file handle
   // Context: used internally
  TIJL_HANDLE = Pointer;


   // Name:    IJLIOTYPE
   // Purpose: Possible types of data read/write/other operations to be
   //          performed by the functions IJL_Read and IJL_Write.
   // Fields:
   //  IJL_JFILE_XXXXXXX   Indicates JPEG data in a stdio file.
   //  IJL_JBUFF_XXXXXXX   Indicates JPEG data in an addressable buffer.

const
  IJL_SETUP = -1;
type
  TIJLIOType = (
     // Read JPEG parameters (i.e., height, width, channels, sampling, etc.)
     // from a JPEG bit stream.
    IJL_JFILE_READPARAMS,      //    =  0
    IJL_JBUFF_READPARAMS,      //    =  1
     // Read a JPEG Interchange Format image.
    IJL_JFILE_READWHOLEIMAGE,  //    =  2
    IJL_JBUFF_READWHOLEIMAGE,  //    =  3
     // Read JPEG tables from a JPEG Abbreviated Format bit stream.
    IJL_JFILE_READHEADER,      //    =  4,
    IJL_JBUFF_READHEADER,      //    =  5,
     // Read image info from a JPEG Abbreviated Format bit stream.
    IJL_JFILE_READENTROPY,     //    =  6
    IJL_JBUFF_READENTROPY,     //    =  7
     // Write an entire JFIF bit stream.
    IJL_JFILE_WRITEWHOLEIMAGE, //    =  8
    IJL_JBUFF_WRITEWHOLEIMAGE, //    =  9
     // Write a JPEG Abbreviated Format bit stream.
    IJL_JFILE_WRITEHEADER,     //    = 10
    IJL_JBUFF_WRITEHEADER,     //    = 11
     // Write image info to a JPEG Abbreviated Format bit stream.
    IJL_JFILE_WRITEENTROPY,    //    = 12
    IJL_JBUFF_WRITEENTROPY,    //    = 13

     // Scaled Decoding Options
     
     // Reads a JPEG image scaled to 1/2 size.
    IJL_JFILE_READONEHALF,     //    = 14
    IJL_JBUFF_READONEHALF,     //    = 15
     // Reads a JPEG image scaled to 1/4 size.
    IJL_JFILE_READONEQUARTER,  //    = 16
    IJL_JBUFF_READONEQUARTER,  //    = 17
     // Reads a JPEG image scaled to 1/8 size.
    IJL_JFILE_READONEEIGHTH,   //    = 18
    IJL_JBUFF_READONEEIGHTH,   //    = 19
     // Reads an embedded thumbnail from a JFIF bit stream.
    IJL_JFILE_READTHUMBNAIL,   //    = 20
    IJL_JBUFF_READTHUMBNAIL);  //    = 21

   // Purpose: Possible color space formats.
   // Note these formats do *not* necessarily denote the number of channels in the color space.
   // There exists separate "channel" fields in the JPEG_CORE_PROPERTIES data structure
   // specifically for indicating the number of channels in the JPEG and/or DIB color spaces.
  TIJL_COLOR = (
    IJL_PAD1,      // = 0   // Stub for Delphi, enum type start with 0
    IJL_RGB,       // = 1   // Red-Green-Blue color space.
    IJL_BGR,       // = 2   // Reversed channel ordering from IJL_RGB.
    IJL_YCBCR,     // = 3   // Luminance-Chrominance color space as defined
                            // by CCIR Recommendation 601.
    IJL_G,         // = 4   // Grayscale color space.
    IJL_RGBA_FPX,  // = 5   // FlashPix RGB 4 channel color space that
                            // has pre-multiplied opacity.
    IJL_YCBCRA_FPX // = 6   // FlashPix YCbCr 4 channel color space that
                            // has pre-multiplied opacity.
    //IJL_OTHER  = 255      // Some other color space not defined by the IJL.
                            // (This means no color space conversion will
                            //  be done by the IJL.)
    );

   // Purpose: Possible subsampling formats used in the JPEG.
  TIJL_JPGSUBSAMPLING = (
    IJL_PAD2,      // = 0     // Stub for Delphi, enum type start with 0
    IJL_411,       // = 1,    // Valid on a JPEG w/ 3 channels.
    IJL_422,       // = 2,    // Valid on a JPEG w/ 3 channels.
    IJL_4114,      // = 3,    // Valid on a JPEG w/ 4 channels.
    IJL_4224);     // = 4     // Valid on a JPEG w/ 4 channels.

   // Purpose: Possible subsampling formats used in the DIB.
  TIJL_DIBSUBSAMPLING = TIJL_JPGSUBSAMPLING;

   // Purpose: Stores Huffman table information in a fast-to-use format.
   // Context: Used by Huffman encoder/decoder to access Huffman table data. Raw Huffman tables are formatted to fit
   //   this structure prior to use.//
   // Fields:
   //  huff_class  0 == DC Huffman or lossless table, 1 == AC table.
   //  ident       Huffman table identifier, 0-3 valid (Extended Baseline).
   //  huffelem    Huffman elements for codes <= 8 bits long;
   //              contains both zero run-length and symbol length in bits.
   //  huffval     Huffman values for codes 9-16 bits in length.
   //  mincode     Smallest Huffman code of length n.
   //  maxcode     Largest Huffman code of length n.
   //  valptr      Starting index into huffval[] for symbols of length k.
  PHUFFMAN_TABLE = ^THUFFMAN_TABLE;
  THUFFMAN_TABLE = record
    huff_class: Integer;
    ident     : Integer;
    huffelem  : array [0..255] of UINT;
    huffval   : array [0..255] of SHORT;
    mincode   : array [0..16]  of SHORT;
    maxcode   : array [0..17]  of SHORT;
    valptr    : array [0..16]  of SHORT;
  end;

   // Purpose: Stores pointers to JPEG-binary spec compliant Huffman table information.
   // Context: Used by interface and table methods to specify encoder tables to generate and store JPEG images.
   // Fields:
   //   bits   Points to number of codes of length i (<=16 supported).
   //   vals   Value associated with each Huffman code.
   //   hclass 0 == DC table, 1 == AC table.
   //   ident  Specifies the identifier for this table. 0-3 for extended JPEG compliance.
  PJPEGHuffTable = ^TJPEGHuffTable;
  TJPEGHuffTable = record
    bits  : PUCHAR;
    vals  : PUCHAR;
    hclass: UCHAR;
    ident : UCHAR;
  end;

   // Purpose: Stores quantization table information in a fast-to-use format.
   // Context: Used by quantizer/dequantizer to store formatted quantization tables.
   // Fields:
   //  precision   0 => elements contains 8-bit elements,
   //              1 => elements contains 16-bit elements.
   //  ident       Table identifier (0-3).
   //  elements    Pointer to 64 table elements + 16 extra elements to catch
   //              input data errors that may cause malfunction of the
   //              Huffman decoder.
   //  elarray     Space for elements (see above) plus 8 bytes to align
   //              to a quadword boundary.
  PQUANT_TABLE = ^TQUANT_TABLE;
  TQUANT_TABLE = record
    precision: Integer;
    ident    : Integer;
    elements : PSHORT;
    elarray  : array [0..83] of Short;
  end;

   // Purpose: Stores pointers to JPEG binary spec compliant quantization table information.
   // Context: Used by interface and table methods to specify encoder tables to generate and store JPEG images.
   // Fields:
   //  quantizer   Zig-zag order elements specifying quantization factors.
   //  ident       Specifies identifier for this table.
   //              0-3 valid for Extended Baseline JPEG compliance.
  PJPEGQuantTable = ^TJPEGQuantTable;
  TJPEGQuantTable = record
    quantizer: PUCHAR;
    ident    : UCHAR;
  end;

   // Purpose: One frame-component structure is allocated per component in a frame.
   // Context:     Used by Huffman decoder to manage components.
   // Fields:
   //  ident       Component identifier.  The tables use this ident to
   //              determine the correct table for each component.
   //  hsampling   Horizontal subsampling factor for this component,
   //              1-4 are legal.
   //  vsampling   Vertical subsampling factor for this component,
   //              1-4 are legal.
   //  quant_sel   Quantization table selector.  The quantization table
   //              used by this component is determined via this selector.
  PFRAME_COMPONENT = ^TFRAME_COMPONENT;
  TFRAME_COMPONENT = record
    ident    : Integer;
    hsampling: Integer;
    vsampling: Integer;
    quant_sel: Integer;
  end;

   // Purpose:     Stores frame-specific data.
   // Context:     One Frame structure per image.
   // Fields:
   //  precision       Sample precision in bits.
   //  width           Width of the source image in pixels.
   //  height          Height of the source image in pixels.
   //  MCUheight       Height of a frame MCU.
   //  MCUwidth        Width of a frame MCU.
   //  max_hsampling   Max horiz sampling ratio of any component in the frame.
   //  max_vsampling   Max vert sampling ratio of any component in the frame.
   //  ncomps          Number of components/channels in the frame.
   //  horMCU          Number of horizontal MCUs in the frame.
   //  totalMCU        Total number of MCUs in the frame.
   //  comps           Array of 'ncomps' component descriptors.
   //  restart_interv  Indicates number of MCUs after which to restart the
   //                  entropy parameters.
   //  SeenAllDCScans  Used when decoding Multiscan images to determine if
   //                  all channels of an image have been decoded.
   //  SeenAllACScans  (See SeenAllDCScans)
  PFRAME = ^TFRAME;
  TFRAME = record
    precision     : Integer;
    width         : Integer;
    height        : Integer;
    MCUheight     : Integer;
    MCUwidth      : Integer;
    max_hsampling : Integer;
    max_vsampling : Integer;
    ncomps        : Integer;
    horMCU        : Integer;
    totalMCU      : Longint;
    comps         : PFRAME_COMPONENT;
    restart_interv: Integer;
    SeenAllDCScans: Integer;
    SeenAllACScans: Integer;
  end;

   // Name:        SCAN_COMPONENT
   // Purpose:     One scan-component structure is allocated per component
   //              of each scan in a frame.
   // Context:     Used by Huffman decoder to manage components within scans.
   // Fields:
   //  comp        Component number, index to the comps member of FRAME.
   //  hsampling   Horizontal sampling factor.
   //  vsampling   Vertical sampling factor.
   //  dc_table    DC Huffman table pointer for this scan.
   //  ac_table    AC Huffman table pointer for this scan.
   //  quant_table Quantization table pointer for this scan.
  PSCAN_COMPONENT = ^TSCAN_COMPONENT;
  TSCAN_COMPONENT = record
    comp       : Integer;
    hsampling  : Integer;
    vsampling  : Integer;
    dc_table   : PHUFFMAN_TABLE;
    ac_table   : PHUFFMAN_TABLE;
    quant_table: PQUANT_TABLE;
  end;

   // Purpose:     One SCAN structure is allocated per scan in a frame.
   // Context:     Used by Huffman decoder to manage scans.
   // Fields:
   //  ncomps          Number of image components in a scan, 1-4 legal.
   //  gray_scale      If TRUE, decode only the Y channel.
   //  start_spec      Start coefficient of spectral or predictor selector.
   //  end_spec        End coefficient of spectral selector.
   //  approx_high     High bit position in successive approximation
   //                  Progressive coding.
   //  approx_low      Low bit position in successive approximation
   //                  Progressive coding.
   //  restart_interv  Restart interval, 0 if disabled.
   //  curxMCU         Next horizontal MCU index to be processed after
   //                  an interrupted SCAN.
   //  curyMCU         Next vertical MCU index to be processed after
   //                  an interrupted SCAN.
   //  dc_diff         Array of DC predictor values for DPCM modes.
   //  comps           Array of ncomps SCAN_COMPONENT component identifiers.
  PSCAN = ^TSCAN;
  TSCAN = record
    ncomps        : Integer;
    gray_scale    : Integer;
    start_spec    : Integer;
    end_spec      : Integer;
    approx_high   : Integer;
    approx_low    : Integer;
    restart_interv: UINT;
    curxMCU       : DWORD;
    curyMCU       : DWORD;
    dc_diff       : array [0..3] of Integer;
    comps         : PSCAN_COMPONENT;
  end;

   // Purpose:     Possible algorithms to be used to perform the discrete
   //              cosine transform (DCT).
   // Fields:
   //  IJL_AAN     The AAN (Arai, Agui, and Nakajima) algorithm from
   //              Trans. IEICE, vol. E 71(11), 1095-1097, Nov. 1988.
   //  IJL_IPP     The modified K. R. Rao and P. Yip algorithm from
   //              Intel Performance Primitives Library
  TDCTTYPE = (
    IJL_AAN,   // = 0
    IJL_IPP);  // = 1

   // Purpose:            -  Possible algorithms to be used to perform upsampling
   // Fields:
   //  IJL_BOX_FILTER      - the algorithm is simple replication of the input pixel
   //                        onto the corresponding output pixels (box filter);
   //  IJL_TRIANGLE_FILTER - 3/4 * nearer pixel + 1/4 * further pixel in each
   //                        dimension
  TUPSAMPLING_TYPE = (
    IJL_BOX_FILTER,       // = 0
    IJL_TRIANGLE_FILTER); // = 1

   // Purpose:     Stores current conditions of sampling. Only for upsampling
   //              with triangle filter is used now.
   // Fields:
   //  top_row        - pointer to buffer with MCUs, that are located above than
   //                   current row of MCUs;
   //  cur_row        - pointer to buffer with current row of MCUs;
   //  bottom_row     - pointer to buffer with MCUs, that are located below than
   //                   current row of MCUs;
   //  last_row       - pointer to bottom boundary of last row of MCUs
   //  cur_row_number - number of row of MCUs, that is decoding;
   //  user_interrupt - field to store jprops->interrupt, because of we prohibit
   //                   interrupts while top row of MCUs is upsampling.
  PSAMPLING_STATE = ^TSAMPLING_STATE;
  TSAMPLING_STATE = record
    top_row       : PShort;
    cur_row       : PShort;
    bottom_row    : PShort;
    last_row      : PShort;
    cur_row_number: Integer;
  end;

   // Purpose:     Possible types of processors.
   //              Note that the enums are defined in ascending order
   //              depending upon their various IA32 instruction support.
   // Fields:
   // IJL_OTHER_PROC
   //      Does not support the CPUID instruction and
   //      assumes no Pentium(R) processor instructions.
   //
   // IJL_PENTIUM_PROC
   //      Corresponds to an Intel(R) Pentium processor
   //      (or a 100% compatible) that supports the
   //      Pentium processor instructions.
   //
   // IJL_PENTIUM_PRO_PROC
   //      Corresponds to an Intel Pentium Pro processor
   //      (or a 100% compatible) that supports the
   //      Pentium Pro processor instructions.
   //
   // IJL_PENTIUM_PROC_MMX_TECH
   //      Corresponds to an Intel Pentium processor
   //      with MMX(TM) technology (or a 100% compatible)
   //      that supports the MMX instructions.
   //
   // IJL_PENTIUM_II_PROC
   //      Corresponds to an Intel Pentium II processor
   //      (or a 100% compatible) that supports both the
   //      Pentium Pro processor instructions and the
   //      MMX instructions.
   //
   // IJL_PENTIUM_III_PROC
   //      Corresponds to an Intel(R) Pentium(R) III processor
   //
   // IJL_PENTIUM_4_PROC
   //      Corresponds to an Intel(R) Pentium(R) 4 processor
   //
   // IJL_NEW_PROCESSOR
   //      Correponds to new processor
   //
   //  Any additional processor types that support a superset
   //  of both the Pentium Pro processor instructions and the
   //  MMX instructions should be given an enum value greater
   //  than IJL_PENTIUM_4_PROC.
  TPROCESSOR_TYPE = (
    IJL_OTHER_PROC,            // = 0,
    IJL_PENTIUM_PROC,          // = 1,
    IJL_PENTIUM_PRO_PROC,      // = 2,
    IJL_PENTIUM_PROC_MMX_TECH, // = 3,
    IJL_PENTIUM_II_PROC,       // = 4
    IJL_PENTIUM_III_PROC,      // = 5
    IJL_PENTIUM_4_PROC,        // = 6
    IJL_NEW_PROCESSOR);        // = 7
   
   // Purpose:     Stores data types: raw dct coefficients or raw sampled data.
   //              Pointer to structure in JPEG_PROPERTIES is NULL, if any raw
   //              data isn't request (DIBBytes!=NULL).
   //
   // Fields:
   //  short* raw_ptrs[4] - pointers to buffers with raw data; one pointer
   //                       corresponds one JPG component;
   //  data_type          - 0 - raw dct coefficients, 1 - raw sampled data.
  PRAW_DATA_TYPES_STATE = ^TRAW_DATA_TYPES_STATE;
  TRAW_DATA_TYPES_STATE = record
    data_type     : Integer;
    raw_ptrs      : array [0..3] of PShort;
  end;

   // Purpose:     Stores the decoder state information necessary to "jump"
   //              to a particular MCU row in a compressed entropy stream.
   //
   // Context:     Used to persist the decoder state within Decode_Scan when
   //              decoding using ROIs.
   //
   // Fields:
   //      offset              Offset (in bytes) into the entropy stream
   //                          from the beginning.
   //      dcval1              DC val at the beginning of the MCU row
   //                          for component 1.
   //      dcval2              DC val at the beginning of the MCU row
   //                          for component 2.
   //      dcval3              DC val at the beginning of the MCU row
   //                          for component 3.
   //      dcval4              DC val at the beginning of the MCU row
   //                          for component 4.
   //      bit_buffer_64       64-bit Huffman bit buffer.  Stores current
   //                          bit buffer at the start of a MCU row.
   //                          Also used as a 32-bit buffer on 32-bit
   //                          architectures.
   //      bitbuf_bits_valid   Number of valid bits in the above bit buffer.
   //      unread_marker       Have any markers been decoded but not
   //                          processed at the beginning of a MCU row?
   //                          This entry holds the unprocessed marker, or
   //                          0 if none.
  PENTROPYSTRUCT = ^TENTROPYSTRUCT;
  TENTROPYSTRUCT = record
    offset           : DWORD;
    dcval1           : Integer;
    dcval2           : Integer;
    dcval3           : Integer;
    dcval4           : Integer;
    bit_buffer_64    : IJL_UINT64;
    bitbuf_bits_valid: Integer;
    unread_marker    : Byte;
  end;

   // Purpose:     Stores the active state of the IJL.
   //
   // Context:     Used by all low-level routines to store pseudo-global or
   //              state variables.
   //
   // Fields:
   //      bit_buffer_64           64-bit bitbuffer utilized by Huffman
   //                              encoder/decoder algorithms utilizing routines
   //                              designed for MMX(TM) technology.
   //      bit_buffer_32           32-bit bitbuffer for all other Huffman
   //                              encoder/decoder algorithms.
   //      bitbuf_bits_valid       Number of bits in the above two fields that
   //                              are valid.
   //
   //      cur_entropy_ptr         Current position (absolute address) in
   //                              the entropy buffer.
   //      start_entropy_ptr       Starting position (absolute address) of
   //                              the entropy buffer.
   //      end_entropy_ptr         Ending position (absolute address) of
   //                              the entropy buffer.
   //      entropy_bytes_processed Number of bytes actually processed
   //                              (passed over) in the entropy buffer.
   //      entropy_buf_maxsize     Max size of the entropy buffer.
   //      entropy_bytes_left      Number of bytes left in the entropy buffer.
   //      Prog_EndOfBlock_Run     Progressive block run counter.
   //
   //      DIB_ptr                 Temporary offset into the input/output DIB.
   //
   //      unread_marker           If a marker has been read but not processed,
   //                              stick it in this field.
   //      processor_type          (0, 1, or 2) == current processor does not
   //                              support MMX(TM) instructions.
   //                              (3 or 4) == current processor does
   //                              support MMX(TM) instructions.
   //      cur_scan_comp           On which component of the scan are we working?
   //      file                    Process file handle, or
   //                              0x00000000 if no file is defined.
   //      JPGBuffer               Entropy buffer (~4K).
  PSTATE = ^TSTATE;
  TSTATE = record
    // Bit buffer.
    bit_buffer_64    : IJL_UINT64;
    bit_buffer_32    : DWORD;
    bitbuf_bits_valid: Integer;
    // Entropy.
    cur_entropy_ptr        : PByte;
    start_entropy_ptr      : PByte;
    end_entropy_ptr        : PByte;
    entropy_bytes_processed: Longint;
    entropy_buf_maxsize    : Longint;
    entropy_bytes_left     : Integer;
    Prog_EndOfBlock_Run    : Integer;
    // Input or output DIB.
    DIB_ptr       : PByte;
    unread_marker : Byte;
    processor_type: TPROCESSOR_TYPE;
    cur_scan_comp : Integer;
    hFile         : TIJL_HANDLE; //THandle;
    JPGBuffer     : array [0..JBUFSIZE-1] of Byte;
  end;

   // Name:        FAST_MCU_PROCESSING_TYPE
   // Purpose:     Advanced Control Option.  Do NOT modify.
   //              WARNING:  Used for internal reference only.
   // Fields:
   //   IJL_(sampling)_(JPEG color space)_(sampling)_(DIB color space)
   //      Decode is read left to right w/ upsampling.
   //      Encode is read right to left w/ subsampling.
   //
  TFAST_MCU_PROCESSING_TYPE = (
    IJL_NO_CC_OR_US,                   //  = 0,

    IJL_111_YCBCR_111_RGB,             //  = 1,
    IJL_111_YCBCR_111_BGR,             //  = 2,

    IJL_411_YCBCR_111_RGB,             //  = 3,
    IJL_411_YCBCR_111_BGR,             //  = 4,

    IJL_422_YCBCR_111_RGB,             //  = 5,
    IJL_422_YCBCR_111_BGR,             //  = 6,

    IJL_111_YCBCR_1111_RGBA_FPX,       //  = 7,
    IJL_411_YCBCR_1111_RGBA_FPX,       //  = 8,
    IJL_422_YCBCR_1111_RGBA_FPX,       //  = 9,

    IJL_1111_YCBCRA_FPX_1111_RGBA_FPX, //  = 10,
    IJL_4114_YCBCRA_FPX_1111_RGBA_FPX, //  = 11,
    IJL_4224_YCBCRA_FPX_1111_RGBA_FPX, //  = 12,

    IJL_111_RGB_1111_RGBA_FPX,         //  = 13,

    IJL_1111_RGBA_FPX_1111_RGBA_FPX,   //  = 14

    IJL_111_OTHER_111_OTHER,           //  = 15,
    IJL_411_OTHER_111_OTHER,           //  = 16,
    IJL_422_OTHER_111_OTHER,           //  = 17,

    IJL_YCBYCR_YCBCR,                  //  = 18, encoding from YCbCr 422 format

    IJL_YCBCR_YCBYCR);                 //  = 19  decoding to YCbCr 422 format

   // Purpose:     Stores low-level and control information.  It is used by
   //              both the encoder and decoder.  An advanced external user
   //              may access this structure to expand the interface
   //              capability.
   //
   //              See the Developer's Guide for an expanded description
   //              of this structure and its use.
   //
   // Context:     Used by all interface methods and most IJL routines.
   //
   // Fields:
   //
   //  iotype              IN:     Specifies type of data operation
   //                              (read/write/other) to be
   //                              performed by IJL_Read or IJL_Write.
   //  roi                 IN:     Rectangle-Of-Interest to read from, or
   //                              write to, in pixels.
   //  dcttype             IN:     DCT alogrithm to be used.
   //  fast_processing     OUT:    Supported fast pre/post-processing path.
   //                              This is set by the IJL.
   //  interrupt           IN:     Signals an interrupt has been requested.
   //
   //  DIBBytes            IN:     Pointer to buffer of uncompressed data.
   //  DIBWidth            IN:     Width of uncompressed data.
   //  DIBHeight           IN:     Height of uncompressed data.
   //  DIBPadBytes         IN:     Padding (in bytes) at end of each
   //                              row in the uncompressed data.
   //  DIBChannels         IN:     Number of components in the
   //                              uncompressed data.
   //  DIBColor            IN:     Color space of uncompressed data.
   //  DIBSubsampling      IN:     Required to be IJL_NONE.
   //  DIBLineBytes        OUT:    Number of bytes in an output DIB line
   //                              including padding.
   //
   //  JPGFile             IN:     Pointer to file based JPEG.
   //  JPGBytes            IN:     Pointer to buffer based JPEG.
   //  JPGSizeBytes        IN:     Max buffer size. Used with JPGBytes.
   //                      OUT:    Number of compressed bytes written.
   //  JPGWidth            IN:     Width of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGHeight           IN:     Height of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGChannels         IN:     Number of components in JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGColor            IN:     Color space of JPEG image.
   //  JPGSubsampling      IN:     Subsampling of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGThumbWidth       OUT:    JFIF embedded thumbnail width [0-255].
   //  JPGThumbHeight      OUT:    JFIF embedded thumbnail height [0-255].
   //
   //  cconversion_reqd    OUT:    If color conversion done on decode, TRUE.
   //  upsampling_reqd     OUT:    If upsampling done on decode, TRUE.
   //  jquality            IN:     [0-100] where highest quality is 100.
   //  jinterleaveType     IN/OUT: 0 => MCU interleaved file, and
   //                              1 => 1 scan per component.
   //  numxMCUs            OUT:    Number of MCUs in the x direction.
   //  numyMCUs            OUT:    Number of MCUs in the y direction.
   //
   //  nqtables            IN/OUT: Number of quantization tables.
   //  maxquantindex       IN/OUT: Maximum index of quantization tables.
   //  nhuffActables       IN/OUT: Number of AC Huffman tables.
   //  nhuffDctables       IN/OUT: Number of DC Huffman tables.
   //  maxhuffindex        IN/OUT: Maximum index of Huffman tables.
   //  jFmtQuant           IN/OUT: Formatted quantization table info.
   //  jFmtAcHuffman       IN/OUT: Formatted AC Huffman table info.
   //  jFmtDcHuffman       IN/OUT: Formatted DC Huffman table info.
   //
   //  jEncFmtQuant        IN/OUT: Pointer to one of the above, or
   //                              to externally persisted table.
   //  jEncFmtAcHuffman    IN/OUT: Pointer to one of the above, or
   //                              to externally persisted table.
   //  jEncFmtDcHuffman    IN/OUT: Pointer to one of the above, or
   //                              to externally persisted table.
   //
   //  use_external_qtables IN:    Set to default quantization tables.
   //                              Clear to supply your own.
   //  use_external_htables IN:    Set to default Huffman tables.
   //                              Clear to supply your own.
   //  rawquanttables      IN:     Up to 4 sets of quantization tables.
   //  rawhufftables       IN:     Alternating pairs (DC/AC) of up to 4
   //                              sets of raw Huffman tables.
   //  HuffIdentifierAC    IN:     Indicates what channel the user-
   //                              supplied Huffman AC tables apply to.
   //  HuffIdentifierDC    IN:     Indicates what channel the user-
   //                              supplied Huffman DC tables apply to.
   //
   //  jframe              OUT:    Structure with frame-specific info.
   //  needframe           OUT:    TRUE when a frame has been detected.
   //
   //  jscan               Persistence for current scan pointer when
   //                      interrupted.
   //
   //  state               OUT:    Contains info on the state of the IJL.
   //  SawAdobeMarker      OUT:    Decoder saw an APP14 marker somewhere.
   //  AdobeXform          OUT:    If SawAdobeMarker TRUE, this indicates
   //                              the JPEG color space given by that marker.
   //
   //  rowoffsets          Persistence for the decoder MCU row origins
   //                      when decoding by ROI.  Offsets (in bytes
   //                      from the beginning of the entropy data)
   //                      to the start of each of the decoded rows.
   //                      Fill the offsets with -1 if they have not
   //                      been initalized and NULL could be the
   //                      offset to the first row.
   //
   //  MCUBuf              OUT:    Quadword aligned internal buffer.
   //                              Big enough for the largest MCU
   //                              (10 blocks) with extra room for
   //                              additional operations.
   //  tMCUBuf             OUT:    Version of above, without alignment.
   //
   //  processor_type      OUT:    Determines type of processor found
   //                              during initialization.
   //
   //  raw_coefs           IN:     Place to hold pointers to raw data buffers or
   //                              raw DCT coefficients buffers
   //
   //  progressive_found   OUT:    1 when progressive image detected.
   //  coef_buffer         IN:     Pointer to a larger buffer containing
   //                              frequency coefficients when they
   //                              cannot be decoded dynamically
   //                              (i.e., as in progressive decoding).
   //
   //  upsampling_type     IN:     Type of sampling:
   //                              IJL_BOX_FILTER or IJL_TRIANGLE_FILTER.
   //  SAMPLING_STATE*    OUT:     pointer to structure, describing current
   //                              condition of upsampling
   //
   //  AdobeVersion       OUT      version field, if Adobe APP14 marker detected
   //  AdobeFlags0        OUT      flags0 field, if Adobe APP14 marker detected
   //  AdobeFlags1        OUT      flags1 field, if Adobe APP14 marker detected
   //
   //  jfif_app0_detected OUT:     1 - if JFIF APP0 marker detected,
   //                              0 - if not
   //  jfif_app0_version  IN/OUT   The JFIF file version
   //  jfif_app0_units    IN/OUT   units for the X and Y densities
   //                              0 - no units, X and Y specify
   //                                  the pixel aspect ratio
   //                              1 - X and Y are dots per inch
   //                              2 - X and Y are dots per cm
   //  jfif_app0_Xdensity IN/OUT   horizontal pixel density
   //  jfif_app0_Ydensity IN/OUT   vertical pixel density
   //
   //  jpeg_comment       IN       pointer to JPEG comments
   //  jpeg_comment_size  IN/OUT   size of JPEG comments, in bytes


  PJPEG_PROPERTIES = ^TJPEG_PROPERTIES;
  TJPEG_PROPERTIES = record
    // Compression/Decompression control.
    iotype         : TIJLIOTYPE;                // default = IJL_SETUP
    roi            : TIJL_RECT;                 // default = 0
    dcttype        : TDCTTYPE;                  // default = IJL_AAN
    fast_processing: TFAST_MCU_PROCESSING_TYPE; // default = IJL_NO_CC_OR_US
    intr           : DWORD;                     // default = FALSE

    // DIB specific I/O data specifiers.
    DIBBytes      : PByte;               // default = NULL
    DIBWidth      : DWORD;               // default = 0
    DIBHeight     : Integer;             // default = 0
    DIBPadBytes   : DWORD;               // default = 0
    DIBChannels   : DWORD;               // default = 3
    DIBColor      : TIJL_COLOR;          // default = IJL_BGR
    DIBSubsampling: TIJL_DIBSUBSAMPLING; // default = IJL_NONE
    DIBLineBytes  : Integer;             // default = 0

    // JPEG specific I/O data specifiers.
    JPGFile       : PChar;               // default = NULL
    JPGBytes      : PByte;               // default = NULL
    JPGSizeBytes  : DWORD;               // default = 0
    JPGWidth      : DWORD;               // default = 0
    JPGHeight     : DWORD;               // default = 0
    JPGChannels   : DWORD;               // default = 3
    JPGColor      : TIJL_COLOR;          // default = IJL_YCBCR
    JPGSubsampling: TIJL_JPGSUBSAMPLING; // default = IJL_411
    JPGThumbWidth : DWORD;               // default = 0
    JPGThumbHeight: DWORD;               // default = 0

    // JPEG conversion properties.
    cconversion_reqd: DWORD;             // default = TRUE
    upsampling_reqd : DWORD;             // default = TRUE
    jquality        : DWORD;             // default = 75
    jinterleaveType : DWORD;             // default = 0
    numxMCUs        : DWORD;             // default = 0
    numyMCUs        : DWORD;             // default = 0

    // Tables.
    nqtables     : DWORD;
    maxquantindex: DWORD;
    nhuffActables: DWORD;
    nhuffDctables: DWORD;
    maxhuffindex : DWORD;

    jFmtQuant    : array [0..3] of TQUANT_TABLE;
    jFmtAcHuffman: array [0..3] of THUFFMAN_TABLE;
    jFmtDcHuffman: array [0..3] of THUFFMAN_TABLE;

    jEncFmtQuant    : array [0..3] of PSHORT;
    jEncFmtAcHuffman: array [0..3] of PHUFFMAN_TABLE;
    jEncFmtDcHuffman: array [0..3] of PHUFFMAN_TABLE;

    // Allow user-defined tables.
    use_external_qtables: DWORD;
    use_external_htables: DWORD;

    rawquanttables  : array [0..3] of TJPEGQuantTable;
    rawhufftables   : array [0..7] of TJPEGHuffTable;
    HuffIdentifierAC: array [0..3] of Byte;
    HuffIdentifierDC: array [0..3] of Byte;

    // Frame specific members.
    jframe   : TFRAME;
    needframe: Integer;

    // SCAN persistent members.
    jscan: PSCAN;

    Pad  : DWORD;  // 8-byte alignment!

    // State members.
    state         : TSTATE;
    SawAdobeMarker: DWORD;
    AdobeXform    : DWORD;

    // ROI decoder members.
    rowoffsets: PENTROPYSTRUCT;

    // Intermediate buffers.
    MCUBuf : PByte;
    tMCUBuf: array [0..720*2-1] of Byte;

    // Processor detected.
    processor_type: TPROCESSOR_TYPE;

    raw_coefs: PRAW_DATA_TYPES_STATE;

    // Progressive mode members.
    progressive_found: Integer;
    coef_buffer      : PShort;

    // Upsampling mode members.
    upsampling_type   : TUPSAMPLING_TYPE;
    sampling_state_ptr: PSAMPLING_STATE;

    // Adobe APP14 segment variables
    AdobeVersion: Short;         // default = 100
    AdobeFlags0 : Short;         // default = 0
    AdobeFlags1 : Short;         // default = 0

    // JFIF APP0 segment variables
    jfif_app0_detected: Integer;
    jfif_app0_version : Short;    // default = 0x0101
    jfif_app0_units   : UCHAR;    // default = 0 - pixel
    jfif_app0_Xdensity: Short;    // default = 1
    jfif_app0_Ydensity: Short;    // default = 1

    // comments related fields
    jpeg_comment     : PChar;     // default = NULL
    jpeg_comment_size: Short;     // default = 0

  end;

   // Purpose:     This is the primary data structure between the IJL and
   //              the external user.  It stores JPEG state information
   //              and controls the IJL.  It is user-modifiable.
   //
   //              See the Developer's Guide for details on appropriate usage.
   //
   // Context:     Used by all low-level IJL routines to store
   //              pseudo-global information.
   //
   // Fields:
   //
   //  UseJPEGPROPERTIES   Set this flag != 0 if you wish to override
   //                      the JPEG_CORE_PROPERTIES "IN" parameters with
   //                      the JPEG_PROPERTIES parameters.
   //
   //  DIBBytes            IN:     Pointer to buffer of uncompressed data.
   //  DIBWidth            IN:     Width of uncompressed data.
   //  DIBHeight           IN:     Height of uncompressed data.
   //  DIBPadBytes         IN:     Padding (in bytes) at end of each
   //                              row in the uncompressed data.
   //  DIBChannels         IN:     Number of components in the
   //                              uncompressed data.
   //  DIBColor            IN:     Color space of uncompressed data.
   //  DIBSubsampling      IN:     Required to be IJL_NONE.
   //
   //  JPGFile             IN:     Pointer to file based JPEG.
   //  JPGBytes            IN:     Pointer to buffer based JPEG.
   //  JPGSizeBytes        IN:     Max buffer size. Used with JPGBytes.
   //                      OUT:    Number of compressed bytes written.
   //  JPGWidth            IN:     Width of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGHeight           IN:     Height of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGChannels         IN:     Number of components in JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGColor            IN:     Color space of JPEG image.
   //  JPGSubsampling      IN:     Subsampling of JPEG image.
   //                      OUT:    After reading (except READHEADER).
   //  JPGThumbWidth       OUT:    JFIF embedded thumbnail width [0-255].
   //  JPGThumbHeight      OUT:    JFIF embedded thumbnail height [0-255].
   //
   //  cconversion_reqd    OUT:    If color conversion done on decode, TRUE.
   //  upsampling_reqd     OUT:    If upsampling done on decode, TRUE.
   //  jquality            IN:     [0-100] where highest quality is 100.
   //
   //  jprops              "Low-Level" IJL data structure.

type
  PJPEG_CORE_PROPERTIES = ^TJPEG_CORE_PROPERTIES;
  TJPEG_CORE_PROPERTIES = record
    UseJPEGPROPERTIES: DWORD;               // default = 0

    // DIB specific I/O data specifiers.
    DIBBytes         : PByte;               // default = NULL
    DIBWidth         : DWORD;               // default = 0
    DIBHeight        : Integer;             // default = 0
    DIBPadBytes      : DWORD;               // default = 0
    DIBChannels      : DWORD;               // default = 3
    DIBColor         : TIJL_COLOR;          // default = IJL_BGR
    DIBSubsampling   : TIJL_DIBSUBSAMPLING; // default = IJL_NONE

    // JPEG specific I/O data specifiers.
    JPGFile          : PChar;               // default = NULL
    JPGBytes         : PByte;               // default = NULL
    JPGSizeBytes     : DWORD;               // default = 0
    JPGWidth         : DWORD;               // default = 0
    JPGHeight        : DWORD;               // default = 0
    JPGChannels      : DWORD;               // default = 3
    JPGColor         : TIJL_COLOR;          // default = IJL_YCBCR
    JPGSubsampling   : TIJL_JPGSUBSAMPLING; // default = IJL_411
    JPGThumbWidth    : DWORD;               // default = 0
    JPGThumbHeight   : DWORD;               // default = 0

    // JPEG conversion properties.
    cconversion_reqd : DWORD;               // default = TRUE
    upsampling_reqd  : DWORD;               // default = TRUE
    jquality         : DWORD;               // default = 75

    Pad              : DWORD;               // 8-byte alignment!!!
    // Low-level properties.
    jprops           : TJPEG_PROPERTIES;
  end;

   // Name:        IJLERR
   // Purpose:     Listing of possible "error" codes returned by the IJL.
   //              See the Developer's Guide for details on appropriate usage.
   // Context:     Used for error checking.

const
  // The following "error" values indicate an "OK" condition.
  IJL_OK                              =   0;
  IJL_INTERRUPT_OK                    =   1;
  IJL_ROI_OK                          =   2;

  // The following "error" values indicate an error has occurred.
  IJL_EXCEPTION_DETECTED              =  -1;
  IJL_INVALID_ENCODER                 =  -2;
  IJL_UNSUPPORTED_SUBSAMPLING         =  -3;
  IJL_UNSUPPORTED_BYTES_PER_PIXEL     =  -4;
  IJL_MEMORY_ERROR                    =  -5;
  IJL_BAD_HUFFMAN_TABLE               =  -6;
  IJL_BAD_QUANT_TABLE                 =  -7;
  IJL_INVALID_JPEG_PROPERTIES         =  -8;
  IJL_ERR_FILECLOSE                   =  -9;
  IJL_INVALID_FILENAME                = -10;
  IJL_ERROR_EOF                       = -11;
  IJL_PROG_NOT_SUPPORTED              = -12;
  IJL_ERR_NOT_JPEG                    = -13;
  IJL_ERR_COMP                        = -14;
  IJL_ERR_SOF                         = -15;
  IJL_ERR_DNL                         = -16;
  IJL_ERR_NO_HUF                      = -17;
  IJL_ERR_NO_QUAN                     = -18;
  IJL_ERR_NO_FRAME                    = -19;
  IJL_ERR_MULT_FRAME                  = -20;
  IJL_ERR_DATA                        = -21;
  IJL_ERR_NO_IMAGE                    = -22;
  IJL_FILE_ERROR                      = -23;
  IJL_INTERNAL_ERROR                  = -24;
  IJL_BAD_RST_MARKER                  = -25;
  IJL_THUMBNAIL_DIB_TOO_SMALL         = -26;
  IJL_THUMBNAIL_DIB_WRONG_COLOR       = -27;
  IJL_BUFFER_TOO_SMALL                = -28;
  IJL_UNSUPPORTED_FRAME               = -29;
  IJL_ERR_COM_BUFFER                  = -30;
  IJL_RESERVED                        = -99;

   //===================================================================================================================
   // Function Prototypes (API Calls)
   //===================================================================================================================

type
   // Purpose:     Used to initalize the IJL.
   // Context:     Always call this before anything else.
   //              Also, only call this with a new jcprops structure, or
   //              after calling IJL_Free.  Otherwise, dynamically
   //              allocated memory may be leaked.
   // Returns:     Any IJLERR value.  IJL_OK indicates success.
   // Parameters:
   //  jcprops     Pointer to an externally allocated
   //              JPEG_CORE_PROPERTIES structure.
  TijlInitProc          = function(jcprops: PJPEG_CORE_PROPERTIES): Integer; stdcall;
   // Purpose:     Used to properly close down the IJL.
   // Context:     Always call this when done using the IJL to perform
   //              clean-up of dynamically allocated memory.
   //              Note, IJL_Init will have to be called to use the IJL again.
   // Returns:     Any IJLERR value.  IJL_OK indicates success.
   // Parameters:
   //  jcprops     Pointer to an externally allocated
   //              JPEG_CORE_PROPERTIES structure.
  TijlFreeProc          = function(jcprops: PJPEG_CORE_PROPERTIES): Integer; stdcall;
   // Purpose:     Used to read JPEG data (entropy, or header, or both) into
   //              a user-supplied buffer (to hold the image data) and/or
   //              into the JPEG_CORE_PROPERTIES structure (to hold the
   //              header info).
   // Context:     The jcprops main data members are checked for consistency.
   // Returns:     Any IJLERR value.  IJL_OK indicates success.
   // Parameters:
   //  jcprops     Pointer to an externally allocated
   //              JPEG_CORE_PROPERTIES structure.
   //  iotype      Specifies what type of read operation to perform.
  TijlReadProc          = function(jcprops: PJPEG_CORE_PROPERTIES; IoType: TIJLIOTYPE): Integer; stdcall;
   // Purpose:     Used to write JPEG data (entropy, or header, or both) into
   //              a user-supplied buffer (to hold the image data) and/or
   //              into the JPEG_CORE_PROPERTIES structure (to hold the
   //              header info).
   // Context:     The jcprops main data members are checked for consistency.
   // Returns:     Any IJLERR value.  IJL_OK indicates success.
   // Parameters:
   //  jcprops     Pointer to an externally allocated
   //              JPEG_CORE_PROPERTIES structure.
   //  iotype      Specifies what type of write operation to perform.
  TijlWriteProc         = function(jcprops: PJPEG_CORE_PROPERTIES; IoType: TIJLIOTYPE): Integer; stdcall;
   // Purpose:     To identify the version number of the IJL.
   // Context:     Call to get the IJL version number.
   // Returns:     pointer to IJLibVersion struct
  TijlGetLibVersionProc = function: PIJLibVersion; stdcall;
   // Purpose:     Gets the String to describe error code.
   // Context:     Is called to get descriptive String on arbitrary IJLERR code.
   // Returns:     pointer to String
   // Parameters:  IJLERR - IJL error code
  TijlErrorStrProc      = function(Code: Integer): PChar; stdcall;

   //===================================================================================================================
   // IJL Function mappings. Can use only if bIJL_Available=True!
   //===================================================================================================================

var
  ijlInit:          TijlInitProc;
  ijlFree:          TijlFreeProc;
  ijlRead:          TijlReadProc;
  ijlWrite:         TijlWriteProc;
  ijlGetLibVersion: TijlGetLibVersionProc;
  ijlErrorStr:      TijlErrorStrProc;

   //===================================================================================================================
   // Delphi interface to IJL
   //===================================================================================================================

resourcestring
  SIJLError = 'Error %s image:'+#13+'%s'+#13+'Error: %s'+#13+'IJL Error number: %d';

type
  EIJLError = class(Exception);
  EJPEGLoadError = class(Exception);
  EJPEGDrawError = class(Exception);
  TIJL_Quality = 0..100;

var
   // True, ���� ���������� IJL ������� � ����������
  bIJL_Available: Boolean;

  procedure RGBA2BGRA(pData: Pointer; Width, Height: Integer);

  procedure SaveTo24bitJPEGFile(Bitmap32: TBitmap32; const FileName: String; Quality: TIJL_Quality = 75; const Progressive_Passes: Boolean = False);
   // ��������� JPEG-���� � Bitmap32. ���� iDesiredWidth=0 ��� iDesiredHeight=0, ��������� ���� �������; ����� ���������
   //   ���������� ������� ������ (1/2, 1/4 ��� 1/8), ����� ������ ���� ������ iDesiredWidth, � ������ - ������
   //   iDesiredHeight
  procedure LoadJPEGFromFile(Bitmap32: TBitmap32; const Filename: String; const DesiredSize: TSize; out FullSize: TSize);

  procedure Save24bitJPEGToStream(Bitmap32: TBitmap32; MemStream: TMemoryStream; Quality: TIJL_Quality = 75; const Progressive_Passes: Boolean = False);
  procedure LoadJPEGFromStream(Bitmap32: TBitmap32; MemStream: TMemoryStream);

implementation /////////////////////////////////////////////////////////////////////////////////////////////////////////
uses ConsVars;

   // used only for reading 32 bit JPEGs
  procedure RGBA2BGRA(pData: Pointer; Width, Height: Integer);
  var
    i, Pixel: Integer;
    bP: Array[0..3] of Byte absolute Pixel;
    p: PInteger;
    Tmp: Byte;
  begin
    p := PInteger(pData);
    for i := 0 to Height*Width-1 do begin
      Pixel := p^;
      Tmp := Byte((Integer(bP[0])*bP[3]+1) shr 8);
      bP[0] := Byte((Integer(bP[2])*bP[3]+1) shr 8);
      bP[1] := Byte((Integer(bp[1])*bP[3]+1) shr 8);
      bP[2] := Tmp;
      p^ := Pixel;
      Inc(p);
    end;
  end;


  { Quality: 0..100, small values gives small file size but greater quality loss.

   Progressive_Passes: if True, should create a GIF type image that, when loaded
   from a web page, is quickly shown as a complete poor quality image,
   then at better and better quality as it continues loading.
   Doesn't work though?
   Internet Explorer doesn't seem to support it (unless my code is wrong).
   Also, switching it on turns incremental display OFF (where the downloading
   image is shown line by line), so none of the image shows until it is all loaded.
   Also makes the file slightly larger. I might remove this.}
  procedure SaveTo24bitJPEGFile(Bitmap32: TBitmap32; const FileName: String; Quality: TIJL_Quality = 75; const Progressive_Passes: Boolean = False);
  var
    Bitmap: TBitmap;
    DIB: TDIBSection;
    jcprops: TJPEG_CORE_PROPERTIES;
    ret: Integer;
  begin
    if Bitmap32.Empty then raise Exception.Create('No image to save');
    FillChar (jcprops, SizeOf (jcprops), 0);
    ret := ijlInit (@jcprops); // Initialises Intel JPEG unit
    if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['initializing for', Filename, ijlErrorStr(ret), ret]);
    try
      Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(Bitmap32);
        Bitmap.PixelFormat := pf24bit;
        FillChar(DIB, SizeOf(DIB), 0);
        if GetObject(Bitmap.Handle, SizeOf (DIB), @DIB)=0 then OutOfMemoryError;
        with jcprops do begin
          DIBWidth := DIB.dsBm.bmWidth;
          DIBHeight := - DIB.dsBm.bmHeight;
          DIBChannels := 3;
          DIBColor := IJL_BGR;
          DIBPadBytes := ((((DIB.dsBm.bmWidth * 3) + 3) div 4) * 4)-(DIB.dsBm.bmWidth * 3);
          DIBBytes := PByte(DIB.dsBm.bmBits);
          JPGChannels := 3;
          JPGColor := IJL_YCBCR;
          JPGFile := PChar(FileName);
          jquality := Quality;
          JPGWidth := DIB.dsBm.bmWidth;
          JPGHeight := DIB.dsBm.bmHeight;
          if Progressive_Passes then jprops.progressive_found := 1;
        end;
        ret := ijlWrite(@jcprops, IJL_JFILE_WRITEWHOLEIMAGE);
        if ret<>IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['Saving', Filename, ijlErrorStr(ret), ret]);
      finally
        Bitmap.Free;
      end;
    finally
      ijlFree(@jcprops);
    end;
  end;

  procedure LoadJPEGFromFile(Bitmap32: TBitmap32; const Filename: String; const DesiredSize: TSize; out FullSize: TSize);
  var
    Bitmap: TBitmap;
    DIB: TDIBSection;
    jcprops: TJPEG_CORE_PROPERTIES;
    ret, iWidth, iHeight: Integer;
    ReadType: TIJLIOType;

     // ���������� True, ���� ����������� ����� ��������� �������� (�����, ������������ ��������� iDivisor). ����� �
     //   ���� ������ ��������� iWidth, iHeight � ReadType
    function TryUsePartialLoad(iDivisor: Integer; AReadType: TIJLIOType): Boolean;
    var iRealWidth, iRealHeight: Integer;
    begin
       // �������, ����� ������� ����� � �����������
      iRealWidth  := (iWidth +iDivisor-1) div iDivisor;
      iRealHeight := (iHeight+iDivisor-1) div iDivisor;
       // ���� ��� ������� ��������� ��������� ��� ������� ����� (��� ������������� �����������) - ���������
      Result := (iRealWidth>DesiredSize.cx*2) and (iRealHeight>DesiredSize.cy*2);
      if Result then begin
        iWidth   := iRealWidth;
        iHeight  := iRealHeight;
        ReadType := AReadType;
      end;
    end;

  begin
    Assert(Bitmap32<>nil, 'Bitmap32 must not be nil');
    if not FileExists(Filename) then raise Exception.Create(Filename+#13+'does not exist');
    // Initialize Intel JPEG unit
    FillChar(jcprops, SizeOf (jcprops), 0);
    ret := ijlInit(@jcprops);
    if ret<>IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['initializing for', Filename, ijlErrorStr(ret), ret]);
     // Create a temporary bitmap
    Bitmap := TBitmap.Create;
    try
      jcprops.JPGFile := PChar(Filename);
      ret := ijlRead(@jcprops, IJL_JFILE_READPARAMS);
      if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['reading parameters of', Filename, ijlErrorStr(ret), ret]);
      case jcprops.JPGChannels of
         // Grayscale JPEG
        1: begin
          jcprops.JPGColor    := IJL_G;
          jcprops.DIBChannels := 3;
          jcprops.DIBColor    := IJL_BGR;
          Bitmap.PixelFormat := pf24bit;
        end;
         // 24 bit color (most common format)
        3: begin
          jcprops.JPGColor    := IJL_YCBCR;
          jcprops.DIBChannels := 3;
          jcprops.DIBColor    := IJL_BGR;
          Bitmap.PixelFormat := pf24bit;
        end;
         // 32 bit 4 channel JPEG. UNTESTED!
        4: begin
          jcprops.JPGColor    := IJL_YCBCRA_FPX;
          jcprops.DIBChannels := 4;
          jcprops.DIBColor    := IJL_RGBA_FPX;
          Bitmap.PixelFormat := pf32bit;
        end;
         // unknown type - no 'Color Twist' is performed, whatever that is...
        else begin
          jcprops.DIBColor    := TIJL_COLOR(IJL_OTHER);
          jcprops.JPGColor    := TIJL_COLOR(IJL_OTHER);
          jcprops.DIBChannels := jcprops.JPGChannels;
        end;
      end;
       // ���������� ��������� ������� �������
      iWidth  := jcprops.JPGWidth;
      iHeight := jcprops.JPGHeight;
      FullSize.cx := iWidth;
      FullSize.cy := iHeight;
       // ���� �������� ������� ������, ������� ������ 1/8, ����� 1/4, ����� 1/2
      if (DesiredSize.cx<=0) or (DesiredSize.cy<=0) or
         (not TryUsePartialLoad(8, IJL_JFILE_READONEEIGHTH) and
          not TryUsePartialLoad(4, IJL_JFILE_READONEQUARTER) and
          not TryUsePartialLoad(2, IJL_JFILE_READONEHALF)) then ReadType := IJL_JFILE_READWHOLEIMAGE;
       // ��������� Bitmap
      Bitmap.Width  := iWidth;
      Bitmap.Height := iHeight;
      FillChar(DIB, SizeOf(DIB), 0);
      if GetObject(Bitmap.Handle, SizeOf(DIB), @DIB) = 0 then OutOfMemoryError;
      jcProps.DIBWidth    := iWidth;
      jcProps.DIBHeight   := -iHeight;
      jcProps.DIBPadBytes := ((((iWidth*Integer(jcProps.DIBChannels))+3) div 4)*4)-(iWidth*Integer(jcProps.DIBChannels));
      jcProps.DIBBytes    := PByte(DIB.dsBm.bmBits);
      ret := ijlRead(@jcprops, ReadType);
      if ret<>IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['reading', Filename, ijlErrorStr(ret), ret]);
      if jcProps.DIBColor=IJL_RGBA_FPX then RGBA2BGRA(jcprops.DIBBytes, iWidth, iHeight);
      Bitmap32.Assign(Bitmap);
    finally
      Bitmap.Free;
      ijlFree(@jcprops);
    end;
  end;

  procedure Save24bitJPEGToStream(Bitmap32: TBitmap32; MemStream: TMemoryStream; Quality: TIJL_Quality = 75; const Progressive_Passes: Boolean = False);
  var
    Bitmap: TBitmap;
    DIB: TDIBSection;
    jcprops: TJPEG_CORE_PROPERTIES;
    i, ret: Integer;
    Buff: LongInt;
  begin
    if Bitmap32.Empty then raise Exception.Create('No image to save');
    MemStream.Clear;
    FillChar(jcprops, SizeOf (jcprops), 0);
    ret := ijlInit(@jcprops); // Initializes Intel JPEG unit
    if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['initializing Intel JPEG unit', '', ijlErrorStr(ret), ret]);
    try
      Bitmap := TBitmap.Create;
      try
        Bitmap.Assign(Bitmap32);
        Bitmap.PixelFormat := pf24bit;
        FillChar(DIB, SizeOf(DIB), 0);
        if GetObject(Bitmap.Handle, SizeOf (DIB), @DIB) = 0 then OutOfMemoryError;
        with jcprops do begin
          DIBWidth := DIB.dsBm.bmWidth;
          DIBHeight := - DIB.dsBm.bmHeight;
          DIBChannels := 3;
          DIBColor := IJL_BGR;
          DIBPadBytes := ((((DIB.dsBm.bmWidth * 3) + 3) div 4) * 4)-(DIB.dsBm.bmWidth * 3);
          DIBBytes := PByte(DIB.dsBm.bmBits);
          JPGChannels := 3;
          JPGColor := IJL_YCBCR;
          JPGFile := nil;
          jquality := Quality;
          JPGWidth := DIB.dsBm.bmWidth;
          JPGHeight := DIB.dsBm.bmHeight;
          JPGSizeBytes := DIB.dsBm.bmWidth *  DIB.dsBm.bmHeight * 3;
          MemStream.SetSize(JPGSizeBytes); // allow for header?
          JPGBytes := MemStream.Memory;
          if Progressive_Passes then jprops.progressive_found := 1;
        end;
        ret := ijlWrite(@jcprops, IJL_JBUFF_WRITEWHOLEIMAGE);
        if ret<>IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['Saving to stream', '', ijlErrorStr(ret), ret]);
      finally
        Bitmap.Free;
      end;
    finally
      ijlFree(@jcprops);
    end;
    { the memory stream now has compressed JPEG, but is the size of UNCOMPRESSED image.
      Resize the memory stream, deleting the unused ($0) bytes}
    with MemStream do begin
      i := Size - $10;
      Seek(i, soFromBeginning);
      Read(Buff, 4);
      while Buff = $0 do begin
        Dec(i);
        Seek(i, soFromBeginning);
        Read(Buff, 4)
      end;
      SetSize(i + 1);
    end;
  end;

  procedure LoadJPEGFromStream(Bitmap32: TBitmap32; MemStream: TMemoryStream);
  var
    Bitmap: TBitmap;
    DIB: TDIBSection;
    jcprops: TJPEG_CORE_PROPERTIES;
    ret: Integer;
  begin
    Assert(Bitmap32<>nil, 'Bitmap32 must not be nil');
    //MemStream.Seek(0, 0);
    Bitmap := TBitmap.Create;
    // Initialise Intel JPEG unit
    FillChar(jcprops, SizeOf (jcprops), 0);
    ret := ijlInit (@jcprops);
    if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['initializing Intel JPEG unit', '', ijlErrorStr(ret), ret]);
    try
      jcprops.JPGFile := nil;
      jcprops.JPGBytes := MemStream.Memory;
      jcprops.JPGSizeBytes := MemStream.Size;
      ret := ijlRead (@jcprops, IJL_JBUFF_READPARAMS);
      if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['reading parameters from stream', '', ijlErrorStr(ret), ret]);
      with jcprops do begin
        case JPGChannels of
          1: begin  // Grayscale JPEG
            JPGColor := IJL_G;
            DIBChannels := 3;
            DIBColor := IJL_BGR;
            Bitmap.PixelFormat := pf24bit;
          end;
          3: begin // 24 bit color (most common format)
            JPGColor := IJL_YCBCR;
            DIBChannels := 3;
            DIBColor := IJL_BGR;
            Bitmap.PixelFormat := pf24bit;
          end;
          4: begin  // 32 bit 4 channel JPEG. UNTESTED!
            JPGColor := IJL_YCBCRA_FPX;
            DIBChannels := 4;
            DIBColor := IJL_RGBA_FPX;
            Bitmap.PixelFormat := pf32bit
          end;
          else
            // unknown type - no 'Color Twist' is performed, whatever that is...
            DIBColor := TIJL_COLOR(IJL_OTHER);
            JPGColor := TIJL_COLOR(IJL_OTHER);
            DIBChannels := JPGChannels;
        end;
        Bitmap.Width := JPGWidth;
        Bitmap.Height := JPGHeight;
        FillChar(DIB, SizeOf(DIB), 0);
        if GetObject(Bitmap.Handle, SizeOf(DIB), @DIB) = 0 then OutOfMemoryError;
        DIBWidth := JPGWidth;
        DIBHeight := - JPGHeight;
        DIBPadBytes := ((((JPGWidth * DIBChannels) + 3) div 4) * 4)-(JPGWidth * DIBChannels);
        DIBBytes := PByte(DIB.dsBm.bmBits);
        ret := ijlRead(@jcprops, IJL_JBUFF_READWHOLEIMAGE);
        if ret <> IJL_OK then raise EIJLError.CreateFmt(SIJLError, ['reading JPEG image from stream', '', ijlErrorStr(ret), ret]);
        if DIBColor=IJL_RGBA_FPX then RGBA2BGRA(jcprops.DIBBytes, JPGWidth, JPGHeight);
      end; 
      Bitmap32.Assign(Bitmap);
    finally
      Bitmap.Free;
      ijlFree(@jcprops);
    end;
  end;

   //===================================================================================================================
   // Dynamic IJL dll binding procedures
   //===================================================================================================================

  function BindLibProc(hLib: HModule; const sProcName: String): Pointer;
  begin
    Result := GetProcAddress(hLib, PChar(sProcName));
    if Result=nil then raise Exception.CreateFmt('Cannot find entry point for %s in ijl15.dll', [sProcName]);
  end;

  function LoadIJLLib: Boolean;
  var hLib: HMODULE;
  begin
     // ������ ����������
    hLib := WideSafeLoadLibrary(wsApplicationPath+SRelativePluginPath+'ijl15.dll');
    Result := hLib<>0;
     // ���� �������, ���������� �������
    if Result then begin
      ijlInit          := BindLibProc(hLib, 'ijlInit');
      ijlFree          := BindLibProc(hLib, 'ijlFree');
      ijlRead          := BindLibProc(hLib, 'ijlRead');
      ijlWrite         := BindLibProc(hLib, 'ijlWrite');
      ijlGetLibVersion := BindLibProc(hLib, 'ijlGetLibVersion');
      ijlErrorStr      := BindLibProc(hLib, 'ijlErrorStr');
    end;
  end;

initialization
  bIJL_Available := LoadIJLLib;
end.

